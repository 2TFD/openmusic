import 'dart:async';

import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_sync_events.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which account the cloud rows in the local database belong to.
abstract interface class CloudAccountOwnerStore {
  Future<String?> read();
  Future<void> write(String? accountId);
}

class SharedPreferencesCloudAccountOwnerStore
    implements CloudAccountOwnerStore {
  SharedPreferencesCloudAccountOwnerStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'owlsonic.cloud_account_id';
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> read() => _instance.getString(key);
  @override
  Future<void> write(String? accountId) => accountId == null
      ? _instance.remove(key)
      : _instance.setString(key, accountId);
}

enum CloudSyncPhase { idle, syncing, failed }

class CloudSyncStatus {
  const CloudSyncStatus({
    this.phase = CloudSyncPhase.idle,
    this.lastSyncedAt,
    this.lastErrorCode,
  });
  final CloudSyncPhase phase;
  final DateTime? lastSyncedAt;
  final String? lastErrorCode;
}

/// The one place that runs `GET /v1/sync`. Triggers (sign-in, launch, resume,
/// import, mutations, a modest foreground timer) only *request* a sync; runs
/// are serialised and coalesced, so widgets cannot cause sync storms.
///
/// Account isolation: cloud rows are tagged with the owning account. Signing
/// out, or a different account signing in, purges them (never files) and the
/// cursor is stored per account.
class CloudSyncCoordinator {
  CloudSyncCoordinator({
    required AuthSession session,
    AnalyticsTracker analytics = const NoopAnalyticsTracker(),
    required bool configured,
    required CloudAccountRepository account,
    required CloudSyncRepository remote,
    required CloudLocalStore local,
    required CloudAccountOwnerStore owner,
    required SyncCursorStore Function(String accountId) cursorsFor,
    List<Future<void> Function()> afterSync = const [],
    List<Future<void> Function()> afterPurge = const [],
    this.pollInterval = const Duration(minutes: 3),
    this.pageSize,
  }) : _session = session,
       _analytics = analytics,
       _configured = configured,
       _account = account,
       _remote = remote,
       _local = local,
       _owner = owner,
       _cursorsFor = cursorsFor,
       _afterSync = afterSync,
       _afterPurge = afterPurge;

  final AuthSession _session;
  final AnalyticsTracker _analytics;
  int? _reportedFailureEpoch;
  final bool _configured;
  final CloudAccountRepository _account;
  final CloudSyncRepository _remote;
  final CloudLocalStore _local;
  final CloudAccountOwnerStore _owner;
  final SyncCursorStore Function(String accountId) _cursorsFor;
  final List<Future<void> Function()> _afterSync;

  /// Runs after cloud rows were purged (sign-out or another account), to
  /// remove audio files that belonged to them.
  final List<Future<void> Function()> _afterPurge;
  final Duration pollInterval;
  final int? pageSize;

  final _status = StreamController<CloudSyncStatus>.broadcast();
  CloudSyncStatus _current = const CloudSyncStatus();
  StreamSubscription<AuthStatus>? _authSubscription;
  Timer? _poll;
  Future<void>? _running;
  bool _again = false;
  String? _accountId;
  int? _accountEpoch;
  String? _restoredOwner;
  int? _restoredEpoch;

  CloudSyncStatus get status => _current;

  /// Account of the current session as confirmed by `/v1/me` in this
  /// session; null while unknown or signed out.
  String? get verifiedAccountId =>
      _accountEpoch != null && _session.isCurrent(_accountEpoch!)
      ? _accountId
      : null;

  /// [verifiedAccountId], or before the first `/v1/me` of a restored session
  /// the owner persisted for it. Used to tag work (e.g. queued plays) so it is
  /// only ever sent for the account it was recorded under.
  String? get currentAccountId =>
      verifiedAccountId ??
      (_restoredEpoch != null && _session.isCurrent(_restoredEpoch!)
          ? _restoredOwner
          : null);
  Stream<CloudSyncStatus> get statusChanges => _status.stream;

  Future<void> start() async {
    if (!_configured || _authSubscription != null) return;
    _authSubscription = _session.changes.listen(_onAuth);
    await _session.restore();
    if (_session.isSignedIn) {
      final epoch = _session.epoch;
      final owner = await _owner.read();
      if (_session.isCurrent(epoch)) {
        _restoredOwner = owner;
        _restoredEpoch = epoch;
      }
    }
    await _onAuth(_session.status);
  }

