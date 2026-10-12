import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/usecases/add_track_use_case.dart';

sealed class LocalImportOutcome {
  const LocalImportOutcome();
}

final class LocalImportAdded extends LocalImportOutcome {
  const LocalImportAdded(this.track);
  final Track track;
}

/// The audio was already in the library; nothing new was created.
final class LocalImportExisting extends LocalImportOutcome {
  const LocalImportExisting(this.track);
  final Track track;
}

final class LocalImportFailed extends LocalImportOutcome {
  const LocalImportFailed(this.failure);
  final Failure failure;
}

typedef AddResolvedTracks =
    Future<AddTrackResult> Function(ResolvedTrackInput input);

/// Commits one reviewed file to the library. The track is visible as soon as
/// this returns; embeddings and lyrics continue in background queues.
class ImportLocalTrackItemUseCase {
  const ImportLocalTrackItemUseCase(this._addTrack);

  final AddResolvedTracks _addTrack;

  Future<LocalImportOutcome> call(TrackPreview preview) async {
    try {
      final result = await _addTrack(ResolvedTrackInput.single(preview));
      final track = result.firstTrack;
      if (track == null) {
        return LocalImportFailed(
          result.failures.firstOrNull?.failure ??
              const EmptyResultFailure('import track'),
        );
      }
      return result.existingTrackIds.contains(track.id)
          ? LocalImportExisting(track)
          : LocalImportAdded(track);
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Local import of ${preview.id} failed.',
        operation: 'import.local_item',
        error: error,
        stackTrace: stackTrace,
      );
      return LocalImportFailed(failureFromException(error));
    }
  }
}
