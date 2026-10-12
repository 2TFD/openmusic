import 'dart:async';

import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/core/services/cloud/cloud_playlist_sync.dart';
import 'package:owlsonic/core/services/cloud/local_library_migration.dart';
import 'package:owlsonic/core/utils/app_logger.dart';

/// Sends the whole local library to OwlSonic while the setting is on: first
/// the tracks, then the playlists (which need the tracks to exist there).
///
/// It runs after every sync (sign-in, app start, resume, the foreground
/// timer), when the setting changes, and when the connection becomes allowed
/// (Wi-Fi only). Passes never overlap; a request during a pass schedules one
/// more.
class AutoSyncService {
  AutoSyncService({
    required AuthSession session,
    required AutoSyncPolicy policy,
    required LocalLibraryMigration tracks,
    required CloudPlaylistSync playlists,
    required bool configured,
  }) : _session = session,
       _policy = policy,
       _tracks = tracks,
       _playlists = playlists,
       _configured = configured;

  final AuthSession _session;
  final AutoSyncPolicy _policy;
  final LocalLibraryMigration _tracks;
  final CloudPlaylistSync _playlists;
  final bool _configured;

  Future<void>? _running;
  bool _again = false;
  AutoSyncPrefs? _lastPrefs;
  StreamSubscription<void>? _network;

  /// Starts reacting to setting and connection changes.
  void start() {
    if (!_configured || _network != null) return;
    _lastPrefs = _policy.prefs;
    _policy.settings.current.addListener(_onPrefs);
    _network = _policy.networkChanges.listen((_) => unawaited(run()));
  }

  void _onPrefs() {
    final next = _policy.prefs;
    final previous = _lastPrefs;
    _lastPrefs = next;
    // Turning sync on, or allowing mobile data, can only add work.
    if (next.enabled && (previous == null || previous != next)) {
      unawaited(run());
    }
  }

  Future<void> run() {
    if (!_configured || !_session.isSignedIn) return Future.value();
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    final pass = _loop().whenComplete(() => _running = null);
    _running = pass;
    return pass;
  }

  Future<void> _loop() async {
    do {
      _again = false;
      try {
        if (!_session.isSignedIn || !await _policy.allowsUploadNow()) return;
        await _tracks.uploadWaiting();
        await _playlists.reconcile();
      } catch (error, stackTrace) {
        // Offline or server trouble: the next sync tries again.
        await AppLogger.warning(
          'Auto-sync pass stopped.',
          operation: 'owlsonic.auto_sync',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
    } while (_again);
  }

  /// "Sync" on one song of a playlist: uploads it, then adds it to the server
  /// playlists that were waiting for it. Works with auto-sync switched off.
  Future<void> syncTrack(String trackId) async {
    if (!_configured || !_session.isSignedIn) return;
    await _tracks.uploadNow(trackId);
    try {
      await _playlists.addUploadedTracks();
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Could not add the synced song to its playlists.',
        operation: 'owlsonic.auto_sync.track',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> dispose() async {
    _policy.settings.current.removeListener(_onPrefs);
    await _network?.cancel();
  }
}
