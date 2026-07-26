import 'package:drift/drift.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';
import 'package:openmusic/layers/domain/repositories/track_download_completion_repository.dart';

class TrackDownloadCompletionRepositoryImpl
    implements TrackDownloadCompletionRepository {
  final AppDatabase database;

  TrackDownloadCompletionRepositoryImpl(this.database);

  @override
  Future<void> completeLocal({
    required String trackId,
    required String filePath,
  }) => database.transaction(
    () => _updateTrackAndQueueEmbedding(trackId: trackId, filePath: filePath),
  );

  @override
  Future<bool> completeClaimed({
    required String trackId,
    required String filePath,
    required String ownerId,
  }) {
    return database.transaction<bool>(() async {
      final deleted =
          await (database.delete(database.downloadTaskTable)..where(
                (task) =>
                    task.trackId.equals(trackId) &
                    task.status.equals(DownloadStatus.downloading.name) &
                    task.leaseOwner.equals(ownerId),
              ))
              .go();
      if (deleted != 1) return false;

      await _updateTrackAndQueueEmbedding(trackId: trackId, filePath: filePath);
      return true;
    });
  }

  Future<void> _updateTrackAndQueueEmbedding({
    required String trackId,
    required String filePath,
  }) async {
    final current = await (database.select(
      database.trackTable,
    )..where((track) => track.id.equals(trackId))).getSingleOrNull();
    if (current == null) throw NotFoundFailure('track', trackId);

    final audioRevision = current.audioRevision + 1;
    final updated =
        await (database.update(database.trackTable)..where(
              (track) =>
                  track.id.equals(trackId) &
                  track.audioRevision.equals(current.audioRevision),
            ))
            .write(
              TrackTableCompanion(
                pathToFile: Value(filePath),
                embedding: const Value(null),
                audioRevision: Value(audioRevision),
              ),
            );
    if (updated != 1) {
      throw StateError('Concurrent audio update for track $trackId');
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
        Variable<String>(trackId),
        Variable<String>(trackId),
        Variable<String>(EmbeddingStatus.queued.name),
        Variable<String>(filePath),
        Variable<DateTime>(DateTime.now()),
        Variable<int>(audioRevision),
      ],
      updates: {database.embeddingTaskTable},
    );
  }
}
