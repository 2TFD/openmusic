import 'dart:async';

import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/cloud/play_event_queue.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/listening_summary.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/domain/repositories/listening_summary_repository.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';
import 'package:owlsonic/layers/domain/repositories/playlist_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_removal_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:uuid/uuid.dart';

/// Client-generated ids sent to OwlSonic (tracks, playlists, playlist items,
/// play events) must be UUIDv7; the deployed backend rejects other versions.
bool isUuidV7(String value) => RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
).hasMatch(value);

/// Shared wiring of the cloud-aware decorators below: cloud entities are
/// mutated through the backend first, then the response is applied to the
/// local database (the same idempotent paths sync uses), then a sync is
/// requested so every device converges. Local-only entities keep their
/// existing local behaviour.
class CloudMutationContext {
  const CloudMutationContext({
    required this.store,
    required this.isEnabled,
    required this.requestSync,
    this.autoSyncEnabled = _always,
  });

  static bool _always() => true;

  final CloudLocalStore store;

  /// The "auto-sync" setting: new playlists start in the cloud only when on.
  /// Existing cloud playlists keep working either way.
  final bool Function() autoSyncEnabled;

  /// Signed in to a configured backend.
  final bool Function() isEnabled;
  final void Function() requestSync;

  AppDatabase get db => store.db;

  Future<bool> isCloudTrack(String trackId) async {
    final row = await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(trackId))).getSingleOrNull();
    return row?.sourceType == SourceType.owlsonic.name;
  }

  Future<CloudLibraryItemTableData?> cloudItem(String trackId) => (db.select(
    db.cloudLibraryItemTable,
  )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
}

class CloudAwarePlaylistRepository implements PlaylistRepository {
  CloudAwarePlaylistRepository({
    required PlaylistRepository local,
    required CloudPlaylistRepository remote,
    required CloudMutationContext cloud,
    String Function()? newItemId,
  }) : _local = local,
       _remote = remote,
       _cloud = cloud,
       _newItemId = newItemId ?? (() => const Uuid().v7());

  final PlaylistRepository _local;
  final CloudPlaylistRepository _remote;
  final CloudMutationContext _cloud;
  final String Function() _newItemId;

  Future<bool> _isCloud(String playlistId) =>
      _cloud.store.isCloudPlaylist(playlistId);