  Future<void> _onAuth(AuthStatus status) async {
    switch (status) {
      case AuthStatus.unknown:
        return;
      case AuthStatus.signedOut:
        _poll?.cancel();
        _poll = null;
        _accountId = null;
        _accountEpoch = null;
        // A pass already running would keep writing the old account's rows
        // and cursor after the purge; let it finish first.
        final running = _running;
        if (running != null) await running.catchError((_) {});
        // Signed in again meanwhile: _ensureOwner purges the old account.
        if (_session.isSignedIn) return;
        await _purge();
      case AuthStatus.signedIn:
        _poll ??= Timer.periodic(pollInterval, (_) => requestSync());
        unawaited(requestSync());
    }
  }

  /// Request a sync. Concurrent requests share the running pass, and one more
  /// pass runs afterwards if something was requested meanwhile.
  Future<void> requestSync() {
    if (!_configured || !_session.isSignedIn) return Future.value();
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final future = _loop();
    _running = future;
    return future.whenComplete(() {
      if (identical(_running, future)) _running = null;
    });
  }

  /// App lifecycle hook: foreground → sync now and keep polling; background →
  /// stop the timer.
  void setForeground(bool foreground) {
    if (!foreground) {
      _poll?.cancel();
      _poll = null;
      return;
    }
    if (_session.isSignedIn) {
      _poll ??= Timer.periodic(pollInterval, (_) => requestSync());
      unawaited(requestSync());
    }
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _pass();
    } while (_again && _session.isSignedIn);
  }

  /// Every request of a pass is bound to the session it started in; when that
  /// session ends (sign-out, another account) the pass stops before writing
  /// anything for it.
  Future<void> _pass() {
    final epoch = _session.epoch;
    return _session.bind(epoch, () => _boundPass(epoch));
  }

  Future<void> _boundPass(int epoch) async {
    _emit(CloudSyncPhase.syncing);
    try {
      final accountId = await _ensureOwner(epoch);
      if (accountId == null || !_session.isCurrent(epoch)) {
        _emit(CloudSyncPhase.idle);
        return;
      }
      await _runEngine(accountId, epoch);
      if (!_session.isCurrent(epoch)) {
        _emit(CloudSyncPhase.idle);
        return;
      }
      for (final hook in _afterSync) {
        try {
          await hook();
        } catch (error) {
          await AppLogger.warning(
            'Post-sync step failed: $error',
            operation: 'owlsonic.sync.after',
          );
        }
      }
      _reportedFailureEpoch = null;
      _current = CloudSyncStatus(lastSyncedAt: DateTime.now().toUtc());
      _status.add(_current);
    } on SyncEventRejected catch (rejected) {
      // The page was not applied and the cursor did not move.
      _emit(CloudSyncPhase.failed, code: 'sync_event_rejected');
      _reportPersistentFailure('unsupported');
      await AppLogger.warning(
        'Sync stopped at an unsupported or malformed event',
        operation: 'owlsonic.sync.rejected',
        error:
            'type=${rejected.type} version=${rejected.version} '
            'event_id=${rejected.eventId} reason=${rejected.reason}',
      );
    } on OwlSonicApiException catch (error) {
      if (error.code == OwlSonicApiException.sessionChanged.code) {
        // The session ended mid-pass; nothing more was written for it.
        _emit(CloudSyncPhase.idle);
        return;
      }
      // Offline or server trouble: keep the local library and cursor as is.
      _emit(CloudSyncPhase.failed, code: error.code);
      if (!error.isNetwork && !error.retryable && !error.isUnauthorized) {
        _reportPersistentFailure('server');
      }
      await AppLogger.warning(
        'Sync failed: ${error.code} status=${error.statusCode} '
        'network=${error.isNetwork} (request_id=${error.requestId})',
        operation: 'owlsonic.sync',
      );
    } catch (error, stackTrace) {
      _emit(CloudSyncPhase.failed, code: 'local_apply_failed');
      _reportPersistentFailure('storage');
      await AppLogger.warning(
        'Sync apply failed',
        operation: 'owlsonic.sync.apply',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _runEngine(String accountId, int epoch) async {
    bool current() => _session.isCurrent(epoch);
    final cursors = _SessionGuardedCursors(_cursorsFor(accountId), current);
    final engine = SyncEngine(
      remote: _remote,
      cursors: cursors,
      applier: _SessionGuardedApplier(_local, current),
      pageSize: pageSize,
    );
    if (await cursors.read() == null) _local.beginSnapshot();
    try {
      await engine.run();
    } on OwlSonicApiException catch (error) {
      if (error.code != 'INVALID_SYNC_CURSOR') rethrow;
      // Server says: restart without cursor. Re-bootstrap from scratch.
      await cursors.clear();
      _local.beginSnapshot();
      await engine.run();
    }
  }

  /// Resolves the signed-in account and purges cloud rows that belong to a
  /// different (previous) account before any new data is applied.
  ///
  /// A `/v1/me` answer that arrives after the session changed is discarded:
  /// it never tags the database or a cursor with the previous account.
  Future<String?> _ensureOwner(int epoch) async {
    final known = _accountId;
    if (known != null && _accountEpoch == epoch) return known;
    final me = await _account.me();
    if (!_session.isCurrent(epoch)) return null;
    final stored = await _owner.read();
    if (!_session.isCurrent(epoch)) return null;
    if (stored != null && stored != me.id) {
      await _local.purgeCloudData();
      await _cursorsFor(stored).clear();
      await _runAfterPurge();
      if (!_session.isCurrent(epoch)) return null;
    }
    await _owner.write(me.id);
    if (!_session.isCurrent(epoch)) return null;
    _accountId = me.id;
    _accountEpoch = epoch;
    return me.id;
  }

  Future<void> _runAfterPurge() async {
    for (final hook in _afterPurge) {
      try {
        await hook();
      } catch (error, stackTrace) {
        await AppLogger.warning(
          'Cleanup after cloud purge failed',
          operation: 'owlsonic.sync.purge_cleanup',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Each step runs even when an earlier one fails, so e.g. a database error
  /// never leaves queued plays or cached audio of the signed-out account.
  /// The owner is cleared only once the rows are gone; otherwise the next
  /// sign-in still sees the old owner and purges again.
  Future<void> _purge() async {
    String? stored;
    var purged = false;
    Future<void> step(String name, Future<void> Function() action) async {
      try {
        await action();
      } catch (error, stackTrace) {
        await AppLogger.warning(
          'Could not $name after sign-out',
          operation: 'owlsonic.sync.purge',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    await step(
      'read the cloud owner',
      () async => stored = await _owner.read(),
    );
    await step('purge cloud rows', () async {
      await _local.purgeCloudData();
      purged = true;
    });
    final owner = stored;
    if (owner != null) {
      await step('clear the sync cursor', () => _cursorsFor(owner).clear());
    }
    if (purged) await step('clear the cloud owner', () => _owner.write(null));
    await _runAfterPurge();
  }

  void _reportPersistentFailure(String category) {
    final epoch = _session.epoch;
    if (_reportedFailureEpoch == epoch || !_session.isSignedIn) return;
    _reportedFailureEpoch = epoch;
    unawaited(
      _analytics.logEvent(
        'sync_failed',
        properties: {'error_category': category},
      ),
    );
  }

  void _emit(CloudSyncPhase phase, {String? code}) {
    _current = CloudSyncStatus(
      phase: phase,
      lastSyncedAt: _current.lastSyncedAt,
      lastErrorCode: code,
    );
    if (!_status.isClosed) _status.add(_current);
  }

  Future<void> dispose() async {
    _poll?.cancel();
    await _authSubscription?.cancel();
    await _status.close();
  }
}

/// Refuses to move the cursor once the session that pulled the page ended.
class _SessionGuardedCursors implements SyncCursorStore {
  _SessionGuardedCursors(this._inner, this._current);
  final SyncCursorStore _inner;
  final bool Function() _current;

  @override
  Future<String?> read() => _inner.read();
  @override
  Future<void> write(String cursor) {
    if (!_current()) throw OwlSonicApiException.sessionChanged;
    return _inner.write(cursor);
  }

  @override
  Future<void> clear() {
    if (!_current()) throw OwlSonicApiException.sessionChanged;
    return _inner.clear();
  }
}

/// Refuses to apply a page pulled for a session that ended meanwhile.
class _SessionGuardedApplier implements SyncEventApplier {
  _SessionGuardedApplier(this._inner, this._current);
  final SyncEventApplier _inner;
  final bool Function() _current;

  @override
  Future<void> apply(SyncPage page) {
    if (!_current()) throw OwlSonicApiException.sessionChanged;
    return _inner.apply(page);
  }
}
