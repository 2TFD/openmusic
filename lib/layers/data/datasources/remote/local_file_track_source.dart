import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/media_information.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/local_file_scanner.dart';
import 'package:owlsonic/layers/domain/repositories/local_track_picker.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalFileTrackSource
    implements TrackSource, LocalTrackPicker, LocalFileScanner {
  static const _audioExtensions = [
    'mp3',
    'm4a',
    'flac',
    'wav',
    'aac',
    'ogg',
    'opus',
  ];

  @override
  SourceType get sourceType => SourceType.localFile;

  @override
  bool canHandle(String input) => isSupportedAudioPath(input);

  static bool isSupportedAudioPath(String input, {p.Context? pathContext}) {
    final paths = pathContext ?? p.context;
    return paths.isAbsolute(input) &&
        _audioExtensions.contains(
          paths.extension(input).replaceFirst('.', '').toLowerCase(),
        );
  }

  Future<TrackPreview> fetchPreview(String filePath) async {
    final fileName = _basenameWithoutExtension(filePath);
    // Untagged files are often named "Artist - Title"; tags still win.
    final parts = fileName.split(' - ');

    String title = parts.length >= 2
        ? parts.sublist(1).join(' - ').trim()
        : fileName;
    String artist = parts.length >= 2 ? parts.first.trim() : 'Unknown Artist';
    String? album;
    Duration duration = Duration.zero;
    int? year;
    String? artworkPath;

    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        throw UnsupportedMediaFailure('$filePath: ffprobe could not open it');
      }

      final info = session.getMediaInformation();
      if (info == null) {
        throw UnsupportedMediaFailure('$filePath: no media information');
      }

      final audio = info
          .getStreams()
          .where((stream) => stream.getType() == 'audio')
          .firstOrNull;
      if (audio == null) {
        throw UnsupportedMediaFailure('$filePath: no audio stream');
      }

      // Some VBR/streamed files carry no container duration; fall back to the
      // audio stream, and keep the file even when neither knows its length.
      final secs = double.tryParse(
        info.getDuration() ?? audio.getStringProperty('duration') ?? '',
      );
      if (secs != null && secs > 0) {
        duration = Duration(milliseconds: (secs * 1000).round());
      }

      final tags = _readTags(info);
      if (tags.isNotEmpty) {
        final tagTitle = tags['title'];
        final tagArtist = tags['artist'] ?? tags['album_artist'];
        final tagAlbum = tags['album'];
        final tagDate = tags['date'] ?? tags['year'];

        if (tagTitle != null && tagTitle.isNotEmpty) title = tagTitle;
        if (tagArtist != null && tagArtist.isNotEmpty) artist = tagArtist;
        if (tagAlbum != null && tagAlbum.isNotEmpty) album = tagAlbum;
        if (tagDate != null) year = int.tryParse(tagDate.split('-').first);
      }

      artworkPath = await _extractArtwork(
        filePath,
        await _artworkName(filePath),
      );
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Failed to probe local track. File might be corrupted or not an audio file.',
        operation: 'local_track.read_metadata',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    return TrackPreview(
      id: _generateId(filePath),
      title: title,
      artist: artist,
      album: album,
      artworkUrl: artworkPath,
      duration: duration,
      source: SourceType.localFile,
      originalUrl: filePath,
      urlFile: filePath,
      year: year,
    );
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    return ResolvedTrackInput.single(await fetchPreview(input));
  }

  @override
  Future<List<TrackPreview>> pickTracks() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _audioExtensions,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return [];

    final previews = <TrackPreview>[];
    Object? firstError;

    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;

      // One unreadable file must not discard the rest of the selection.
      try {
        previews.add(await fetchPreview(path));
      } catch (error) {
        firstError ??= error;
      }
    }

    if (previews.isEmpty && firstError != null) throw firstError;
    return previews;
  }

  /// On Android/iOS the picker hands out copies in its cache; once they are
  /// imported (copied into app storage or uploaded) the copies are waste.
  @override
  Future<void> clearPickedCache() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await FilePicker.platform.clearTemporaryFiles();
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Could not clear the file picker cache.',
        operation: 'local_track.clear_picker_cache',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<String>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _audioExtensions,
      withData: false,
      withReadStream: false,
    );
    return [
      for (final file in result?.files ?? const <PlatformFile>[])
        if (file.path != null) file.path!,
    ];
  }

  @override
  Future<List<String>> pickFolder() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) return const [];
    return expandPaths([directory]);
  }

  @override
  Future<List<String>> expandPaths(List<String> paths) async {
    final expanded = <String>{};
    for (final path in paths) {
      if (await FileSystemEntity.isDirectory(path)) {
        try {
          await for (final entity in Directory(
            path,
          ).list(recursive: true, followLinks: false)) {
            if (entity is File && isSupportedAudioPath(entity.path)) {
              expanded.add(entity.path);
            }
          }
        } on FileSystemException catch (error, stackTrace) {
          await AppLogger.warning(
            'Could not list import folder.',
            operation: 'local_track.expand_folder',
            error: error,
            stackTrace: stackTrace,
          );
          rethrow;
        }
      } else {
        expanded.add(path);
      }
    }
    return expanded.toList()..sort();
  }

  @override
  bool isSupportedPath(String path) => isSupportedAudioPath(path);

  @override
  Future<TrackPreview> readPreview(String path) async {
    if (!await File(path).exists()) throw const FileNotFoundFailure();
    return fetchPreview(path);
  }

  static Future<String?> _extractArtwork(String audioPath, String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final artDir = Directory(p.join(dir.path, 'artwork'));
      await artDir.create(recursive: true);
      final outPath = p.join(artDir.path, '${_sanitizeFileName(name)}.jpg');

      if (await File(outPath).exists()) return outPath;

      final session = await FFmpegKit.executeWithArguments([
        '-i',
        audioPath,
        '-an',
        '-vcodec',
        'copy',
        '-frames:v',
        '1',
        outPath,
        '-y',
      ]);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode) && await File(outPath).exists()) {
        return outPath;
      }
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Embedded artwork extraction failed.',
        operation: 'local_track.extract_artwork',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }

    return null;
  }

  /// Vorbis comments (FLAC/OGG/Opus) keep their own case (`TITLE`), and in
  /// OGG/Opus they live on the audio stream, not the container. Container tags
  /// win; stream tags fill the gaps. Keys are lower-cased.
  static Map<String, String> _readTags(MediaInformation info) {
    final result = <String, String>{};
    void addAll(Map<dynamic, dynamic>? tags) {
      tags?.forEach((key, value) {
        final text = value?.toString().trim();
        if (key == null || text == null || text.isEmpty) return;
        result.putIfAbsent(key.toString().toLowerCase(), () => text);
      });
    }

    addAll(info.getTags());
    for (final stream in info.getStreams()) {
      if (stream.getType() == 'audio') addAll(stream.getTags());
    }
    return result;
  }

  /// Artwork is cached by file name, so it must not share the 32-bit track id:
  /// two colliding files would show each other's cover. Size is part of the
  /// name so a replaced file at the same path gets its own cover.
  static Future<String> _artworkName(String filePath) async {
    final size = await File(filePath).length();
    final digest = sha1.convert(utf8.encode(filePath)).toString();
    return '${digest.substring(0, 20)}_$size';
  }

  static String _sanitizeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static String _generateId(String filePath) {
    var hash = 0x811c9dc5;
    for (final codeUnit in filePath.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  @override
  Future<String> download(
    TrackPreview preview, {
    OperationCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    final dir = await getApplicationDocumentsDirectory();
    final ext = _extensionWithDot(preview.originalUrl);
    final id = _generateId(preview.originalUrl);
    final source = File(preview.originalUrl);
    final sourceLength = await source.length();
    var relativePath = '$id$ext';
    var destPath = p.join(dir.path, relativePath);

    final existing = File(destPath);
    if (await existing.exists()) {
      // The id is a 32-bit path hash: only reuse a file that is plausibly the
      // same audio, otherwise a collision or a truncated earlier copy would be
      // played back as this track.
      if (await existing.length() == sourceLength) return relativePath;
      relativePath = '$id-${DateTime.now().microsecondsSinceEpoch}$ext';
      destPath = p.join(dir.path, relativePath);
    }

    final partial = File('$destPath.part');
    try {
      await source.copy(partial.path);
      cancellation?.throwIfCancelled();
      await partial.rename(destPath);
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
    return relativePath;
  }

  static String _basenameWithoutExtension(String path) {
    final name = p.basename(path);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0) return name;
    return name.substring(0, dotIndex);
  }

  static String _extensionWithDot(String path) {
    final name = p.basename(path);
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex);
  }
}
