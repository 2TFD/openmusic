import 'package:drift/drift.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/repositories/track_download_completion_repository.dart';

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
    MediaLocator? media,
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

      await _updateTrackAudio(
        trackId: trackId,
        filePath: filePath,
        media: media,
      );
      return true;
    });
  }

  Future<void> _updateTrackAudio({
    required String trackId,
    required String filePath,
    MediaLocator? media,
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
                mediaSourceType: media == null
                    ? const Value.absent()
                    : Value(media.type.name),
                mediaSourceId: media == null
                    ? const Value.absent()
                    : Value(media.id),
                mediaSourceUri: media == null
                    ? const Value.absent()
                    : Value(media.url),
                contentIdentity: media == null
                    ? const Value.absent()
                    : Value('${media.type.name}:${media.id}'),
              ),
            );
    if (updated != 1) {
      throw ConflictFailure('track audio', trackId);
    }
  }
}
