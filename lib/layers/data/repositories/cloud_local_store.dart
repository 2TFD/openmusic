import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/remote/owlsonic/owlsonic_sync_parser.dart';
import 'package:owlsonic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_sync_events.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_embedding.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';

/// Pipeline identifiers of synced canonical analysis in the shared
/// embedding/emotion tables.
class CloudAnalysisPipeline {
  const CloudAnalysisPipeline._();
  static const preprocessingVersion = 'owlsonic-cloud-v1';
  static const emotionModelId = 'owlsonic-cloud-emotion';
  static const emotionRepresentation = 'audio.emotion.global';
}

/// Pseudo image URL for a cloud track whose artwork lives on the backend. It is
/// resolved to a short-lived signed URL at display time and never stores one.
const cloudArtworkScheme = 'owlsonic-artwork';
String cloudArtworkUri(String trackId) => '$cloudArtworkScheme:$trackId';
String? cloudArtworkTrackId(String? imageUrl) {
  if (imageUrl == null || !imageUrl.startsWith('$cloudArtworkScheme:')) {
    return null;
  }
  return imageUrl.substring(cloudArtworkScheme.length + 1);
}

/// Writes OwlSonic cloud state into the local database. Every apply is
/// idempotent; sync pages are applied in one transaction.
class CloudLocalStore implements SyncEventApplier {
  CloudLocalStore(
    this.db, {
    OwlSonicSyncParser parser = const OwlSonicSyncParser(),
    DateTime Function()? now,
  }) : _parser = parser,
       _now = now ?? (() => DateTime.now().toUtc());

  final AppDatabase db;
  final OwlSonicSyncParser _parser;
  final DateTime Function() _now;

  static final _sourceType = SourceType.owlsonic.name;

  // ── Sync ─────────────────────────────────────────────────────────────────

  /// Parses the whole page first: one unknown or malformed event rejects the
  /// page before anything is written, so the cursor stays where it was.
  @override
  Future<void> apply(SyncPage page) async {
    final List<CloudSyncEvent> events;
    try {
      events = [for (final raw in page.events) _parser.parse(raw)];
    } on SyncEventRejected catch (rejected) {
      await AppLogger.warning(
        'Sync page rejected: ${rejected.reason}',
        operation: 'owlsonic.sync.parse',
        error:
            'type=${rejected.type} version=${rejected.version} '
            'event_id=${rejected.eventId}',
      );
      rethrow;
    }
    final sweep = _snapshotSeen;
    await db.transaction(() async {
      for (final event in events) {
        await applyEvent(event);
        if (sweep != null && page.mode == SyncMode.snapshot) {
          switch (event) {
            case LibraryUpsertSyncEvent(:final item):
              sweep.tracks.add(item.id);
            case PlaylistUpsertSyncEvent(:final playlistId):
              sweep.playlists.add(playlistId);
            default:
              break;
          }
        }
      }
      if (sweep != null && page.mode == SyncMode.snapshot && !page.hasMore) {
        await _sweepAfterSnapshot(sweep);
      }
    });
    if (page.mode != SyncMode.snapshot || !page.hasMore) _snapshotSeen = null;
  }

  _SnapshotSeen? _snapshotSeen;

  /// Called before a bootstrap that starts from its first page (no cursor).
  /// Cloud rows absent from the complete snapshot are then removed. A
  /// snapshot resumed mid-way never sweeps, since earlier pages are unknown.
  void beginSnapshot() => _snapshotSeen = _SnapshotSeen();

  /// Seen ids are matched in Dart and stale ids deleted in chunks: binding a
  /// whole library as SQL variables exceeds SQLite's variable limit.
  Future<void> _sweepAfterSnapshot(_SnapshotSeen seen) async {
    final stale =
        (await (db.selectOnly(db.trackTable)
                  ..addColumns([db.trackTable.id])
                  ..where(db.trackTable.sourceType.equals(_sourceType)))
                .get())
            .map((row) => row.read(db.trackTable.id)!)
            .where((id) => !seen.tracks.contains(id))
            .toList();
    for (final chunk in _chunks(stale)) {
      await _deleteTrackRows(chunk);
    }
    final playlists = (await db.select(db.cloudPlaylistTable).get())
        .map((p) => p.playlistId)
        .where((id) => !seen.playlists.contains(id))
        .toList();
    for (final chunk in _chunks(playlists)) {
      await (db.delete(db.playlistTable)..where((t) => t.id.isIn(chunk))).go();
    }
  }

  static Iterable<List<String>> _chunks(List<String> ids) sync* {
    const size = 200;
    for (var start = 0; start < ids.length; start += size) {
      yield ids.sublist(start, math.min(start + size, ids.length));
    }
  }

