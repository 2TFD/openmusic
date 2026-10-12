import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:path/path.dart' as p;

class AudioMetadata {
  const AudioMetadata({
    required this.title,
    this.artist,
    this.album,
    this.coverPath,
  });

  final String title;
  final String? artist;
  final String? album;

  /// Local image file to embed as the front cover.
  final String? coverPath;
}

/// Writes title/artist/album and the cover into an audio file, so a copy kept
/// on the device looks right in other players and file managers (the backend
/// strips all tags from uploads).
abstract interface class AudioMetadataWriter {
  /// Returns false when the file was left as it was.
  Future<bool> write(String audioPath, AudioMetadata metadata);
}

/// FFmpeg stream copy: the audio is not re-encoded (bit-identical), only the
/// container is rewritten with the tags, so it costs disk I/O, not CPU.
class FfmpegAudioMetadataWriter implements AudioMetadataWriter {
  const FfmpegAudioMetadataWriter();

  /// Containers that can carry an attached cover picture. OGG/Opus cannot via
  /// FFmpeg's muxer; they still get the text tags.
  static const _coverContainers = {'.mp3', '.m4a', '.mp4', '.flac'};

  @override
  Future<bool> write(String audioPath, AudioMetadata metadata) async {
    final extension = p.extension(audioPath).toLowerCase();
    final cover = metadata.coverPath;
    final withCover =
        cover != null &&
        _coverContainers.contains(extension) &&
        await File(cover).exists();
    final output = File(
      p.join(
        p.dirname(audioPath),
        '${p.basenameWithoutExtension(audioPath)}.tagged$extension',
      ),
    );
    final arguments = [
      '-y',
      '-i',
      audioPath,
      if (withCover) ...['-i', cover],
      '-map',
      '0:a',
      if (withCover) ...['-map', '1:v', '-disposition:v', 'attached_pic'],
      '-c',
      'copy',
      if (extension == '.mp3') ...['-id3v2_version', '3'],
      '-metadata',
      'title=${metadata.title}',
      if (metadata.artist case final artist?) ...[
        '-metadata',
        'artist=$artist',
      ],
      if (metadata.album case final album?) ...['-metadata', 'album=$album'],
      output.path,
    ];
    try {
      final session = await FFmpegKit.executeWithArguments(arguments);
      final code = await session.getReturnCode();
      if (!ReturnCode.isSuccess(code) || !await output.exists()) {
        if (await output.exists()) await output.delete();
        return false;
      }
      await output.rename(audioPath);
      return true;
    } catch (error, stackTrace) {
      // Missing plugin (e.g. Linux) or I/O failure: the untagged file stays.
      if (await output.exists()) await output.delete();
      await AppLogger.warning(
        'Could not write audio metadata.',
        operation: 'owlsonic.audio_metadata',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
