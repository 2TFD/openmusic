import 'dart:async';

import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SyncCursorStore {
  Future<String?> read();
  Future<void> write(String cursor);
  Future<void> clear();
}

/// Cursor of one account: the key embeds the account id, so another user's
/// cursor is never reused.
class SharedPreferencesSyncCursorStore implements SyncCursorStore {
  SharedPreferencesSyncCursorStore({
    required String accountId,
    SharedPreferencesAsync? preferences,
  }) : key = 'owlsonic.sync_cursor.v1.$accountId',
       _preferences = preferences;

  final String key;
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> read() => _instance.getString(key);
  @override
  Future<void> write(String cursor) => _instance.setString(key, cursor);
  @override
  Future<void> clear() => _instance.remove(key);
}

/// Applies one sync page to the local database. Implementations MUST be
/// transactional (all events of the page or none) and idempotent (replaying an
/// already-applied page is a no-op).
abstract interface class SyncEventApplier {
  Future<void> apply(SyncPage page);
}

class SyncRunResult {
  const SyncRunResult({required this.pages, required this.events});
  final int pages;
  final int events;
}

/// Pulls `GET /v1/sync` pages: bootstrap without cursor, delta with cursor.
/// The cursor advances only after a page was applied, so an interrupted run
/// resumes from the last fully applied page.
class SyncEngine {
  SyncEngine({
    required CloudSyncRepository remote,
    required SyncCursorStore cursors,
    required SyncEventApplier applier,
    this.pageSize,
  }) : _remote = remote,
       _cursors = cursors,
       _applier = applier;

  final CloudSyncRepository _remote;
  final SyncCursorStore _cursors;
  final SyncEventApplier _applier;
  final int? pageSize;
  Future<SyncRunResult>? _running;

  Future<SyncRunResult> run() => _running ??= _run().whenComplete(() {
    _running = null;
  });

  Future<SyncRunResult> _run() async {
    var cursor = await _cursors.read();
    var pages = 0;
    var events = 0;
    while (true) {
      final page = await _remote.pull(cursor: cursor, limit: pageSize);
      await _applier.apply(page);
      await _cursors.write(page.nextCursor);
      pages++;
      events += page.events.length;
      if (!page.hasMore || page.nextCursor == cursor) {
        return SyncRunResult(pages: pages, events: events);
      }
      cursor = page.nextCursor;
    }
  }

  /// Forget sync position, e.g. after sign-out or account switch.
  Future<void> reset() => _cursors.clear();
}