  Future<void> applyEvent(CloudSyncEvent event) => switch (event) {
    LibraryUpsertSyncEvent(:final item, :final hasPersonalState) =>
      upsertLibraryItem(item, hasPersonalState: hasPersonalState),
    LibraryDeleteSyncEvent(:final trackId) => deleteLibraryItem(trackId),
    AnalysisUpsertSyncEvent(:final trackId, :final analysis) => _applyAnalysis(
      trackId,
      analysis,
    ),
    PlaylistUpsertSyncEvent() => _upsertPlaylist(
      event.playlistId,
      name: event.name,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    ),
    PlaylistDeleteSyncEvent(:final playlistId) => deletePlaylist(playlistId),
    PlaylistItemsSyncEvent(:final playlistId, :final items) =>
      replacePlaylistItems(playlistId, items),
    HistoryAppendSyncEvent() => _appendHistory(event),
  };

  // ── Library ──────────────────────────────────────────────────────────────

  Future<void> upsertLibraryItem(
    CloudLibraryItem item, {
    bool hasPersonalState = true,
  }) => db.transaction(() async {
    final trackId = item.id;
    final existingTrack = await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(trackId))).getSingleOrNull();
    final existingCloud = await _cloudRow(trackId);

    final title = item.customTitle ?? item.title;
    final artist = item.customArtistName ?? item.artistName;
    final album = item.customAlbumTitle ?? item.albumTitle;

    if (existingTrack == null) {
      await db
          .into(db.trackTable)
          .insert(
            TrackTableCompanion.insert(
              id: trackId,
              title: title,
              sourceType: _sourceType,
              sourceUri: 'owlsonic:track/$trackId',
              durationMs: Value(item.duration.inMilliseconds),
              addedAt: Value(item.addedAt),
              album: Value(album),
              imageUrl: Value(
                item.hasArtwork ? cloudArtworkUri(trackId) : null,
              ),
            ),
          );
    } else {
      final changed =
          existingTrack.title != title ||
          existingTrack.album != album ||
          existingTrack.durationMs != item.duration.inMilliseconds;
      final keepsLocalArtwork =
          existingTrack.imageUrl != null &&
          cloudArtworkTrackId(existingTrack.imageUrl) == null;
      await (db.update(
        db.trackTable,
      )..where((t) => t.id.equals(trackId))).write(
        TrackTableCompanion(
          title: Value(title),
          album: Value(album),
          durationMs: Value(item.duration.inMilliseconds),
          sourceType: Value(_sourceType),
          addedAt: Value(item.addedAt),
          imageUrl: keepsLocalArtwork
              ? const Value.absent()
              : Value(item.hasArtwork ? cloudArtworkUri(trackId) : null),
          metadataRevision: changed
              ? Value(existingTrack.metadataRevision + 1)
              : const Value.absent(),
        ),
      );
    }
    await _replaceArtists(trackId, artist);

