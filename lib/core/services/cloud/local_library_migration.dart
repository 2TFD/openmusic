import 'dart:io';

import 'package:dio/dio.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:path/path.dart' as p;

class MigrationProgress {
  const MigrationProgress({
    required this.total,
    required this.done,
    required this.failed,
  });
  final int total;
  final int done;
  final int failed;
}

/// "Upload local library to OwlSonic": an explicit, user-confirmed action for
/// tracks imported before cloud integration (files and downloaded link
/// imports); link imports made while signed in upload on their own. Uses the same upload pipeline
/// (new UUIDv7 track id, persistent Idempotency-Key, LOCAL_UPLOAD or
/// COMMUNITY_IMPORT for link imports). Success is
/// recorded per item, so a restart never re-uploads blindly. Files are kept.
class LocalLibraryMigration {
  LocalLibraryMigration({
    required TrackRepository tracks,
    required CloudUploadStore uploads,
    required CloudImportService importer,
    required String appDir,
    Dio? dio,
  }) : _tracks = tracks,
       _uploads = uploads,
       _importer = importer,
       _appDir = appDir,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
             ),
           );

  final TrackRepository _tracks;
  final CloudUploadStore _uploads;
  final CloudImportService _importer;
  final String _appDir;
  final Dio _dio;

  bool get available => _importer.enabled;

  Future<List<CloudImportSource>> candidates() async {
    final ids = {
      for (final row in await _uploads.migrationCandidates()) row.id,
    };
    if (ids.isEmpty) return const [];
    final sources = <CloudImportSource>[];
    for (final track in await _tracks.getTracksByIds(ids.toList())) {
      final source = await _sourceFor(track);
      if (source != null) sources.add(source);
    }
    return sources;
  }

  /// Local files and tracks downloaded from links (SoundCloud, YouTube,
  /// Spotify) both live as a managed audio file; cloud tracks are already
  /// uploaded. Null when there is nothing to upload yet.
  Future<CloudImportSource?> _sourceFor(Track track) async {
    if (track.source.type == SourceType.owlsonic || track.filePath == null) {
      return null;
    }
    final audioPath = p.join(_appDir, track.filePath);
    if (!await File(audioPath).exists()) return null;
    final artwork = await _artworkFile(track);
    return CloudImportSource(
      key: track.id,
      audioPath: audioPath,
      title: track.title,
      artistName: track.artists.isEmpty
          ? null
          : track.artists.map((artist) => artist.name).join(', '),
      albumTitle: track.album,
      artworkPath: artwork,
      contentIdentity: track.contentIdentity,
      sourceTrackId: track.id,
      sourceProvider: communityProviderFor(track.source.type),
    );
  }

  static const _maxArtworkBytes = 10 * 1024 * 1024;

  static const _artworkExtensions = {
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
  };

  /// The local file to upload as the track's artwork. Local imports already
  /// have an extracted file; link imports (SoundCloud, YouTube, Spotify) only
  /// have an http URL, which is downloaded once into `artwork/` so the server
  /// gets a real cover. A failed download only means no cover is uploaded.
  Future<String?> _artworkFile(Track track) async {
    final value = track.imageUrl;
    if (value == null || value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      return await File(value).exists() ? value : null;
    }
    try {
      final dir = Directory(p.join(_appDir, 'artwork'));
      await dir.create(recursive: true);
      final base = _safeName(track.id);
      for (final extension in _artworkExtensions.values.toSet()) {
        final cached = File(p.join(dir.path, '$base.$extension'));
        if (await cached.exists() && await cached.length() > 0) {
          return cached.path;
        }
      }
      final response = await _dio.get<List<int>>(
        value,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      final mime = response.headers
          .value(Headers.contentTypeHeader)
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      final extension = _artworkExtensions[mime];
      if (bytes == null ||
          bytes.isEmpty ||
          bytes.length > _maxArtworkBytes ||
          extension == null) {
        return null;
      }
      final target = File(p.join(dir.path, '$base.$extension'));
      final partial = File('${target.path}.part');
      await partial.writeAsBytes(bytes, flush: true);
      await partial.rename(target.path);
      return target.path;
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Could not download artwork for upload.',
        operation: 'owlsonic.upload_artwork',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static String _safeName(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  Future<void> _serial = Future.value();

  /// Uploads one just-downloaded track (from a link import) while signed in
  /// and auto-sync allows it. Calls are serialized: [CloudImportService] runs
  /// one batch at a time. Failures stay in the upload store, so
  /// `resumePending` retries the retryable ones and the account screen lists
  /// the rest.
  Future<void> uploadDownloaded(String trackId) =>
      _uploadOne(trackId, onlyIfAutoAllowed: true);

  /// Uploads one track the user asked to sync, whatever the auto-sync setting.
  Future<void> uploadNow(String trackId) =>
      _uploadOne(trackId, onlyIfAutoAllowed: false);

  Future<void> _uploadOne(String trackId, {required bool onlyIfAutoAllowed}) {
    if (!available) return Future.value();
    final next = _serial.then((_) async {
      try {
        // With auto-sync off (or on mobile data under "Wi-Fi only") a
        // download stays on the device; auto-sync uploads it later.
        if (onlyIfAutoAllowed && !await _importer.autoUploadAllowed()) return;
        final track = (await _tracks.getTracksByIds([trackId])).firstOrNull;
        if (track == null) return;
        final source = await _sourceFor(track);
        if (source == null) return;
        await _importer.importAll([source]);
      } catch (error, stackTrace) {
        await AppLogger.warning(
          'Cloud upload of a track failed.',
          operation: 'owlsonic.upload_track',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
    _serial = next;
    return next;
  }

  /// Uploads every local track that is still waiting, for auto-sync. Runs in
  /// line with the other uploads of this class, and skips tracks that failed
  /// for good earlier so they are not retried on every pass.
  Future<void> uploadWaiting() {
    if (!available) return Future.value();
    final next = _serial.then((_) async {
      try {
        final skip = await _uploads.permanentlyFailedSourceTracks();
        final sources = [
          for (final source in await candidates())
            if (!skip.contains(source.sourceTrackId)) source,
        ];
        if (sources.isEmpty) return;
        await _importer.importAll(sources);
      } catch (error, stackTrace) {
        await AppLogger.warning(
          'Automatic upload of local tracks failed.',
          operation: 'owlsonic.auto_sync.upload',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
    _serial = next;
    return next;
  }

  Future<MigrationProgress> run({
    void Function(MigrationProgress progress)? onProgress,
  }) async {
    final sources = await candidates();
    var done = 0;
    var failed = 0;
    final results = await _importer.importAll(
      sources,
      onUpdate: (_, state) {
        if (!state.isTerminal) return;
        if (state.phase == CloudUploadPhase.succeeded) done++;
        if (state.phase == CloudUploadPhase.failed) failed++;
        onProgress?.call(
          MigrationProgress(total: sources.length, done: done, failed: failed),
        );
      },
    );
    return MigrationProgress(
      total: sources.length,
      done: results.values
          .where((state) => state.phase == CloudUploadPhase.succeeded)
          .length,
      failed: results.values
          .where((state) => state.phase == CloudUploadPhase.failed)
          .length,
    );
  }

  void stop() => _importer.stop();
}
