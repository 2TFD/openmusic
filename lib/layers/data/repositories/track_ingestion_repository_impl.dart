import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/track_mapper.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/track_ingestion_repository.dart';

class TrackIngestionRepositoryImpl implements TrackIngestionRepository {
  TrackIngestionRepositoryImpl({
    required this.database,
    required this.trackLocalDataSource,
  });

  final AppDatabase database;
  final TrackLocalDataSource trackLocalDataSource;

  @override
  Future<Track> ingestRemote(Track track) async {
    await database.transaction(() async {
      final existing = await _findTrack(track.id);
      if (existing?.pathToFile != null) return;

      if (existing == null) {
        await _insertTrack(track);
        await _insertArtists(track);
      }

      await database.customUpdate(
        '''
INSERT INTO download_task_table (
  track_id, original_url, status, created_at, lease_owner, lease_until
) VALUES (?, ?, ?, ?, NULL, NULL)
ON CONFLICT(track_id) DO UPDATE SET
  original_url = excluded.original_url,
  status = excluded.status,
  created_at = excluded.created_at,
  lease_owner = NULL,
  lease_until = NULL
WHERE download_task_table.status IN (?, ?)
''',
        variables: [
          Variable<String>(track.id),
          Variable<String>(track.source.originalUrl),
          Variable<String>(DownloadStatus.queued.name),
          Variable<DateTime>(DateTime.now()),
          Variable<String>(DownloadStatus.completed.name),
          Variable<String>(DownloadStatus.failed.name),
        ],
        updates: {database.downloadTaskTable},
      );
    });
    return _loadTrack(track.id);
  }

  @override
  Future<Track> ingestLocal(Track track, {required String filePath}) async {
    await database.transaction(() async {
      var existing = await _findTrack(track.id);
      if (existing?.pathToFile != null) return;

      if (existing == null) {
        await _insertTrack(track);
        await _insertArtists(track);
        existing = await _findTrack(track.id);
      }
      if (existing == null) throw NotFoundFailure('track', track.id);

      final revision = existing.audioRevision + 1;
      final updated =
          await (database.update(database.trackTable)..where(
                (row) =>
                    row.id.equals(track.id) &
                    row.audioRevision.equals(existing!.audioRevision),
              ))
              .write(
                TrackTableCompanion(
                  pathToFile: Value(filePath),
                  embedding: const Value(null),
                  audioRevision: Value(revision),
                ),
              );
      if (updated != 1) {
        throw StateError('Concurrent audio update for track ${track.id}');
      }

      await database.customUpdate(
        '''
INSERT INTO embedding_task_table (
  id, track_id, status, file_path, created_at, audio_revision,
  lease_owner, lease_until
) VALUES (?, ?, ?, ?, ?, ?, NULL, NULL)
ON CONFLICT(track_id) DO UPDATE SET
  status = excluded.status,
  file_path = excluded.file_path,
  created_at = excluded.created_at,
  audio_revision = excluded.audio_revision,
  lease_owner = NULL,
  lease_until = NULL
''',
        variables: [
          Variable<String>(track.id),
          Variable<String>(track.id),
          Variable<String>(EmbeddingStatus.queued.name),
          Variable<String>(filePath),
          Variable<DateTime>(DateTime.now()),
          Variable<int>(revision),
        ],
        updates: {database.embeddingTaskTable},
      );
    });
    return _loadTrack(track.id);
  }

  Future<TrackTableData?> _findTrack(String id) => (database.select(
    database.trackTable,
  )..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<void> _insertTrack(Track track) async {
    await database
        .into(database.trackTable)
        .insert(
          TrackTableCompanion.insert(
            id: track.id,
            title: track.title,
            pathToFile: Value(track.filePath),
            durationMs: Value(track.duration.inMilliseconds),
            sourceType: track.source.type.name,
            sourceUri: track.source.originalUrl,
            addedAt: Value(track.addedAt),
            album: Value(track.album),
            imageUrl: Value(track.imageUrl),
            trackDescriptorJson: Value(track.trackDescriptor?.toJson()),
            embedding: Value(
              track.embedding == null ? null : jsonEncode(track.embedding),
            ),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _insertArtists(Track track) async {
    final seen = <String>{};
    var position = 0;
    for (final artist in track.artists) {
      if (artist.id.isEmpty || !seen.add(artist.id)) continue;
      await database
          .into(database.artistTable)
          .insertOnConflictUpdate(
            ArtistTableCompanion.insert(id: artist.id, name: artist.name),
          );
      await database
          .into(database.trackArtistTable)
          .insert(
            TrackArtistTableCompanion.insert(
              trackId: track.id,
              artistId: artist.id,
              position: position++,
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<Track> _loadTrack(String id) async {
    final dto = await trackLocalDataSource.getTrackById(id);
    if (dto == null) throw NotFoundFailure('track', id);
    return TrackMapper.toEntity(dto);
  }
}
