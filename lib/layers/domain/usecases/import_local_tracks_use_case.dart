import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/utils/app_logger.dart';

typedef TrackImportOperation = Future<void> Function(ResolvedTrackInput input);

class ImportLocalTracksResult {
  const ImportLocalTracksResult({
    required this.added,
    required this.failed,
    this.failures = const [],
    this.localOnly = false,
  });

  final int added;
  final int failed;

  /// Why files failed (cloud uploads carry the backend error category).
  final List<Failure> failures;

  /// True when the user is signed out of a configured OwlSonic backend, so the
  /// imported music exists on this device only and is not synced.
  final bool localOnly;
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
