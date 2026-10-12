import 'dart:async';
import 'dart:convert';

import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract interface class PlayEventStore {
  Future<List<PlayEvent>> load();
  Future<void> save(List<PlayEvent> events);
}

class SharedPreferencesPlayEventStore implements PlayEventStore {
  SharedPreferencesPlayEventStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'owlsonic.pending_play_events.v1';
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<List<PlayEvent>> load() async {
    final raw = await _instance.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((item) => PlayEvent.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<PlayEvent> events) => _instance.setString(
    key,
    jsonEncode([for (final event in events) event.toStoredJson()]),
  );
}

/// Durable outbox for `POST /v1/history/events`.
///
/// The event UUID is generated once at [record] time and persisted, so every
/// retry re-sends the same id and the backend can de-duplicate.
///
/// Account isolation (when [session] and [accountId] are given): each event is
/// tagged with the account it was recorded under, a flush sends only the
/// current account's events, and every submit is bound to the session the
/// flush started in, so a flush racing with sign-out or an account switch is
/// never sent with the next account's token. Events of another account stay
/// queued until the sign-out purge clears them.
class PlayEventQueue {
  PlayEventQueue({
    required PlayEventStore store,
    required CloudHistoryRepository history,
    String Function()? newId,
    this.batchSize = 100,
    AuthSession? session,
    String? Function()? accountId,
  }) : _store = store,
       _history = history,
       _session = session,
       _accountId = accountId,
       // The backend requires UUIDv7 event ids.
       _newId = newId ?? (() => const Uuid().v7());

  final PlayEventStore _store;
  final CloudHistoryRepository _history;
  final AuthSession? _session;
  final String? Function()? _accountId;
  final String Function() _newId;
  final int batchSize;

  /// Session epoch of events recorded untagged in this process. Untagged
  /// events of another session are never sent.
  final _untaggedEpochs = <String, int>{};
  Future<void> _lock = Future.value();
  Future<int>? _flushing;

  Future<T> _locked<T>(Future<T> Function() action) {
    final result = _lock.then((_) => action());
    _lock = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// [id] lets the caller reuse its own play id (e.g. the local history row),
  /// so the server echo is recognised as the same play.
  Future<PlayEvent> record({
    String? id,
    required String trackId,
    required DateTime playedAt,
    required Duration listened,
  }) => _locked(() async {
    final queued = await _store.load();
    if (id != null) {
      final existing = queued.where((event) => event.id == id).firstOrNull;
      if (existing != null) return existing;
    }
    final event = PlayEvent(
      id: id ?? _newId(),
      trackId: trackId,
      playedAt: playedAt.toUtc(),
      listenedMs: listened.inMilliseconds.clamp(0, 86400000),
      accountId: _accountId?.call(),
    );
    final session = _session;
    if (event.accountId == null && session != null) {
      _untaggedEpochs[event.id] = session.epoch;
    }
    await _store.save([...queued, event]);
    return event;
  });

  Future<List<PlayEvent>> pending() => _locked(_store.load);

  /// Drops every queued event: after sign-out they belong to an account that
  /// is no longer signed in and must not be sent under the next one.
  Future<void> clear() => _locked(() async {
    _untaggedEpochs.clear();
    await _store.save(const []);
  });

  /// Uploads queued events. Returns the number removed from the queue.
  /// Network/retryable failures leave events queued for a later attempt.
  Future<int> flush() => _flushing ??= _flush().whenComplete(() {
    _flushing = null;
  });

  Future<int> _flush() async {
    final session = _session;
    final epoch = session?.epoch;
    final account = _accountId == null ? null : _accountId();
    if (_accountId != null && account == null) return 0;
    bool ours(PlayEvent event) {
      if (_accountId == null) return true;
      if (event.accountId != null) return event.accountId == account;
      final recordedIn = _untaggedEpochs[event.id];
      return recordedIn == null || recordedIn == epoch;
    }

    var removed = 0;
    final attempted = <String>{};
    while (true) {
      if (session != null && !session.isCurrent(epoch!)) return removed;
      final batch = (await pending())
          .where((event) => ours(event) && !attempted.contains(event.id))
          .take(batchSize)
          .toList();
      if (batch.isEmpty) return removed;
      attempted.addAll(batch.map((event) => event.id));
      final delivered = session == null
          ? await _deliver(batch)
          : await session.bind(epoch!, () => _deliver(batch));
      if (delivered.isEmpty) return removed;
      await _locked(() async {
        final remaining = (await _store.load())
            .where((event) => !delivered.contains(event.id))
            .toList();
        await _store.save(remaining);
        delivered.forEach(_untaggedEpochs.remove);
      });
      removed += delivered.length;
      if (delivered.length < batch.length) return removed;
    }
  }

  /// Returns ids that may leave the queue: accepted, duplicates, or
  /// permanently rejected individually by the server.
  Future<Set<String>> _deliver(List<PlayEvent> batch) async {
    try {
      await _history.submit(batch);
      return {for (final event in batch) event.id};
    } on OwlSonicApiException catch (error) {
      if (_keep(error)) return const {};
      if (batch.length == 1) {
        await AppLogger.warning(
          'Dropping play event rejected by server: ${error.code} '
          '(request_id=${error.requestId})',
          operation: 'owlsonic.history.flush',
        );
        return {batch.single.id};
      }
      // Isolate the offending event(s) so one bad event cannot block history.
      final result = <String>{};
      for (final event in batch) {
        final delivered = await _deliver([event]);
        if (delivered.isEmpty) return result;
        result.addAll(delivered);
      }
      return result;
    }
  }

  /// Only a 4xx about the payload itself drops an event. Server faults (5xx),
  /// rate limits, undecodable responses and network trouble keep it queued.
  static bool _keep(OwlSonicApiException error) {
    final status = error.statusCode;
    return error.retryable ||
        error.isUnauthorized ||
        error.kind != OwlSonicApiErrorKind.server ||
        status == null ||
        status == 429 ||
        status >= 500;
  }
}
