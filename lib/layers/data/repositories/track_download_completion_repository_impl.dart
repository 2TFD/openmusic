import 'package:drift/drift.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
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
    () => _updateTrackAudio(trackId: trackId, filePath: filePath),
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

      await _updateTrackAudio(trackId: trackId, filePath: filePath);
      return true;
    });
  }

  Future<void> _updateTrackAudio({
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
                audioRevision: Value(audioRevision),
              ),
            );
    if (updated != 1) {
      throw ConflictFailure('track audio', trackId);
    }
  }
}
