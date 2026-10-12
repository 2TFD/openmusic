import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/import_candidate.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/local_file_scanner.dart';
import 'package:owlsonic/layers/domain/repositories/track_content_identity_service.dart';
import 'package:owlsonic/layers/domain/repositories/track_duplicate_lookup.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:path/path.dart' as p;

/// Prepares a selected file for review: validates it, reads metadata and
/// checks whether the same audio is already in the library. Never writes.
class ScanLocalImportUseCase {
  const ScanLocalImportUseCase({
    required LocalFileScanner scanner,
    required TrackContentIdentityService identity,
    required TrackDuplicateLookup duplicates,
    required TrackRepository tracks,
  }) : _scanner = scanner,
       _identity = identity,
       _duplicates = duplicates,
       _tracks = tracks;

  final LocalFileScanner _scanner;
  final TrackContentIdentityService _identity;
  final TrackDuplicateLookup _duplicates;
  final TrackRepository _tracks;

  Future<List<String>> pickFiles() => _scanner.pickFiles();

  Future<List<String>> pickFolder() => _scanner.pickFolder();

  Future<List<String>> expand(List<String> paths) =>
      _scanner.expandPaths(paths);

  /// [batchIdentities] maps content identity -> title for files already seen
  /// in the same batch, so selecting one file twice is reported as a duplicate.
  Future<ImportCandidate> scan(
    String path, {
    required Map<String, String> batchIdentities,
  }) async {
    final name = p.basename(path);
    if (!_scanner.isSupportedPath(path)) {
      return ImportCandidate(
        path: path,
        fileName: name,
        status: ImportItemStatus.invalid,
        failure: UnsupportedMediaFailure(path),
      );
    }

    try {
      final preview = await _scanner.readPreview(path);
      final identity = await _identity.forLocalFile(path);

      final batchTitle = batchIdentities[identity];
      if (batchTitle != null) {
        return ImportCandidate(
          path: path,
          fileName: name,
          status: ImportItemStatus.duplicate,
          preview: preview,
          contentIdentity: identity,
          duplicateOfTitle: batchTitle,
        );
      }

      final existing =
          await _duplicates.findByContentIdentity(identity) ??
          await _existingWithSameId(preview.id, path);
      if (existing != null) {
        return ImportCandidate(
          path: path,
          fileName: name,
          status: ImportItemStatus.duplicate,
          preview: preview,
          contentIdentity: identity,
          duplicateOfTitle: existing.title,
          duplicateOfTrackId: existing.id,
        );
      }

      batchIdentities[identity] = preview.title;
      return ImportCandidate(
        path: path,
        fileName: name,
        status: ImportItemStatus.ready,
        preview: preview,
        contentIdentity: identity,
      );
    } catch (error, stackTrace) {
      final failure = _asScanFailure(error);
      await AppLogger.warning(
        'Import scan rejected $name with ${failure.runtimeType}.',
        operation: 'import.scan',
        error: error,
        stackTrace: stackTrace,
      );
      return ImportCandidate(
        path: path,
        fileName: name,
        status: ImportItemStatus.invalid,
        failure: failure,
      );
    }
  }

  /// Local ids are a 32-bit path hash, so the same id is only the same track
  /// when it was imported from the same path; otherwise it is a collision.
  Future<Track?> _existingWithSameId(String id, String path) async {
    final track = await _tracks.getTrackById(id);
    if (track?.filePath == null || track!.source.originalUrl != path) {
      return null;
    }
    return track;
  }

  Failure _asScanFailure(Object error) {
    final failure = failureFromException(error);
    // A scan failure on a file the user chose means the file itself is bad;
    // "unknown" would only hide that.
    return failure is UnknownFailure
        ? UnsupportedMediaFailure('$error')
        : failure;
  }
}