    final keepPersonal = !hasPersonalState && existingCloud != null;
    await db
        .into(db.cloudLibraryItemTable)
        .insertOnConflictUpdate(
          CloudLibraryItemTableCompanion.insert(
            trackId: trackId,
            canonicalTitle: item.title,
            canonicalArtistName: Value(item.artistName),
            canonicalAlbumTitle: Value(item.albumTitle),
            albumArtist: Value(item.albumArtist),
            trackNumber: Value(item.trackNumber),
            discNumber: Value(item.discNumber),
            year: Value(item.year),
            genresJson: Value(jsonEncode(item.genres)),
            durationMs: item.duration.inMilliseconds,
            hasArtwork: item.hasArtwork,
            analysisStatus: item.analysisStatus.name,
            customTitle: Value(item.customTitle),
            customArtistName: Value(item.customArtistName),
            customAlbumTitle: Value(item.customAlbumTitle),
            favorite: Value(
              keepPersonal ? existingCloud.favorite : item.favorite,
            ),
            customValence: Value(
              keepPersonal ? existingCloud.customValence : item.customValence,
            ),
            customArousal: Value(
              keepPersonal ? existingCloud.customArousal : item.customArousal,
            ),
            playCount: Value(
              keepPersonal ? existingCloud.playCount : item.playCount,
            ),
            lastPlayedAt: Value(
              keepPersonal ? existingCloud.lastPlayedAt : item.lastPlayedAt,
            ),
            addedAt: item.addedAt,
            updatedAt: item.updatedAt,
          ),
        );
    await _refreshPersonalMood(trackId);
  });

  /// Removes a track that left the library: its row, analysis, playlist
  /// references and caches. Never touches files on disk.
  Future<void> deleteLibraryItem(String trackId) => db.transaction(() async {
    await (db.delete(
      db.cloudPlaylistItemTable,
    )..where((t) => t.trackId.equals(trackId))).go();
    await _deleteTrackRows([trackId]);
  });

  // ── Analysis ─────────────────────────────────────────────────────────────

  Future<void> _applyAnalysis(
    String trackId,
    CloudCanonicalAnalysis? analysis,
  ) async {
    final track = await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(trackId))).getSingleOrNull();
    // Analysis always follows its library item; a stray one has no owner.
    if (track == null) return;

    if (analysis == null) {
      await _dropAnalysis(trackId);
      await _setStatus(trackId, CloudAnalysisStatus.failed);
      await _refreshPersonalMood(trackId);
      return;
    }

    final current = await (db.select(
      db.cloudAnalysisTable,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
    // Never let an older replayed analysis overwrite a newer one.
    if (current != null && current.analysisVersion > analysis.analysisVersion) {
      return;
    }

    await _dropAnalysis(trackId);
    final now = _now();
    await db
        .into(db.cloudAnalysisTable)
        .insert(
          CloudAnalysisTableCompanion.insert(
            trackId: trackId,
            analysisVersion: analysis.analysisVersion,
            embeddingModel: analysis.embeddingModel,
            embeddingVersion: analysis.embeddingVersion,
            embeddingDimension: analysis.embeddingDimension,
            emotionVersion: analysis.emotionVersion,
            valence: analysis.valence,
            arousal: analysis.arousal,
            updatedAt: now,
          ),
        );
    await TrackEmbeddingRepositoryImpl(db).save(
      TrackEmbedding(
        trackId: trackId,
        modality: TrackEmbeddingModality.audio,
        modelId: analysis.embeddingModel,
        modelVersion: analysis.embeddingVersion,
        preprocessingVersion: CloudAnalysisPipeline.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
        audioRevision: track.audioRevision,
        dimensions: analysis.embeddingDimension,
        vector: analysis.embedding,
        createdAt: now,
      ),
    );
    await db
        .into(db.trackEmotionAnalysisTable)
        .insert(
          TrackEmotionAnalysisTableCompanion.insert(
            id: 'owlsonic:$trackId',
            trackId: trackId,
            representation: CloudAnalysisPipeline.emotionRepresentation,
            modelId: CloudAnalysisPipeline.emotionModelId,
            modelVersion: analysis.emotionVersion,
            preprocessingVersion: CloudAnalysisPipeline.preprocessingVersion,
            contentRevision: cloudEmotionContentRevision,
            audioRevision: track.audioRevision,
            valence: Value(analysis.valence),
            arousal: Value(analysis.arousal),
            analyzedAt: now,
          ),
        );
    await _setStatus(trackId, CloudAnalysisStatus.ready);
    await _refreshPersonalMood(trackId);
  }

  Future<void> _dropAnalysis(String trackId) async {
    await (db.delete(
      db.cloudAnalysisTable,
    )..where((t) => t.trackId.equals(trackId))).go();
    await (db.delete(db.trackEmbeddingTable)..where(
          (t) =>
              t.trackId.equals(trackId) &
              t.preprocessingVersion.equals(
                CloudAnalysisPipeline.preprocessingVersion,
              ),
        ))
        .go();
    await (db.delete(db.trackEmotionAnalysisTable)..where(
          (t) =>
              t.trackId.equals(trackId) &
              t.modelId.equals(CloudAnalysisPipeline.emotionModelId),
        ))
        .go();
  }

  Future<void> _setStatus(String trackId, CloudAnalysisStatus status) =>
      (db.update(
        db.cloudLibraryItemTable,
      )..where((t) => t.trackId.equals(trackId))).write(
        CloudLibraryItemTableCompanion(analysisStatus: Value(status.name)),
      );

  /// Projects personal `custom_valence`/`custom_arousal` into the Mood Map's
  /// personal position: custom value per axis, canonical for the other one.
  /// Canonical values themselves are never modified.
  Future<void> _refreshPersonalMood(String trackId) async {
    final cloud = await _cloudRow(trackId);
    final remove = (db.delete(db.personalMoodAdjustmentTable)
      ..where((t) => t.trackId.equals(trackId)));
    if (cloud == null ||
        (cloud.customValence == null && cloud.customArousal == null)) {
      await remove.go();
      return;
    }
    final canonical = await (db.select(
      db.cloudAnalysisTable,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
    final valence = cloud.customValence ?? canonical?.valence;
    final arousal = cloud.customArousal ?? canonical?.arousal;
    if (valence == null || arousal == null) {
      await remove.go();
      return;
    }
    await db
        .into(db.personalMoodAdjustmentTable)
        .insertOnConflictUpdate(
          PersonalMoodAdjustmentTableCompanion.insert(
            trackId: trackId,
            valence: valence,
            arousal: arousal,
            updatedAt: cloud.updatedAt,
          ),
        );
  }

  // ── Playlists ────────────────────────────────────────────────────────────

  Future<void> _upsertPlaylist(
    String playlistId, {
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    final existing = await (db.select(
      db.playlistTable,
    )..where((t) => t.id.equals(playlistId))).getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.playlistTable)
          .insert(
            PlaylistTableCompanion.insert(
              id: playlistId,
              name: name,
              createdAt: createdAt,
            ),
          );
    } else if (existing.name != name) {
      await (db.update(
        db.playlistTable,
      )..where((t) => t.id.equals(playlistId))).write(
        PlaylistTableCompanion(
          name: Value(name),
          revision: Value(existing.revision + 1),
        ),
      );
    }
    await db
        .into(db.cloudPlaylistTable)
        .insertOnConflictUpdate(
          CloudPlaylistTableCompanion.insert(
            playlistId: playlistId,
            updatedAt: updatedAt,
          ),
        );
  }

  Future<void> deletePlaylist(String playlistId) =>
      (db.delete(db.playlistTable)..where((t) => t.id.equals(playlistId))).go();

  /// Replaces the ordered item list. The local playlist-track projection keeps
  /// one row per track (first occurrence) for tracks present locally.
  Future<void> replacePlaylistItems(
    String playlistId,
    List<CloudPlaylistItemRef> items,
  ) => db.transaction(() async {
    final playlist = await (db.select(
      db.playlistTable,
    )..where((t) => t.id.equals(playlistId))).getSingleOrNull();
    if (playlist == null) return;
    // Songs the user put here that the server does not know yet: in the view
    // but never mirrored from the server, and not in the new server list.
    final oldMirror =
        (await (db.select(
              db.cloudPlaylistItemTable,
            )..where((t) => t.playlistId.equals(playlistId))).get())
            .map((row) => row.trackId)
            .toSet();
    final oldView =
        (await (db.select(db.playlistTrackTable)
                  ..where((t) => t.playlistId.equals(playlistId))
                  ..orderBy([(t) => OrderingTerm.asc(t.position)]))
                .get())
            .map((row) => row.trackId)
            .toList();
    final serverTracks = items.map((item) => item.trackId).toSet();
    final unsynced = <(int, String)>[
      for (var i = 0; i < oldView.length; i++)
        if (!oldMirror.contains(oldView[i]) &&
            !serverTracks.contains(oldView[i]))
          (i, oldView[i]),
    ];
    await (db.delete(
      db.cloudPlaylistItemTable,
    )..where((t) => t.playlistId.equals(playlistId))).go();
    final ordered = [...items]
      ..sort((a, b) => a.position.compareTo(b.position));
    for (final item in ordered) {
      await db
          .into(db.cloudPlaylistItemTable)
          .insertOnConflictUpdate(
            CloudPlaylistItemTableCompanion.insert(
              itemId: item.itemId,
              playlistId: playlistId,
              trackId: item.trackId,
              position: item.position,
            ),
          );
    }
    final known =
        (await (db.selectOnly(db.trackTable)
                  ..addColumns([db.trackTable.id])
                  ..where(
                    db.trackTable.id.isIn(
                      ordered.map((i) => i.trackId).toSet(),
                    ),
                  ))
                .get())
            .map((row) => row.read(db.trackTable.id)!)
            .toSet();
    await (db.delete(
      db.playlistTrackTable,
    )..where((t) => t.playlistId.equals(playlistId))).go();
    final seen = <String>{};
    final projected = <String>[];
    for (final item in ordered) {
      if (!known.contains(item.trackId) || !seen.add(item.trackId)) continue;
      projected.add(item.trackId);
    }
    for (final (index, trackId) in unsynced) {
      if (seen.add(trackId)) {
        projected.insert(index.clamp(0, projected.length), trackId);
      }
    }
    for (var position = 0; position < projected.length; position++) {
      await db
          .into(db.playlistTrackTable)
          .insert(
            PlaylistTrackTableCompanion.insert(
              playlistId: playlistId,
              trackId: projected[position],
              position: position,
            ),
          );
    }
    await (db.update(db.playlistTable)..where((t) => t.id.equals(playlistId)))
        .write(PlaylistTableCompanion(revision: Value(playlist.revision + 1)));
  });

  /// Playlists that exist only on this device, with their ordered tracks.
  Future<List<({String id, String name, List<String> trackIds})>>
  localOnlyPlaylists() async {
    final cloud = (await db.select(db.cloudPlaylistTable).get())
        .map((row) => row.playlistId)
        .toSet();
    final result = <({String id, String name, List<String> trackIds})>[];
    for (final playlist in await db.select(db.playlistTable).get()) {
      if (cloud.contains(playlist.id)) continue;
      final rows =
          await (db.select(db.playlistTrackTable)
                ..where((t) => t.playlistId.equals(playlist.id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      result.add((
        id: playlist.id,
        name: playlist.name,
        trackIds: [for (final row in rows) row.trackId],
      ));
    }
    return result;
  }

  /// Which of [trackIds] are cloud tracks.
  Future<Set<String>> cloudTrackIdsAmong(Iterable<String> trackIds) async {
    final ids = trackIds.toSet();
    if (ids.isEmpty) return const {};
    final rows =
        await (db.selectOnly(db.trackTable)
              ..addColumns([db.trackTable.id])
              ..where(
                db.trackTable.id.isIn(ids) &
                    db.trackTable.sourceType.equals(_sourceType),
              ))
            .get();
    return {for (final row in rows) row.read(db.trackTable.id)!};
  }

  /// Tracks of a cloud playlist shown on this device but not on the server.
  /// Empty for device-only playlists.
  Future<List<String>> unsyncedPlaylistTracks(String playlistId) async {
    if (!await isCloudPlaylist(playlistId)) return const [];
    final mirror =
        (await (db.select(
              db.cloudPlaylistItemTable,
            )..where((t) => t.playlistId.equals(playlistId))).get())
            .map((row) => row.trackId)
            .toSet();
    final rows =
        await (db.select(db.playlistTrackTable)
              ..where((t) => t.playlistId.equals(playlistId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return [
      for (final row in rows)
        if (!mirror.contains(row.trackId)) row.trackId,
    ];
  }

  /// Cloud playlists holding tracks that are in the cloud library by now but
  /// were not added to the playlist on the server yet (they were local when
  /// put in the playlist).
  Future<Map<String, List<String>>> cloudPlaylistsAwaitingTracks() async {
    final result = <String, List<String>>{};
    for (final marker in await db.select(db.cloudPlaylistTable).get()) {
      final pending = await unsyncedPlaylistTracks(marker.playlistId);
      final cloud = await cloudTrackIdsAmong(pending);
      final ready = [
        for (final id in pending)
          if (cloud.contains(id)) id,
      ];
      if (ready.isNotEmpty) result[marker.playlistId] = ready;
    }
    return result;
  }

  /// Applies a REST `PlaylistDetail` (create/rename/reorder response).
  Future<void> applyPlaylistDetail(CloudPlaylist playlist) =>
      db.transaction(() async {
        await _upsertPlaylist(
          playlist.id,
          name: playlist.name,
          createdAt: playlist.createdAt,
          updatedAt: playlist.updatedAt,
        );
        await replacePlaylistItems(playlist.id, [
          for (final item in playlist.items)
            CloudPlaylistItemRef(
              itemId: item.id,
              trackId: item.trackId,
              position: item.position,
            ),
        ]);
      });

  Future<bool> isCloudPlaylist(String playlistId) async =>
      await (db.select(
        db.cloudPlaylistTable,
      )..where((t) => t.playlistId.equals(playlistId))).getSingleOrNull() !=
      null;

  Future<List<CloudPlaylistItemRef>> playlistItems(String playlistId) async {
    final rows =
        await (db.select(db.cloudPlaylistItemTable)
              ..where((t) => t.playlistId.equals(playlistId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return [
      for (final row in rows)
        CloudPlaylistItemRef(
          itemId: row.itemId,
          trackId: row.trackId,
          position: row.position,
        ),
    ];
  }

  // ── History ──────────────────────────────────────────────────────────────

  /// Idempotent by `event_id`: a play recorded locally with the same id is not
  /// counted twice.
  Future<void> _appendHistory(HistoryAppendSyncEvent event) async {
    final track = await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(event.trackId))).getSingleOrNull();
    final artist = await _artistName(event.trackId);
    await db
        .into(db.listeningSummaryTable)
        .insert(
          ListeningSummaryTableCompanion.insert(
            id: event.eventId,
            trackId: event.trackId,
            trackTitle: track?.title ?? '',
            artistName: artist,
            sourceType: _sourceType,
            listenedDurationMilliseconds: event.listenedMs,
            playedAt: event.playedAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await (db.update(
      db.cloudLibraryItemTable,
    )..where((t) => t.trackId.equals(event.trackId))).write(
      CloudLibraryItemTableCompanion(
        playCount: Value(event.playCount),
        lastPlayedAt: Value(event.lastPlayedAt),
      ),
    );
  }

  // ── Uploads / migration ──────────────────────────────────────────────────

  /// Makes a just-uploaded track visible immediately (201 = imported). The
  /// original file stays where it is and is played locally while present.
  Future<void> insertUploadedTrack(
    CloudTrack track, {
    String? localAudioPath,
    String? localArtworkPath,
    String? contentIdentity,
  }) => db.transaction(() async {
    final exists = await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(track.id))).getSingleOrNull();
    if (exists == null) {
      await upsertLibraryItem(
        CloudLibraryItem(
          id: track.id,
          title: track.title,
          artistName: track.artistName,
          albumTitle: track.albumTitle,
          albumArtist: null,
          trackNumber: null,
          discNumber: null,
          year: null,
          genres: const [],
          duration: track.duration,
          hasArtwork: track.hasArtwork,
          analysisStatus: CloudAnalysisStatus.pending,
          customTitle: null,
          customArtistName: null,
          customAlbumTitle: null,
          addedAt: track.addedAt,
          updatedAt: track.addedAt,
          favorite: false,
          customValence: null,
          customArousal: null,
          playCount: 0,
          lastPlayedAt: null,
        ),
      );
    }
    await (db.update(db.trackTable)..where((t) => t.id.equals(track.id))).write(
      TrackTableCompanion(
        pathToFile: localAudioPath == null
            ? const Value.absent()
            : Value(localAudioPath),
        imageUrl: localArtworkPath == null
            ? const Value.absent()
            : Value(localArtworkPath),
        contentIdentity: contentIdentity == null
            ? const Value.absent()
            : Value(contentIdentity),
      ),
    );
  });

  /// Re-keys a migrated local-only track to its new cloud id. Playlists,
  /// history and the playback queue follow the new id; the managed audio file
  /// is kept and never deleted.
  Future<void> adoptMigratedTrack({
    required String localTrackId,
    required CloudTrack uploaded,
  }) => db.transaction(() async {
    final old = await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(localTrackId))).getSingleOrNull();
    await insertUploadedTrack(
      uploaded,
      localAudioPath: old?.pathToFile,
      localArtworkPath: old?.imageUrl,
      contentIdentity: old?.contentIdentity,
    );
    if (old == null) return;
    await (db.update(db.playlistTrackTable)
          ..where((t) => t.trackId.equals(localTrackId)))
        .write(PlaylistTrackTableCompanion(trackId: Value(uploaded.id)));
    await (db.update(db.listeningSummaryTable)
          ..where((t) => t.trackId.equals(localTrackId)))
        .write(ListeningSummaryTableCompanion(trackId: Value(uploaded.id)));
    await (db.update(db.playbackQueueItemTable)
          ..where((t) => t.trackId.equals(localTrackId)))
        .write(PlaybackQueueItemTableCompanion(trackId: Value(uploaded.id)));
    await (db.update(
      db.playbackSessionTable,
    )..where((t) => t.currentTrackId.equals(localTrackId))).write(
      PlaybackSessionTableCompanion(currentTrackId: Value(uploaded.id)),
    );
    await _deleteTrackRows([localTrackId]);
  });

  // ── Offline copies ───────────────────────────────────────────────────────

  /// Folder (relative to the documents directory) of audio downloaded for the
  /// "offline" storage mode. Only files under it are managed copies; any other
  /// `pathToFile` of a cloud track is the user's own file and is never touched.
  static const offlineFolder = 'offline';

  /// Cloud tracks with no audio file on this device, oldest first.
  Future<List<String>> cloudTracksWithoutAudio() async {
    final rows =
        await (db.selectOnly(db.trackTable)
              ..addColumns([db.trackTable.id])
              ..where(
                db.trackTable.sourceType.equals(_sourceType) &
                    db.trackTable.pathToFile.isNull(),
              )
              ..orderBy([OrderingTerm.asc(db.trackTable.addedAt)]))
            .get();
    return [for (final row in rows) row.read(db.trackTable.id)!];
  }

  /// Cloud tracks in the library, and how many of them have audio on this
  /// device (the user's own file or an offline copy).
  Future<({int total, int onDevice})> cloudAudioCounts() async {
    final total = db.trackTable.id.count();
    final onDevice = db.trackTable.pathToFile.count();
    final row =
        await (db.selectOnly(db.trackTable)
              ..addColumns([total, onDevice])
              ..where(db.trackTable.sourceType.equals(_sourceType)))
            .getSingle();
    return (total: row.read(total) ?? 0, onDevice: row.read(onDevice) ?? 0);
  }

  /// Track id → relative path of every managed offline copy.
  Future<Map<String, String>> managedOfflineAudio() async {
    final rows =
        await (db.select(db.trackTable)..where(
              (t) =>
                  t.sourceType.equals(_sourceType) &
                  t.pathToFile.like('$offlineFolder/%'),
            ))
            .get();
    return {for (final row in rows) row.id: row.pathToFile!};
  }

  /// Points a cloud track at its downloaded copy. False when the track is gone
  /// or already has a file (the download is then not needed).
  Future<bool> attachOfflineAudio(String trackId, String relativePath) async {
    final updated =
        await (db.update(db.trackTable)
              ..where((t) => t.id.equals(trackId) & t.pathToFile.isNull()))
            .write(TrackTableCompanion(pathToFile: Value(relativePath)));
    return updated == 1;
  }

  /// Repoints a managed copy after its file was renamed. False when the track
  /// no longer points at [from].
  Future<bool> renameOfflineAudio(
    String trackId, {
    required String from,
    required String to,
  }) async {
    final updated =
        await (db.update(db.trackTable)
              ..where((t) => t.id.equals(trackId) & t.pathToFile.equals(from)))
            .write(TrackTableCompanion(pathToFile: Value(to)));
    return updated == 1;
  }

  /// Drops the managed offline copy reference; playback streams again.
  Future<void> detachOfflineAudio(String trackId) =>
      (db.update(db.trackTable)..where(
            (t) => t.id.equals(trackId) & t.pathToFile.like('$offlineFolder/%'),
          ))
          .write(const TrackTableCompanion(pathToFile: Value(null)));

  // ── Account isolation ────────────────────────────────────────────────────

  /// Removes every cloud-derived row (tracks, playlists, analysis, history of
  /// cloud tracks, upload records). Local-only tracks and all files on disk
  /// are left untouched.
  ///
  /// A cloud track backed by the user's own file on this device (an import or
  /// a migrated local track; not a managed offline copy) is not deleted: it
  /// becomes a local track again, keeping its id, file and device-only
  /// playlist entries. Only its cloud state (cloud rows, synced analysis,
  /// cloud artwork reference, personal cloud mood) is removed. Signing in to
  /// the same account later re-attaches it by id.
  ///
  /// Ids are bound in chunks: a whole library exceeds SQLite's variable limit.
  Future<void> purgeCloudData() => db.transaction(() async {
    final rows =
        await (db.selectOnly(db.trackTable)
              ..addColumns([
                db.trackTable.id,
                db.trackTable.pathToFile,
                db.trackTable.imageUrl,
              ])
              ..where(db.trackTable.sourceType.equals(_sourceType)))
            .get();
    final remove = <String>[];
    final keep = <({String id, String path, String? imageUrl})>[];
    for (final row in rows) {
      final id = row.read(db.trackTable.id)!;
      final path = row.read(db.trackTable.pathToFile);
      if (isUserOwnedAudio(path)) {
        keep.add((
          id: id,
          path: path!,
          imageUrl: row.read(db.trackTable.imageUrl),
        ));
      } else {
        remove.add(id);
      }
    }

    // Cloud playlists go first, so only device-only playlists keep entries.
    final playlists = (await db.select(db.cloudPlaylistTable).get())
        .map((p) => p.playlistId)
        .toList();
    for (final chunk in _chunks(playlists)) {
      await (db.delete(db.playlistTable)..where((t) => t.id.isIn(chunk))).go();
    }

    for (final chunk in _chunks(remove)) {
      await _deleteTrackRows(chunk);
    }

    for (final track in keep) {
      await (db.update(
        db.trackTable,
      )..where((t) => t.id.equals(track.id))).write(
        TrackTableCompanion(
          sourceType: Value(SourceType.localFile.name),
          sourceUri: Value(track.path),
          imageUrl: cloudArtworkTrackId(track.imageUrl) == null
              ? const Value.absent()
              : const Value(null),
        ),
      );
    }
    for (final chunk in _chunks([for (final track in keep) track.id])) {
      await (db.delete(
        db.cloudLibraryItemTable,
      )..where((t) => t.trackId.isIn(chunk))).go();
      await (db.delete(
        db.cloudAnalysisTable,
      )..where((t) => t.trackId.isIn(chunk))).go();
      await (db.delete(db.trackEmbeddingTable)..where(
            (t) =>
                t.trackId.isIn(chunk) &
                t.preprocessingVersion.equals(
                  CloudAnalysisPipeline.preprocessingVersion,
                ),
          ))
          .go();
      await (db.delete(db.trackEmotionAnalysisTable)..where(
            (t) =>
                t.trackId.isIn(chunk) &
                t.modelId.equals(CloudAnalysisPipeline.emotionModelId),
          ))
          .go();
      await (db.delete(
        db.personalMoodAdjustmentTable,
      )..where((t) => t.trackId.isIn(chunk))).go();
    }

    await (db.delete(
      db.listeningSummaryTable,
    )..where((t) => t.sourceType.equals(_sourceType))).go();
    await db.delete(db.cloudUploadTable).go();
  });

  /// The user's own audio file (not a managed offline copy of cloud audio).
  static bool isUserOwnedAudio(String? pathToFile) =>
      pathToFile != null &&
      pathToFile.isNotEmpty &&
      !pathToFile.startsWith('$offlineFolder/') &&
      !pathToFile.startsWith('$offlineFolder\\');

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<CloudLibraryItemTableData?> _cloudRow(String trackId) => (db.select(
    db.cloudLibraryItemTable,
  )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();

  Future<String> _artistName(String trackId) async {
    final rows =
        await (db.select(db.trackArtistTable).join([
                innerJoin(
                  db.artistTable,
                  db.artistTable.id.equalsExp(db.trackArtistTable.artistId),
                ),
              ])
              ..where(db.trackArtistTable.trackId.equals(trackId))
              ..orderBy([OrderingTerm.asc(db.trackArtistTable.position)]))
            .get();
    return rows.map((row) => row.readTable(db.artistTable).name).join(', ');
  }

  Future<void> _replaceArtists(String trackId, String? artistName) async {
    final previous = await (db.select(
      db.trackArtistTable,
    )..where((t) => t.trackId.equals(trackId))).get();
    await (db.delete(
      db.trackArtistTable,
    )..where((t) => t.trackId.equals(trackId))).go();
    final name = artistName?.trim();
    if (name != null && name.isNotEmpty) {
      final artistId = stableArtistId(
        source: SourceType.owlsonic,
        artistName: name,
      );
      await db
          .into(db.artistTable)
          .insertOnConflictUpdate(
            ArtistTableCompanion.insert(id: artistId, name: name),
          );
      await db
          .into(db.trackArtistTable)
          .insert(
            TrackArtistTableCompanion.insert(
              trackId: trackId,
              artistId: artistId,
              position: 0,
            ),
          );
    }
    await _dropOrphanArtists(previous.map((row) => row.artistId));
  }

  /// Row deletion only; cascades remove embeddings, emotions, cloud rows,
  /// playlist references and queue items. Files are never deleted here.
  Future<void> _deleteTrackRows(List<String> trackIds) async {
    if (trackIds.isEmpty) return;
    final artistRows = await (db.select(
      db.trackArtistTable,
    )..where((t) => t.trackId.isIn(trackIds))).get();
    await (db.delete(
      db.downloadTaskTable,
    )..where((t) => t.trackId.isIn(trackIds))).go();
    await (db.delete(db.trackTable)..where((t) => t.id.isIn(trackIds))).go();
    await _dropOrphanArtists(artistRows.map((row) => row.artistId));
  }

  Future<void> _dropOrphanArtists(Iterable<String> artistIds) async {
    for (final artistId in artistIds.toSet()) {
      final referenced =
          await (db.select(db.trackArtistTable)
                ..where((t) => t.artistId.equals(artistId))
                ..limit(1))
              .getSingleOrNull();
      if (referenced == null) {
        await (db.delete(
          db.artistTable,
        )..where((t) => t.id.equals(artistId))).go();
      }
    }
  }
}

/// Descriptors of the synced canonical analysis, for the model registry.
/// Ranking needs one embedding space, so the space covering the most tracks
/// wins (ties: higher analysis_version). Null when nothing is synced.
extension CloudAnalysisModels on CloudLocalStore {
  Future<MusicAnalysisModels?> cloudModels() async {
    final embedding = await db
        .customSelect(
          '''
SELECT embedding_model, embedding_version, embedding_dimension,
       COUNT(*) AS c, MAX(analysis_version) AS v
FROM cloud_analysis_table
GROUP BY embedding_model, embedding_version, embedding_dimension
ORDER BY c DESC, v DESC
LIMIT 1
''',
          readsFrom: {db.cloudAnalysisTable},
        )
        .getSingleOrNull();
    if (embedding == null) return null;
    final emotion = await db
        .customSelect(
          '''
SELECT emotion_version, COUNT(*) AS c, MAX(analysis_version) AS v
FROM cloud_analysis_table
GROUP BY emotion_version
ORDER BY c DESC, v DESC
LIMIT 1
''',
          readsFrom: {db.cloudAnalysisTable},
        )
        .getSingle();
    return MusicAnalysisModels(
      schemaVersion: 'owlsonic-cloud',
      models: [
        MusicAnalysisModel(
          representation: MusicAnalysisRepresentation.audioGlobal,
          modelId: embedding.read<String>('embedding_model'),
          modelVersion: embedding.read<String>('embedding_version'),
          preprocessingVersion: CloudAnalysisPipeline.preprocessingVersion,
          dimension: embedding.read<int>('embedding_dimension'),
        ),
        MusicAnalysisModel(
          representation: MusicAnalysisRepresentation.audioEmotionGlobal,
          modelId: CloudAnalysisPipeline.emotionModelId,
          modelVersion: emotion.read<String>('emotion_version'),
          preprocessingVersion: CloudAnalysisPipeline.preprocessingVersion,
        ),
      ],
    );
  }
}

class _SnapshotSeen {
  final tracks = <String>{};
  final playlists = <String>{};
}

extension CloudAnalysisStatuses on CloudLocalStore {
  /// Backend analysis status per cloud track (`pending` / `ready` / `failed`).
  Stream<Map<String, String>> watchAnalysisStatuses() => db
      .select(db.cloudLibraryItemTable)
      .watch()
      .map((rows) => {for (final row in rows) row.trackId: row.analysisStatus});
}
