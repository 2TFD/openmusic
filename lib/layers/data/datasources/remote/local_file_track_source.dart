import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalFileTrackSource implements TrackSource {
  static final _kAudioExtensions = [
    'mp3',
    'm4a',
    'flac',
    'wav',
    'aac',
    'ogg',
    'opus',
  ];

  @override
  bool canHandle(String input) {
    return input.startsWith('/') &&
        _kAudioExtensions.contains(input.split('.').last.toLowerCase());
  }

  @override
  Future<TrackPreview> fetchTrackPreview(String input) => fetchPreview(input);

  Future<TrackPreview> fetchPreview(String filePath) async {
    final fileName = p.basenameWithoutExtension(filePath);

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
        artist = parts[0].trim();
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
      year: year ?? DateTime.now().year,
    );
  }

  @override
  Future<List<TrackPreview>> resolve(String input) async {
    final preview = await fetchPreview(input);
    return [preview];
  }

  static Future<List<TrackPreview>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _kAudioExtensions,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return [];

    final source = LocalFileTrackSource();
    final previews = <TrackPreview>[];

    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;

      try {
        previews.add(await source.fetchPreview(path));
      } catch (_) {
        previews.add(_fallbackPreview(path));
      }
    }

    return previews;
  }

  static TrackPreview _fallbackPreview(String filePath) {
    final fileName = p.basenameWithoutExtension(filePath);

    final parts = fileName.split(' - ');
    final title = parts.length >= 2
        ? parts.sublist(1).join(' - ').trim()
        : fileName;
    final artist = parts.length >= 2 ? parts[0].trim() : 'Unknown Artist';

    return TrackPreview(
      id: _generateId(filePath),
      title: title,
      artist: artist,
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
      final outPath = '${artDir.path}/$name.jpg';

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
      return null;
    } catch (_) {
      return null;
    }
  }

  static String _generateId(String filePath) {
    return filePath.hashCode.abs().toRadixString(16);
  }

  @override
  Future<Playlist> createPlaylist(String url, List<Track> tracks) async {
    final name = p.basenameWithoutExtension(url);
    return Playlist(
      id: url.hashCode.abs().toRadixString(16),
      name: name.isNotEmpty ? name : 'Local Files',
      trackIds: tracks.map((t) => t.id).toList(),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<String> download(TrackPreview preview) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(preview.originalUrl);
    final id = _generateId(preview.originalUrl);
    final destPath = '${dir.path}/$id$ext';
    final relativePath = '$id$ext';

    if (await File(destPath).exists()) return relativePath;

    await File(preview.originalUrl).copy(destPath);
    return relativePath;
  }
}
