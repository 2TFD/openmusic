import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/data/repositories/cloud_aware_repositories.dart'
    show isUuidV7;
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:uuid/uuid.dart';

/// Sends playlists to OwlSonic and keeps them complete.
///
/// - A playlist that exists only on this device becomes a cloud playlist (same
///   id) holding the songs that are already in the cloud library.
/// - Songs that are not in the cloud library stay in the playlist on this
///   device, marked "not synced", and are added to the server playlist as soon
///   as they are uploaded.
///
/// Safe to run repeatedly: every step only adds what the server is missing,
/// so an interrupted pass is finished by the next one.
class CloudPlaylistSync {
  CloudPlaylistSync({
    required CloudLocalStore store,
    required CloudPlaylistRepository remote,
    String Function()? newItemId,
  }) : _store = store,
       _remote = remote,
       _newItemId = newItemId ?? (() => const Uuid().v7());

  final CloudLocalStore _store;
  final CloudPlaylistRepository _remote;
  final String Function() _newItemId;

  Future<void> reconcile() async {
    await _promoteLocalPlaylists();
    await addUploadedTracks();
  }

  Future<void> _promoteLocalPlaylists() async {
    for (final playlist in await _store.localOnlyPlaylists()) {
      // The backend only accepts UUIDv7 ids; older playlists keep the device.
      if (!isUuidV7(playlist.id)) continue;
      try {
        final cloudTracks = await _store.cloudTrackIdsAmong(playlist.trackIds);
        final detail = await _existingOrCreate(playlist.id, playlist.name);
        final onServer = {for (final item in detail.items) item.trackId};
        for (final trackId in playlist.trackIds) {
          if (!cloudTracks.contains(trackId) || onServer.contains(trackId)) {
            continue;
          }
          await _remote.addItem(
            playlist.id,
            itemId: _newItemId(),
            trackId: trackId,
          );
        }
        await _store.applyPlaylistDetail(await _remote.get(playlist.id));
      } on OwlSonicApiException catch (error) {
        if (error.isNetwork || error.isUnauthorized) rethrow;
        await _log('promote ${playlist.id}', error);
      }
    }
  }

  /// Adds songs that reached the cloud library since they were put into a
  /// cloud playlist.
  Future<void> addUploadedTracks() async {
    final waiting = await _store.cloudPlaylistsAwaitingTracks();
    for (final entry in waiting.entries) {
      try {
        for (final trackId in entry.value) {
          await _remote.addItem(
            entry.key,
            itemId: _newItemId(),
            trackId: trackId,
          );
        }
        await _store.applyPlaylistDetail(await _remote.get(entry.key));
      } on OwlSonicApiException catch (error) {
        if (error.isNetwork || error.isUnauthorized) rethrow;
        await _log('add songs to ${entry.key}', error);
      }
    }
  }

  /// A retry after an interrupted promotion finds the playlist already there.
  Future<CloudPlaylist> _existingOrCreate(String id, String name) async {
    try {
      return await _remote.get(id);
    } on OwlSonicApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      return _remote.create(id: id, name: name);
    }
  }

  Future<void> _log(String what, Object error) => AppLogger.warning(
    'Playlist sync: could not $what.',
    operation: 'owlsonic.playlist_sync',
    error: error,
  );
}
