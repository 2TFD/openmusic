import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeTrackSource implements TrackSource {
  YoutubeTrackSource({YoutubeExplode? youtube})
    : _youtube = youtube ?? YoutubeExplode();

  final YoutubeExplode _youtube;

  @override
  SourceType get sourceType => SourceType.youtube;

  @override
  bool canHandle(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null) return false;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    return host == 'youtu.be' ||
        host == 'youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com';
  }

  bool _isPlaylist(String input) {
    final uri = Uri.tryParse(input);
    return uri?.queryParameters['list']?.isNotEmpty == true &&
        uri?.queryParameters['v'] == null;
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    if (!canHandle(input)) throw UnsupportedSourceFailure(input);
    return _isPlaylist(input)
        ? _resolvePlaylist(input)
        : ResolvedTrackInput.single(await _resolveVideo(input));
  }

  Future<TrackPreview> _resolveVideo(String input) async {
    final video = await _youtube.videos.get(input);
    if (video.isLive) {
      throw const UnsupportedMediaFailure('YouTube live stream');
    }
    return previewFromVideo(video);
  }

  Future<ResolvedTrackInput> _resolvePlaylist(String input) async {
    final playlist = await _youtube.playlists.get(input);
    final previews = <TrackPreview>[];
    final issues = <TrackResolutionIssue>[];
    await for (final video in _youtube.playlists.getVideos(playlist.id)) {
      if (video.isLive) {
        issues.add(
          TrackResolutionIssue(
            label: video.title,
            reason: TrackResolutionIssueReason.unsupported,
          ),
        );
        continue;
      }
      previews.add(previewFromVideo(video));
    }
    if (previews.isEmpty) {
      throw const EmptyResultFailure('resolve YouTube playlist');
    }
    return ResolvedTrackInput(
      input: input,
      sourceType: SourceType.youtube,
      tracks: previews,
      issues: issues,
      collection: ResolvedTrackCollection(
        id: 'youtube:playlist:${playlist.id.value}',
        name: playlist.title,
        description: playlist.description,
        imageUrl: playlist.thumbnails.highResUrl,
      ),
    );
  }

  TrackPreview previewFromVideo(Video video) => TrackPreview(
    id: video.id.value,
    title: video.title,
    artist: video.author,
    artistId: video.channelId.value.isEmpty
        ? null
        : 'youtube:artist:${video.channelId.value}',
    artworkUrl: video.thumbnails.highResUrl,
    duration: video.duration,
    source: SourceType.youtube,
    originalUrl: video.url,
    year: video.publishDate?.year ?? video.uploadDate?.year,
    urlFile: '',
  );

  Future<List<Video>> search(String query, {int limit = 10}) async {
    final results = await _youtube.search.search(query);
    return results.where((video) => !video.isLive).take(limit).toList();
  }

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    final directory = await getApplicationDocumentsDirectory();
    final outputName = 'youtube_${_safeId(track.id)}.m4a';
    final output = File('${directory.path}/$outputName');
    if (await output.exists()) return outputName;

    final manifest = await _youtube.videos.streams.getManifest(track.id);
    if (manifest.audioOnly.isEmpty) {
      throw const UnsupportedMediaFailure('YouTube audio stream');
    }
    final mp4Streams = manifest.audioOnly
        .where((stream) => stream.container == StreamContainer.mp4)
        .toList();
    final selected = (mp4Streams.isNotEmpty ? mp4Streams : manifest.audioOnly)
        .withHighestBitrate();
    final sourceExtension = selected.container == StreamContainer.mp4
        ? 'm4a'
        : selected.container.name;
    final part = File('${output.path}.$sourceExtension.part');

    try {
      if (await part.exists()) await part.delete();
      final sink = part.openWrite();
      try {
        await for (final bytes in _youtube.videos.streams.get(selected)) {
          cancellation?.throwIfCancelled();
          sink.add(bytes);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      cancellation?.throwIfCancelled();

      if (selected.container == StreamContainer.mp4) {
        await part.rename(output.path);
      } else {
        final session = await FFmpegKit.executeWithArguments([
          '-i',
          part.path,
          '-vn',
          '-c:a',
          'aac',
          '-b:a',
          '256k',
          '-y',
          output.path,
        ]);
        final code = await session.getReturnCode();
        if (!ReturnCode.isSuccess(code) || !await output.exists()) {
          throw const UnsupportedMediaFailure('YouTube audio conversion');
        }
        await part.delete();
      }
      return outputName;
    } catch (_) {
      if (await part.exists()) await part.delete();
      if (await output.exists()) await output.delete();
      rethrow;
    }
  }

  static String _safeId(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}
