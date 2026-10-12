import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/core/utils/audio_file_name.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Asks YouTube whether [videoId] is behind the "confirm you're not a bot"
/// wall for this network.
typedef YouTubeBotCheckProbe = Future<bool> Function(String videoId);

typedef _NamedClient = ({String name, YoutubeApiClient client});

class YoutubeTrackSource implements TrackSource, DirectDownloadSource {
  YoutubeTrackSource({
    YoutubeExplode? youtube,
    YouTubeBotCheckProbe? botCheck,
    Dio? streamDio,
  }) : _youtube = youtube ?? YoutubeExplode(),
       _botCheck = botCheck ?? _probeBotCheck,
       _streamDio =
           streamDio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               responseType: ResponseType.stream,
             ),
           );

  final YoutubeExplode _youtube;
  final YouTubeBotCheckProbe _botCheck;

  /// Audio is fetched here, not with youtube_explode's stream client: on a
  /// 403 that one re-requests the manifest and tries again with no limit,
  /// which hung downloads for minutes and kept hammering YouTube.
  final Dio _streamDio;

  static void _log(String message) =>
      AppLogger.info('[YouTube] $message', operation: 'youtube.download');

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
    if (_isPlaylist(input)) {
      final listId = PlaylistId.parsePlaylistId(input);
      if (listId == null) throw UnsupportedSourceFailure(input);
      // Mixes (RD…) are generated and endless; LL/WL are private to the user.
      if (listId.startsWith('RD') || listId == 'LL' || listId == 'WL') {
        throw const UnsupportedMediaFailure('YouTube mix or private list');
      }
      return _resolvePlaylist(input);
    }
    // Channels, @handles and YouTube Music album pages are not videos; reject
    // them here with a clear failure instead of an ArgumentError.
    final videoId = VideoId.parseVideoId(_withoutShortsQuery(input));
    if (videoId == null) {
      throw UnsupportedSourceFailure(input);
    }
    return ResolvedTrackInput.single(
      await _explainBotCheck(videoId, () => _resolveVideo(videoId)),
    );
  }

  /// youtube_explode reports YouTube's bot check as "video unavailable" (the
  /// watch page lacks the video) or "unplayable", which reads like a dead
  /// link. Ask YouTube once what really happened.
  Future<T> _explainBotCheck<T>(
    String videoId,
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } on YoutubeExplodeException catch (error) {
      if (await _isBotCheck(videoId, error)) {
        throw const YouTubeFailure(botCheck: true);
      }
      rethrow;
    }
  }

  Future<bool> _isBotCheck(String videoId, Object error) async {
    if (error is YouTubeFailure) return error.botCheck;
    if (isYouTubeBotCheckMessage('$error')) return true;
    if (error is! VideoUnavailableException &&
        error is! VideoUnplayableException) {
      return false;
    }
    return _botCheck(videoId).catchError((Object _) => false);
  }

  static Future<bool> _probeBotCheck(String videoId) async {
    final response =
        await Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ).post<Map<String, dynamic>>(
          'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
          data: {
            'videoId': videoId,
            'context': {
              'client': {
                'clientName': 'ANDROID_VR',
                'clientVersion': '1.65.10',
                'hl': 'en',
              },
            },
          },
        );
    final status = response.data?['playabilityStatus'];
    return status is Map &&
        status['status'] == 'LOGIN_REQUIRED' &&
        isYouTubeBotCheckMessage('${status['reason']}');
  }

  /// youtube_explode only matches `/shorts/<id>` at the very end of the URL,
  /// but shared Shorts links carry `?si=…` / `?feature=share`.
  static String _withoutShortsQuery(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null || !uri.path.startsWith('/shorts/')) return input;
    return Uri(scheme: uri.scheme, host: uri.host, path: uri.path).toString();
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

  @override
  TrackPreview? previewForDownload(
    String originalUrl, {
    String? title,
    String? artist,
  }) {
    final videoId = VideoId.parseVideoId(_withoutShortsQuery(originalUrl));
    if (videoId == null) return null;
    return TrackPreview(
      id: videoId,
      title: title ?? videoId,
      artist: artist ?? 'Unknown Artist',
      source: SourceType.youtube,
      originalUrl: originalUrl,
      urlFile: '',
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
    final outputName =
        '${audioFileBase(artist: track.artist, title: track.title, source: 'youtube', id: track.id)}.m4a';
    final output = File(p.join(directory.path, outputName));
    if (await output.exists()) {
      _log('${track.id}: already downloaded');
      return outputName;
    }

    final watch = Stopwatch()..start();
    _log('${track.id}: download started');
    try {
      final name = await _explainBotCheck(
        track.id,
        () => _downloadWithFallbacks(track, output, outputName, cancellation),
      );
      _log('${track.id}: done in ${watch.elapsedMilliseconds}ms');
      return name;
    } on YouTubeFailure catch (error) {
      _log(
        '${track.id}: YouTube failure after ${watch.elapsedMilliseconds}ms: '
        '${_describe(error)}',
      );
      rethrow;
    } catch (error) {
      _log(
        '${track.id}: failed after ${watch.elapsedMilliseconds}ms: '
        '${_describe(error)}',
      );
      rethrow;
    }
  }

  static String _describe(Object error) =>
      '${error.runtimeType}: ${'$error'.split('\n').first}';

  Future<String> _downloadWithFallbacks(
    TrackPreview track,
    File output,
    String outputName,
    OperationCancellation? cancellation,
  ) async {
    var botCheckSeen = false;
    for (var attempt = 0; ; attempt++) {
      final client = _manifestClients[attempt];
      final watch = Stopwatch()..start();
      try {
        return await _downloadWith(
          track,
          output,
          outputName,
          client,
          cancellation,
        );
      } on OperationCancelledException {
        _log('${track.id}: cancelled');
        rethrow;
      } catch (error) {
        _log(
          '${track.id}: client ${client.name} failed after '
          '${watch.elapsedMilliseconds}ms: ${_describe(error)}',
        );
        // The probe uses Android VR, which can be blocked even when another
        // player client still serves audio. Keep its result until all of the
        // bounded fallback attempts fail.
        final botCheck = botCheckSeen || await _isBotCheck(track.id, error);
        botCheckSeen |= botCheck;
        _log(
          '${track.id}: bot-check probe says ${botCheck ? 'blocked' : 'not blocked'}',
        );
        // YouTube regularly rejects one player client (403, empty manifest,
        // throttled stream); another client usually still works.
        if (attempt + 1 >= _manifestClients.length) {
          if (botCheckSeen) throw const YouTubeFailure(botCheck: true);
          rethrow;
        }
        cancellation?.throwIfCancelled();
      }
    }
  }

  static const _stallTimeout = Duration(seconds: 30);

  /// A throttled stream can stall for minutes while youtube_explode retries
  /// internally. `await for` + `Stream.timeout` does not help: leaving the
  /// loop awaits the subscription's cancel, which waits for those retries.
  /// Here a stall fails the download at once and the cancel runs detached.
  @visibleForTesting
  static Future<void> pipeWithStallTimeout(
    Stream<List<int>> stream,
    IOSink sink,
    OperationCancellation? cancellation, {
    Duration stallTimeout = _stallTimeout,
  }) {
    final done = Completer<void>();
    late final StreamSubscription<List<int>> subscription;
    Timer? stall;
    void fail(Object error, [StackTrace? stackTrace]) {
      if (done.isCompleted) return;
      stall?.cancel();
      unawaited(subscription.cancel().catchError((Object _) {}));
      done.completeError(error, stackTrace);
    }

    void arm() {
      stall?.cancel();
      stall = Timer(
        stallTimeout,
        () => fail(TimeoutException('YouTube stream stalled', stallTimeout)),
      );
    }

    subscription = stream.listen(
      (bytes) {
        if (cancellation?.isCancelled == true) {
          fail(const OperationCancelledException());
          return;
        }
        sink.add(bytes);
        arm();
      },
      onError: fail,
      onDone: () {
        stall?.cancel();
        if (!done.isCompleted) done.complete();
      },
      cancelOnError: true,
    );
    cancellation?.whenCancelled.then(
      (_) => fail(const OperationCancelledException()),
    );
    arm();
    return done.future;
  }

  static const _manifestTimeout = Duration(seconds: 45);

  /// In order. Measured on a bot-flagged VPN IP (2026-10-12): these handed
  /// out playable audio for an unflagged video; TV, web and music clients
  /// failed even there.
  static final _manifestClients = <_NamedClient>[
    (name: 'androidSdkless', client: YoutubeApiClient.androidSdkless),
    (name: 'androidVr', client: YoutubeApiClient.androidVr),
    (name: 'ios', client: YoutubeApiClient.ios),
  ];

  /// Range size per request; YouTube throttles single requests above ~10 MB.
  static const _chunkSize = 10 * 1024 * 1024;
  static const _chunkAttempts = 3;

  /// Ranged GETs with a bounded retry. A 403 means YouTube rejected this
  /// signed URL: give up on the client at once, the caller tries the next.
  @visibleForTesting
  Future<void> fetchAudio(
    String videoId,
    Uri url,
    int total,
    IOSink sink,
    OperationCancellation? cancellation, {
    int chunkSize = _chunkSize,
  }) async {
    // Android-client URLs take a Range header; the others a `range` param.
    final rangeHeader = url.queryParameters['c']?.startsWith('ANDROID') == true;
    var received = 0;
    var failures = 0;
    final watch = Stopwatch()..start();
    while (received < total) {
      cancellation?.throwIfCancelled();
      final to = math.min(received + chunkSize, total) - 1;
      final cancelToken = CancelToken();
      final cancelled = cancellation?.whenCancelled.then((_) {
        if (!cancelToken.isCancelled) cancelToken.cancel();
      });
      try {
        final response = await _streamDio.getUri<ResponseBody>(
          rangeHeader
              ? url
              : url.replace(
                  queryParameters: {
                    ...url.queryParameters,
                    'range': '$received-$to',
                  },
                ),
          options: Options(
            responseType: ResponseType.stream,
            headers: rangeHeader ? {'Range': 'bytes=$received-$to'} : null,
          ),
          cancelToken: cancelToken,
        );
        final before = received;
        await pipeWithStallTimeout(
          response.data!.stream.map((bytes) {
            received += bytes.length;
            return bytes;
          }),
          sink,
          cancellation,
        );
        if (received == before) throw const ParseFailure();
        failures = 0;
        _log(
          '$videoId: ${received * 100 ~/ total}% '
          '($received/$total bytes, ${watch.elapsedMilliseconds}ms)',
        );
      } catch (error) {
        if (!cancelToken.isCancelled) cancelToken.cancel();
        if (error is OperationCancelledException) rethrow;
        cancellation?.throwIfCancelled();
        final status = error is DioException
            ? error.response?.statusCode
            : null;
        _log(
          '$videoId: chunk at $received failed'
          '${status == null ? '' : ' (HTTP $status)'}: ${_describe(error)}',
        );
        if (status == 403 || ++failures >= _chunkAttempts) rethrow;
        await Future<void>.delayed(Duration(seconds: failures));
      } finally {
        unawaited(cancelled);
      }
    }
  }

  Future<String> _downloadWith(
    TrackPreview track,
    File output,
    String outputName,
    _NamedClient client,
    OperationCancellation? cancellation,
  ) async {
    final watch = Stopwatch()..start();
    // An explicit client list: with none, youtube_explode silently retries
    // with the TV client, one more request that today fails anyway.
    final manifest = await _youtube.videos.streams
        .getManifest(track.id, ytClients: [client.client])
        .timeout(_manifestTimeout);
    _log(
      '${track.id}: client ${client.name} manifest in '
      '${watch.elapsedMilliseconds}ms, ${manifest.audioOnly.length} audio streams',
    );
    if (manifest.audioOnly.isEmpty) {
      throw const UnsupportedMediaFailure('YouTube audio stream');
    }
    final mp4Streams = manifest.audioOnly
        .where((stream) => stream.container == StreamContainer.mp4)
        .toList();
    final selected = (mp4Streams.isNotEmpty ? mp4Streams : manifest.audioOnly)
        .withHighestBitrate();
    _log(
      '${track.id}: stream itag ${selected.tag}, ${selected.container.name}, '
      '${selected.bitrate.kiloBitsPerSecond.round()} kbit/s, '
      '${selected.size.totalBytes} bytes, throttled=${selected.isThrottled}',
    );
    final sourceExtension = selected.container == StreamContainer.mp4
        ? 'm4a'
        : selected.container.name;
    final part = File('${output.path}.$sourceExtension.part');

    try {
      if (await part.exists()) await part.delete();
      final sink = part.openWrite();
      try {
        await fetchAudio(
          track.id,
          selected.url,
          selected.size.totalBytes,
          sink,
          cancellation,
        );
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
}
