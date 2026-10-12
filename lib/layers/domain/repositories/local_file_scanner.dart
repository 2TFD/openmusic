import 'package:owlsonic/layers/domain/entities/track_preview.dart';

/// Desktop-oriented access to local audio files: choosing, expanding folders
/// and reading metadata without committing anything to the library.
abstract interface class LocalFileScanner {
  /// Returns an empty list when the user cancels the dialog.
  Future<List<String>> pickFiles();

  /// Returns every supported audio file below the chosen folder, or an empty
  /// list when the user cancels.
  Future<List<String>> pickFolder();

  /// Normalizes dropped/selected paths. Files are kept as-is (so unsupported
  /// ones can be reported); directories are expanded to supported audio files.
  Future<List<String>> expandPaths(List<String> paths);

  bool isSupportedPath(String path);

  /// Throws a [Failure] when the file cannot be read as audio.
  Future<TrackPreview> readPreview(String path);
}