  Future<void> _requireSession() async {
    if (!_cloud.isEnabled()) {
      throw const ValidationFailure('cloud.signedOut');
    }
  }

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    if (!_cloud.isEnabled() || !_cloud.autoSyncEnabled()) {
      return _local.createPlaylist(playlist);
    }
    // Validate BEFORE any remote mutation: the backend only accepts tracks of
    // the user's cloud library. A playlist holding local-only music stays
    // device-local, so no partial remote playlist can ever be created.
    for (final trackId in playlist.trackIds) {
      if (!await _cloud.isCloudTrack(trackId)) {
        // Stays on this device for now; the auto-sync pass promotes it to
        // OwlSonic (without the songs that are not uploaded yet).
        await _local.createPlaylist(playlist);
        _cloud.requestSync();
        return;
      }
    }
    final created = await _remote.create(id: playlist.id, name: playlist.name);
    try {
      await _cloud.store.applyPlaylistDetail(created);
      if (playlist.description != null || playlist.imageUrl != null) {
        // Description/cover are device-local presentation fields.
        final stored = await _local.getPlaylistById(playlist.id);
        if (stored != null) {
          await _local.updateMetadata(
            stored.copyWith(
              description: playlist.description,
              imageUrl: playlist.imageUrl,
            ),
          );
        }
      }
      for (final trackId in playlist.trackIds) {
        await addTrackToPlaylist(playlist.id, trackId);
      }
    } catch (_) {
      // Do not leave a half-built playlist behind (e.g. network drop midway).
      await _rollbackCreate(playlist.id);
      rethrow;
    }
    _cloud.requestSync();
  }

  Future<void> _rollbackCreate(String playlistId) async {
    try {
      await _remote.delete(playlistId);
      await _cloud.store.deletePlaylist(playlistId);
    } catch (_) {
      // Best effort; the next sync reconciles whatever the backend holds.
      _cloud.requestSync();
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    if (!await _isCloud(playlistId)) return _local.deletePlaylist(playlistId);
    await _requireSession();
    await _remote.delete(playlistId);
    await _cloud.store.deletePlaylist(playlistId);
    _cloud.requestSync();
  }

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    if (!await _isCloud(playlistId)) {
      return _local.addTrackToPlaylist(playlistId, trackId);
    }
    if (!await _cloud.isCloudTrack(trackId)) {
      // The backend only accepts tracks of the user's cloud library. The song
      // is shown here, marked "not synced", and joins the server playlist
      // once it is uploaded.
      await _local.addTrackToPlaylist(playlistId, trackId);
      _cloud.requestSync();
      return;
    }
    await _requireSession();
    await _remote.addItem(playlistId, itemId: _newItemId(), trackId: trackId);
    await _cloud.store.applyPlaylistDetail(await _remote.get(playlistId));
    _cloud.requestSync();
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  }) async {
    if (!await _isCloud(playlistId)) {
      return _local.removeTrackFromPlaylist(
        playlistId,
        trackId,
        expectedRevision: expectedRevision,
      );
    }
    final items = await _cloud.store.playlistItems(playlistId);
    final onServer = items.where((item) => item.trackId == trackId).toList();
    if (onServer.isEmpty) {
      // Only on this device so far (not synced yet): nothing to tell the server.
      return _local.removeTrackFromPlaylist(
        playlistId,
        trackId,
        expectedRevision: expectedRevision,
      );
    }
    await _requireSession();
    for (final item in onServer) {
      await _remote.removeItem(playlistId, item.itemId);
    }
    await _cloud.store.applyPlaylistDetail(await _remote.get(playlistId));
    _cloud.requestSync();
  }

  @override
  Future<void> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  }) async {
    if (!await _isCloud(playlistId)) {
      return _local.reorderTracks(
        playlistId,
        trackIds,
        expectedRevision: expectedRevision,
      );
    }
    await _requireSession();
    final current = await _local.getPlaylistById(playlistId);
    if (current == null) throw NotFoundFailure('playlist', playlistId);
    if (current.revision != expectedRevision) {
      throw ConflictFailure('playlist', playlistId);
    }
    final items = await _cloud.store.playlistItems(playlistId);
    final byTrack = <String, List<String>>{};
    for (final item in items) {
      byTrack.putIfAbsent(item.trackId, () => []).add(item.itemId);
    }
    // Every backend item must be listed; duplicates of a track stay together.
    final itemIds = [
      for (final trackId in trackIds) ...?byTrack.remove(trackId),
      for (final rest in byTrack.values) ...rest,
    ];
    await _cloud.store.applyPlaylistDetail(
      await _remote.reorder(playlistId, itemIds),
    );
    _cloud.requestSync();
  }

  @override
  Future<void> updateMetadata(Playlist playlist) async {
    if (!await _isCloud(playlist.id)) return _local.updateMetadata(playlist);
    final current = await _local.getPlaylistById(playlist.id);
    if (current != null && current.name != playlist.name) {
      await _requireSession();
      await _cloud.store.applyPlaylistDetail(
        await _remote.rename(playlist.id, playlist.name),
      );
      _cloud.requestSync();
    }
    // Description / cover remain device-local fields.
    final refreshed = await _local.getPlaylistById(playlist.id);
    if (refreshed != null &&
        (refreshed.description != playlist.description ||
            refreshed.imageUrl != playlist.imageUrl)) {
      await _local.updateMetadata(
        refreshed.copyWith(
          description: playlist.description,
          imageUrl: playlist.imageUrl,
          clearDescription: playlist.description == null,
          clearImageUrl: playlist.imageUrl == null,
        ),
      );
    }
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async =>
      _withUnsynced(await _local.getPlaylistById(id));

  @override
  Stream<List<PlaylistSummary>> watchPlaylistSummaries() =>
      _local.watchPlaylistSummaries();

  @override
  Stream<Playlist?> watchPlaylistById(String id) =>
      _local.watchPlaylistById(id).asyncMap(_withUnsynced);

  Future<Playlist?> _withUnsynced(Playlist? playlist) async {
    if (playlist == null) return null;
    final unsynced = await _cloud.store.unsyncedPlaylistTracks(playlist.id);
    return unsynced.isEmpty
        ? playlist
        : playlist.copyWith(unsyncedTrackIds: unsynced.toSet());
  }
}

/// Cloud tracks are removed from the OwlSonic library (`DELETE
/// /v1/library/{id}`) and then locally, without touching any file: their
/// local path may be the user's own original file.
class CloudAwareTrackRemovalRepository implements TrackRemovalRepository {
  CloudAwareTrackRemovalRepository({
    required TrackRemovalRepository local,
    required CloudLibraryRepository remote,
    required CloudMutationContext cloud,
  }) : _local = local,
       _remote = remote,
       _cloud = cloud;

  final TrackRemovalRepository _local;
  final CloudLibraryRepository _remote;
  final CloudMutationContext _cloud;

  @override
  Future<void> removeTrack(String trackId) async {
    if (!await _cloud.isCloudTrack(trackId)) {
      return _local.removeTrack(trackId);
    }
    if (!_cloud.isEnabled()) {
      throw const ValidationFailure('cloud.signedOut');
    }
    await _remote.delete(trackId);
    await _cloud.store.deleteLibraryItem(trackId);
    _cloud.requestSync();
  }

  @override
  Future<void> cleanupPending() => _local.cleanupPending();
}

/// Metadata edits of cloud tracks become personal overrides
/// (`custom_title` / `custom_artist_name` / `custom_album_title`); canonical
/// metadata is never changed. Editing a field back to canonical clears it.
class CloudAwareTrackRepository implements TrackRepository {
  CloudAwareTrackRepository({
    required TrackRepository local,
    required CloudLibraryRepository remote,
    required CloudMutationContext cloud,
  }) : _local = local,
       _remote = remote,
       _cloud = cloud;

