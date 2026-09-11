import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';

typedef TrackImportOperation = Future<void> Function(ResolvedTrackInput input);

class ImportLocalTracksResult {
  const ImportLocalTracksResult({required this.added, required this.failed});

  final int added;
  final int failed;
}

class ImportLocalTracksUseCase {
  const ImportLocalTracksUseCase(this._addTrack);

  final TrackImportOperation _addTrack;

  Future<ImportLocalTracksResult> call(List<TrackPreview> previews) async {
    var added = 0;
    var failed = 0;

    for (final preview in previews) {
      try {
        await _addTrack(ResolvedTrackInput.single(preview));
        added++;
      } catch (error, stackTrace) {
        final failure = failureFromException(error);
        await AppLogger.warning(
          'Local track import failed with ${failure.runtimeType}.',
          operation: 'import.local_track',
          error: error,
          stackTrace: stackTrace,
        );
        failed++;
      }
    }

    return ImportLocalTracksResult(added: added, failed: failed);
  }
}
