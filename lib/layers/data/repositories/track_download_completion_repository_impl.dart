import 'package:drift/drift.dart';
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
    final updated =
        await (database.update(database.trackTable)
              ..where((track) => track.id.equals(trackId)))
            .write(TrackTableCompanion(pathToFile: Value(filePath)));
    if (updated != 1) {
      throw StateError('Cannot complete download: track $trackId not found');
    }

    final existing = await (database.select(
      database.embeddingTaskTable,
    )..where((task) => task.trackId.equals(trackId))).getSingleOrNull();
    if (existing == null) {
      await database
          .into(database.embeddingTaskTable)
          .insert(
            EmbeddingTaskTableCompanion(
              id: Value(trackId),
              trackId: Value(trackId),
              status: Value(EmbeddingStatus.queued.name),
              filePath: Value(filePath),
              createdAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return;
    }

    // Do not steal a live embedding lease. Terminal tasks can safely be
    // re-queued when the audio file changes.
    if (existing.status == EmbeddingStatus.done.name ||
        existing.status == EmbeddingStatus.failed.name) {
      await (database.update(
        database.embeddingTaskTable,
      )..where((task) => task.trackId.equals(trackId))).write(
        EmbeddingTaskTableCompanion(
          status: Value(EmbeddingStatus.queued.name),
          filePath: Value(filePath),
          createdAt: Value(DateTime.now()),
          leaseOwner: const Value(null),
          leaseUntil: const Value(null),
        ),
      );
    }
  }
}
