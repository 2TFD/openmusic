import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Playlist;

// FIXME
class YoutubeTrackSource implements TrackSource {
  static final _clients = [
    YoutubeApiClient.ios,
    YoutubeApiClient.androidVr,
    YoutubeApiClient.androidMusic,
  ];

  @override
  bool canHandle(String input) {
    final t = input.trim();
    return t.contains('youtube.com/watch') ||
        t.contains('youtu.be/') ||
        t.contains('youtube.com/playlist');
  }

  @override
  Future<TrackPreview> fetchTrackPreview(String input) async {
    final yt = YoutubeExplode();
    try {
      final id = Uri.tryParse(input)?.queryParameters['v'] ?? input;
      try {
        final video = await yt.videos.get(id);
        return _videoToPreview(video);
      } on VideoUnavailableException {
        // YTM-only track — verify it's downloadable and return minimal preview
        await yt.videos.streams.getManifest(
          id,
          ytClients: _clients,
          requireWatchPage: false,
        );
        final videoUrl = 'https://www.youtube.com/watch?v=$id';
        return TrackPreview(
          id: id,
          title: id,
          artist: 'YouTube Music',
          source: SourceType.youtube,
          originalUrl: videoUrl,
          urlFile: videoUrl,
        );
      }
    } finally {
      yt.close();
    }
  }

  @override
  Future<List<TrackPreview>> resolve(String input) async {
    return [await fetchTrackPreview(input)];
  }

  @override
  Future<String> download(TrackPreview preview) async {
    final yt = YoutubeExplode();
    String? tempPath;
    IOSink? sink;
    try {
      final videoId = VideoId(preview.id);
      final manifest = await yt.videos.streams.getManifest(
        videoId,
        ytClients: _clients,
        requireWatchPage: false,
      );

      // Prefer mp4 (m4a) — wider player support; fall back to highest bitrate
      final mp4Streams = manifest.audioOnly
          .where((s) => s.container == StreamContainer.mp4)
          .toList();
      final streamInfo = mp4Streams.isNotEmpty
          ? mp4Streams.withHighestBitrate()
          : manifest.audioOnly.withHighestBitrate();

      final ext = streamInfo.container.name;
      final dir = await getApplicationDocumentsDirectory();
      final idValue = videoId.value;
      tempPath = '${dir.path}/temp_$idValue.$ext';
      final finalPath = '${dir.path}/$idValue.$ext';
      final relativePath = '$idValue.$ext';

      if (await File(finalPath).exists()) return relativePath;

      final stream = yt.videos.streams.get(streamInfo);
      sink = File(tempPath).openWrite();
      await for (final chunk in stream) {
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();
      sink = null;

      // Remux: recalculate moov atom so duration/seeking work correctly
      final session = await FFmpegKit.executeWithArguments([
        '-i',
        tempPath,
        '-c',
        'copy',
        '-movflags',
        'faststart',
        finalPath,
        '-y',
      ]);

      final code = await session.getReturnCode();
      if (!ReturnCode.isSuccess(code)) {
        final logs = await session.getAllLogsAsString();
        throw Exception('FFmpeg remux failed: $logs');
      }

      return relativePath;
    } finally {
      await sink?.close();
      if (tempPath != null) {
        final f = File(tempPath);
        if (await f.exists()) await f.delete();
      }
      yt.close();
    }
  }

  @override
  Future<Playlist> createPlaylist(String url, List<Track> tracks) async {
    final yt = YoutubeExplode();
    try {
      final ytPlaylist = await yt.playlists.get(url);
      return Playlist(
        id: ytPlaylist.id.value,
        name: ytPlaylist.title,
        trackIds: tracks.map((t) => t.id).toList(),
        createdAt: DateTime.now(),
        description: ytPlaylist.description,
        imageUrl: ytPlaylist.thumbnails.highResUrl,
      );
    } finally {
      yt.close();
    }
  }

  TrackPreview _videoToPreview(Video video, {String? overrideOriginalUrl}) {
    final videoUrl = 'https://www.youtube.com/watch?v=${video.id.value}';
    return TrackPreview(
      id: video.id.value,
      title: video.title,
      artist: video.author,
      artworkUrl: video.thumbnails.highResUrl,
      duration: video.duration,
      source: SourceType.youtube,
      originalUrl: overrideOriginalUrl ?? videoUrl,
      year: video.uploadDate?.year,
      urlFile: videoUrl,
    );
  }
}
