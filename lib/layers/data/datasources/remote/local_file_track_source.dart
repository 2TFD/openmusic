import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/local_track_picker.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileTrackSource implements TrackSource, LocalTrackPicker {
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
  bool canHandle(String input) {
    return input.startsWith('/') &&
        _audioExtensions.contains(_extension(input).toLowerCase());
  }

  Future<TrackPreview> fetchPreview(String filePath) async {
    final fileName = _basenameWithoutExtension(filePath);

    String title = fileName;
    String artist = 'Unknown Artist';
    String? album;
    Duration duration = Duration.zero;
    int? year;
    String? artworkPath;

    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final info = session.getMediaInformation();

      if (info != null) {
        final tags = info.getTags();
        if (tags != null) {
          final tagTitle = tags['title']?.toString();
          final tagArtist = (tags['artist'] ?? tags['album_artist'])
              ?.toString();
          final tagAlbum = tags['album']?.toString();
          final tagDate = tags['date']?.toString();

          if (tagTitle != null && tagTitle.isNotEmpty) title = tagTitle;
          if (tagArtist != null && tagArtist.isNotEmpty) artist = tagArtist;
          if (tagAlbum != null && tagAlbum.isNotEmpty) album = tagAlbum;
          if (tagDate != null) year = int.tryParse(tagDate.split('-').first);
        }

        final durationStr = info.getDuration();
        if (durationStr != null) {
          final secs = double.tryParse(durationStr);
          if (secs != null) {
            duration = Duration(milliseconds: (secs * 1000).round());
          }
        }

        artworkPath = await _extractArtwork(filePath, fileName);
      }
    } catch (_) {
      final parts = fileName.split(' - ');
      if (parts.length >= 2) {
        artist = parts.first.trim();
        title = parts.sublist(1).join(' - ').trim();
      }
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

    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;

      try {
        previews.add(await fetchPreview(path));
      } catch (_) {
        previews.add(_fallbackPreview(path));
      }
    }

    return previews;
  }

  static TrackPreview _fallbackPreview(String filePath) {
    final fileName = _basenameWithoutExtension(filePath);
    final parts = fileName.split(' - ');

    return TrackPreview(
      id: _generateId(filePath),
      title: parts.length >= 2 ? parts.sublist(1).join(' - ').trim() : fileName,
      artist: parts.length >= 2 ? parts.first.trim() : 'Unknown Artist',
      source: SourceType.localFile,
      originalUrl: filePath,
      urlFile: filePath,
    );
  }

  static Future<String?> _extractArtwork(String audioPath, String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final artDir = Directory('${dir.path}/artwork');
      await artDir.create(recursive: true);
      final outPath = '${artDir.path}/${_sanitizeFileName(name)}.jpg';

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
    } catch (_) {
      return null;
    }

    return null;
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
    final destPath = '${dir.path}/$id$ext';
    final relativePath = '$id$ext';

    if (await File(destPath).exists()) return relativePath;

    await File(preview.originalUrl).copy(destPath);
    cancellation?.throwIfCancelled();
    return relativePath;
  }

  static String _basenameWithoutExtension(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0) return name;
    return name.substring(0, dotIndex);
  }

  static String _extension(String path) {
    return _extensionWithDot(path).replaceFirst('.', '');
  }

  static String _extensionWithDot(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex);
  }
}