  final TrackRepository _local;
  final CloudLibraryRepository _remote;
  final CloudMutationContext _cloud;

  @override
  Future<void> updateMetadata(Track track) async {
    if (!track.isCloudTrack) return _local.updateMetadata(track);
    final item = await _cloud.cloudItem(track.id);
    if (item == null) throw NotFoundFailure('track', track.id);
    if (!_cloud.isEnabled()) {
      throw const ValidationFailure('cloud.signedOut');
    }
    PatchValue<String> override(String? edited, String? canonical) {
      final value = edited?.trim();
      return value == null || value.isEmpty || value == canonical
          ? const PatchValue.clear()
          : PatchValue.set(value);
    }

    final patch = LibraryItemPatch(
      customTitle: override(track.title, item.canonicalTitle),
      customArtistName: override(
        track.artists.map((artist) => artist.name).join(', '),
        item.canonicalArtistName,
      ),
      customAlbumTitle: override(track.album, item.canonicalAlbumTitle),
    );
    final updated = await _remote.patch(track.id, patch);
    await _cloud.store.upsertLibraryItem(updated);
    _cloud.requestSync();
  }

  @override
  Future<List<Track>> getTracks() => _local.getTracks();
  @override
  Future<Track?> getTrackById(String id) => _local.getTrackById(id);
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) =>
      _local.getTracksByIds(ids);
  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) => _local.searchTracks(query, limit: limit, offset: offset);
  @override
  Stream<void> watchChanges() => _local.watchChanges();
}

/// Mood Map position edits of cloud tracks are PERSONAL overrides
/// (`custom_valence` / `custom_arousal`). Canonical analysis is untouched.
class CloudAwareMoodMapRepository implements MoodMapRepository {
  CloudAwareMoodMapRepository({
    required MoodMapRepository local,
    required CloudLibraryRepository remote,
    required CloudMutationContext cloud,
  }) : _local = local,
       _remote = remote,
       _cloud = cloud;

  final MoodMapRepository _local;
  final CloudLibraryRepository _remote;
  final CloudMutationContext _cloud;

  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {
    if (!await _cloud.isCloudTrack(adjustment.trackId)) {
      return _local.savePersonalPosition(adjustment);
    }
    await _patch(
      adjustment.trackId,
      LibraryItemPatch(
        customValence: PatchValue.set(adjustment.valence),
        customArousal: PatchValue.set(adjustment.arousal),
      ),
    );
  }

  @override
  Future<void> resetPersonalPosition(String trackId) async {
    if (!await _cloud.isCloudTrack(trackId)) {
      return _local.resetPersonalPosition(trackId);
    }
    await _patch(
      trackId,
      const LibraryItemPatch(
        customValence: PatchValue.clear(),
        customArousal: PatchValue.clear(),
      ),
    );
  }

  Future<void> _patch(String trackId, LibraryItemPatch patch) async {
    if (!_cloud.isEnabled()) {
      throw const ValidationFailure('cloud.signedOut');
    }
    await _cloud.store.upsertLibraryItem(await _remote.patch(trackId, patch));
    _cloud.requestSync();
  }

  @override
  Future<List<MoodMapTrack>> loadTracks() => _local.loadTracks();
  @override
  Stream<void> watchChanges() => _local.watchChanges();
}

/// Plays of cloud tracks are also queued for `POST /v1/history/events` with
/// the SAME id as the local history row, so the `history.append` echo from
/// sync is recognised (insert-or-ignore by id) and never double-counted.
class CloudAwareListeningSummaryRepository
    implements ListeningSummaryRepository {
  CloudAwareListeningSummaryRepository({
    required ListeningSummaryRepository local,
    required PlayEventQueue queue,
    required bool Function() isEnabled,
  }) : _local = local,
       _queue = queue,
       _isEnabled = isEnabled;

  final ListeningSummaryRepository _local;
  final PlayEventQueue _queue;
  final bool Function() _isEnabled;

  @override
  Future<void> save(ListeningSummary record) async {
    await _local.save(record);
    if (record.sourceType != SourceType.owlsonic || !_isEnabled()) return;
    // The backend accepts only UUIDv7 play ids; a pre-upgrade v4 id would be
    // rejected (422) and silently dropped, so it is not queued at all.
    if (!isUuidV7(record.id)) return;
    await _queue.record(
      id: record.id,
      trackId: record.trackId,
      playedAt: record.playedAt,
      listened: record.listenedDuration,
    );
    unawaited(_queue.flush().catchError((_) => 0));
  }

  @override
  Future<ListeningStatsSummary> aggregate({required DateTime from}) =>
      _local.aggregate(from: from);
  @override
  Future<List<String>> getRecentTrackIds({int limit = 20}) =>
      _local.getRecentTrackIds(limit: limit);
  @override
  Future<void> clear() => _local.clear();
  @override
  Stream<void> watchChanges() => _local.watchChanges();
}
