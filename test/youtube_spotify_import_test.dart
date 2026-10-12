import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/spotify_track_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:owlsonic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  test('YouTube source recognizes supported video and playlist hosts', () {
    final source = YoutubeTrackSource();

    expect(source.canHandle('https://youtu.be/abc123'), isTrue);
    expect(
      source.canHandle('https://music.youtube.com/watch?v=abc123'),
      isTrue,
    );
    expect(source.canHandle('https://youtube.com/playlist?list=PL123'), isTrue);
    expect(source.canHandle('https://example.com/watch?v=abc123'), isFalse);
  });

  group('Spotify to YouTube matcher', () {
    const matcher = SpotifyYoutubeMatcher();
    const spotify = SpotifyTrackMetadata(
      id: 'spotify-id',
      title: 'Song',
      artists: ['Artist'],
      url: 'https://open.spotify.com/track/spotify-id',
      duration: Duration(minutes: 3),
    );

    test('accepts an exact official audio candidate', () {
      final video = _video(
        title: 'Song (Official Audio)',
        author: 'Artist - Topic',
        duration: const Duration(minutes: 3),
      );

      expect(matcher.best(spotify, [video]), same(video));
    });

    test('rejects unexpected covers and large duration differences', () {
      final cover = _video(
        title: 'Song cover',
        author: 'Artist',
        duration: const Duration(minutes: 3),
      );
      final wrongDuration = _video(
        title: 'Song',
        author: 'Artist - Topic',
        duration: const Duration(minutes: 5),
      );

      expect(matcher.best(spotify, [cover, wrongDuration]), isNull);
    });
  });

  test(
    'Spotify provenance and YouTube media locator survive persistence',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final local = TrackDriftLocalSource(database);
      final repository = TrackIngestionRepositoryImpl(
        database: database,
        trackLocalDataSource: local,
      );
      final track = Track(
        id: 'spotify-track',
        contentIdentity: 'youtube:video-id',
        title: 'Song',
        artists: const [Artist(id: 'spotify:artist:artist', name: 'Artist')],
        duration: const Duration(minutes: 3),
        source: const Source(
          type: SourceType.spotify,
          originalUrl: 'https://open.spotify.com/track/spotify-track',
          media: MediaLocator(
            type: SourceType.youtube,
            id: 'video-id',
            url: 'https://www.youtube.com/watch?v=video-id',
          ),
        ),
        addedAt: DateTime.utc(2026),
      );

      final stored = await repository.ingestRemote(track);
      final task = await database
          .select(database.downloadTaskTable)
          .getSingle();

      expect(stored.source.type, SourceType.spotify);
      expect(stored.source.media?.type, SourceType.youtube);
      expect(stored.source.media?.id, 'video-id');
      expect(task.originalUrl, 'https://www.youtube.com/watch?v=video-id');
    },
  );

  test('Spotify preview identity follows its actual YouTube media', () async {
    const service = Sha256TrackContentIdentityService();
    const preview = TrackPreview(
      id: 'spotify-track',
      title: 'Song',
      artist: 'Artist',
      source: SourceType.spotify,
      originalUrl: 'https://open.spotify.com/track/spotify-track',
      urlFile: '',
      media: MediaLocator(
        type: SourceType.youtube,
        id: 'video-id',
        url: 'https://www.youtube.com/watch?v=video-id',
      ),
    );

    expect(await service.createFor(preview), 'youtube:video-id');
  });

  group('YouTube bot check', () {
    test('"unavailable" behind a bot check becomes a clear failure', () async {
      final probed = <String>[];
      final source = YoutubeTrackSource(
        youtube: _FailingYoutube(
          VideoUnavailableException.unavailable(VideoId('dQw4w9WgXcQ')),
        ),
        botCheck: (id) async {
          probed.add(id);
          return true;
        },
      );

      await expectLater(
        source.resolve('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        throwsA(
          isA<YouTubeFailure>().having((f) => f.botCheck, 'botCheck', true),
        ),
      );
      expect(probed, ['dQw4w9WgXcQ']);
    });

    test('a really removed video stays unavailable', () async {
      final source = YoutubeTrackSource(
        youtube: _FailingYoutube(
          VideoUnavailableException.unavailable(VideoId('dQw4w9WgXcQ')),
        ),
        botCheck: (_) async => false,
      );

      await expectLater(
        source.resolve('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        throwsA(isA<VideoUnavailableException>()),
      );
    });

    test('the worker downloads by the stored link', () {
      final preview = YoutubeTrackSource().previewForDownload(
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        title: 'Song',
        artist: 'Artist',
      );

      expect(preview?.id, 'dQw4w9WgXcQ');
      expect(preview?.title, 'Song');
      expect(
        YoutubeTrackSource().previewForDownload('https://www.youtube.com/@x'),
        isNull,
      );
    });
  });

  group('YouTube download after a bot check', () {
    late Directory documents;
    const channel = MethodChannel('plugins.flutter.io/path_provider');

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      documents = await Directory.systemTemp.createTemp('yt_download_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => documents.path);
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await documents.delete(recursive: true);
    });

    test('a manual retry makes a fresh request after a bot check', () async {
      var probes = 0;
      final youtube = _ManifestCountingYoutube(
        VideoUnavailableException.unavailable(VideoId('dQw4w9WgXcQ')),
      );
      final source = YoutubeTrackSource(
        youtube: youtube,
        botCheck: (_) async {
          probes++;
          return true;
        },
      );
      const track = TrackPreview(
        id: 'dQw4w9WgXcQ',
        title: 'Song',
        artist: 'Artist',
        source: SourceType.youtube,
        originalUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        urlFile: '',
      );
      Matcher botCheck() => throwsA(
        isA<YouTubeFailure>().having((f) => f.botCheck, 'botCheck', true),
      );

      await expectLater(source.download(track), botCheck());
      expect(youtube.manifestRequests, 3);
      expect(probes, 1);

      await expectLater(source.download(track), botCheck());
      expect(
        youtube.manifestRequests,
        6,
        reason: 'the retry must contact YouTube again',
      );
      expect(probes, 2);
    });

    test(
      'another client can download after the probe reports a bot check',
      () async {
        final youtube = _ManifestCountingYoutube(
          VideoUnavailableException.unavailable(VideoId('dQw4w9WgXcQ')),
          successOnRequest: 2,
        );
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.resolve(
              Response<ResponseBody>(
                requestOptions: options,
                statusCode: 206,
                data: ResponseBody.fromBytes([1, 2, 3], 206),
              ),
            ),
          ),
        );
        final source = YoutubeTrackSource(
          youtube: youtube,
          botCheck: (_) async => true,
          streamDio: dio,
        );
        const track = TrackPreview(
          id: 'dQw4w9WgXcQ',
          title: 'Song',
          artist: 'Artist',
          source: SourceType.youtube,
          originalUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          urlFile: '',
        );

        final filename = await source.download(track);

        expect(youtube.manifestRequests, 2);
        expect(await File('${documents.path}/$filename').readAsBytes(), [
          1,
          2,
          3,
        ]);
      },
    );
  });

  group('YouTube ranged audio fetch', () {
    late HttpServer server;
    final audio = List<int>.generate(2500, (i) => i % 251);
    final requests = <String>[];
    var forbidden = false;

    HttpOverrides? previousOverrides;

    setUp(() async {
      // The Flutter test binding answers every real HTTP request with 400.
      previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      requests.clear();
      forbidden = false;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final range =
            request.uri.queryParameters['range'] ??
            request.headers.value('range')?.replaceFirst('bytes=', '');
        requests.add(range ?? 'none');
        if (forbidden) {
          request.response.statusCode = 403;
        } else {
          final parts = range!.split('-').map(int.parse).toList();
          request.response.statusCode = 206;
          request.response.add(audio.sublist(parts[0], parts[1] + 1));
        }
        await request.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
      HttpOverrides.global = previousOverrides;
    });

    Uri url({String client = 'WEB'}) =>
        Uri.parse('http://127.0.0.1:${server.port}/videoplayback?c=$client');

    test('downloads in ranges and assembles the file', () async {
      final sink = _MemorySink();
      await YoutubeTrackSource().fetchAudio(
        'id',
        url(),
        audio.length,
        sink,
        null,
        chunkSize: 1000,
      );

      expect(sink.bytes, audio);
      expect(requests, ['0-999', '1000-1999', '2000-2499']);
    });

    test('Android-client URLs use the Range header', () async {
      final sink = _MemorySink();
      await YoutubeTrackSource().fetchAudio(
        'id',
        url(client: 'ANDROID_VR'),
        audio.length,
        sink,
        null,
        chunkSize: 2000,
      );

      expect(sink.bytes, audio);
      expect(requests, ['0-1999', '2000-2499']);
    });

    test('a 403 gives up on the client at once', () async {
      forbidden = true;

      await expectLater(
        YoutubeTrackSource().fetchAudio(
          'id',
          url(),
          audio.length,
          _MemorySink(),
          null,
          chunkSize: 1000,
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            403,
          ),
        ),
      );
      expect(requests, hasLength(1), reason: 'no retry loop on a 403');
    });
  });

  group('YouTube stalled stream', () {
    test('fails at the stall timeout even if cancel hangs', () async {
      // Like youtube_explode mid-retry: no data, and cancel waits forever.
      final controller = StreamController<List<int>>(
        onCancel: () => Completer<void>().future,
      );
      final sink = _MemorySink();
      final watch = Stopwatch()..start();

      await expectLater(
        YoutubeTrackSource.pipeWithStallTimeout(
          controller.stream,
          sink,
          null,
          stallTimeout: const Duration(milliseconds: 200),
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('data keeps the download alive and completes it', () async {
      final sink = _MemorySink();
      final stream = Stream<List<int>>.periodic(
        const Duration(milliseconds: 50),
        (i) => [i],
      ).take(6);

      await YoutubeTrackSource.pipeWithStallTimeout(
        stream,
        sink,
        null,
        stallTimeout: const Duration(milliseconds: 200),
      );

      expect(sink.bytes, [0, 1, 2, 3, 4, 5]);
    });

    test('cancelling during a stall stops at once', () async {
      final controller = StreamController<List<int>>(
        onCancel: () => Completer<void>().future,
      );
      final cancellation = OperationCancellation();
      final pipe = YoutubeTrackSource.pipeWithStallTimeout(
        controller.stream,
        _MemorySink(),
        cancellation,
        stallTimeout: const Duration(minutes: 1),
      );
      cancellation.cancel();

      await expectLater(pipe, throwsA(isA<OperationCancelledException>()));
    });
  });

  group('Spotify embed source', () {
    test('download fallback accepts a matching SoundCloud upload', () async {
      final queries = <String>[];
      final source = _embedSource(
        [],
        const {},
        soundcloudSearch: (query) async {
          queries.add(query);
          return [
            _soundcloudCandidate(title: 'Song (Live)'),
            _soundcloudCandidate(),
          ];
        },
      );
      final track = Track(
        id: 'spotify-track',
        title: 'Song',
        artists: const [Artist(id: 'artist', name: 'Artist')],
        duration: const Duration(seconds: 200),
        source: const Source(
          type: SourceType.spotify,
          originalUrl: 'https://open.spotify.com/track/spotify-track',
          media: MediaLocator(
            type: SourceType.youtube,
            id: 'video-id',
            url: 'https://www.youtube.com/watch?v=video-id',
          ),
        ),
        addedAt: DateTime.utc(2026),
      );

      final selected = await source.findFallback(track);

      expect(queries, ['Artist Song']);
      expect(selected?.id, '42');
      expect(selected?.originalUrl, 'https://soundcloud.com/artist/song');
    });

    test('download fallback rejects a wrong-length upload', () async {
      final source = _embedSource(
        [],
        const {},
        soundcloudSearch: (_) async => [
          _soundcloudCandidate(duration: const Duration(seconds: 30)),
        ],
      );
      final track = Track(
        id: 'spotify-track',
        title: 'Song',
        artists: const [Artist(id: 'artist', name: 'Artist')],
        duration: const Duration(seconds: 200),
        source: const Source(
          type: SourceType.spotify,
          originalUrl: 'https://open.spotify.com/track/spotify-track',
          media: MediaLocator(
            type: SourceType.youtube,
            id: 'video-id',
            url: 'https://www.youtube.com/watch?v=video-id',
          ),
        ),
        addedAt: DateTime.utc(2026),
      );

      expect(await source.findFallback(track), isNull);
    });

    test(
      'playlist keeps order, skips episodes and reports broken items',
      () async {
        final requests = <Uri>[];
        final source = _embedSource(requests, {
          '/embed/playlist/p1': _embedPage({
            'type': 'playlist',
            'name': 'Editorial',
            'coverArt': {
              'sources': [
                {'url': 'https://i.scdn.co/image/cover'},
              ],
            },
            'trackList': [
              _embedItem('t1', 'Song', 'Artist'),
              {
                'uri': 'spotify:episode:e1',
                'title': 'Podcast',
                'entityType': 'episode',
                'duration': 1000,
              },
              {'uri': 'spotify:track:t2', 'title': 'No duration'},
              _embedItem('t3', 'Duet', 'Artist,\u00A0Guest'),
            ],
          }),
        });

        final resolved = await source.resolve(
          'https://open.spotify.com/playlist/p1?si=abc',
        );

        expect(requests.single.path, '/embed/playlist/p1');
        expect(resolved.collection?.name, 'Editorial');
        expect(resolved.collection?.imageUrl, 'https://i.scdn.co/image/cover');
        expect(resolved.tracks.map((track) => track.id), ['t1', 't3']);
        expect(resolved.tracks.last.artist, 'Artist, Guest');
        expect(
          resolved.tracks.last.artist,
          isNot(contains('\u00A0')),
          reason: 'NBSP from Spotify must not reach the YouTube query',
        );
        expect(resolved.tracks.first.artistId, 'spotify:artist:artist');
        expect(
          resolved.tracks.first.artworkUrl,
          contains('dQw4w9WgXcQ'),
          reason:
              'playlist items carry no artwork; the video thumbnail fills in',
        );
        expect(resolved.tracks.first.media?.type, SourceType.youtube);
        expect(resolved.issues.map((issue) => issue.label), ['No duration']);
      },
    );

    test('album tracks get the album name and cover', () async {
      final source = _embedSource([], {
        '/embed/album/a1': _embedPage({
          'type': 'album',
          'name': 'Record',
          'visualIdentity': {
            'image': [
              {'url': 'small', 'maxWidth': 64},
              {'url': 'large', 'maxWidth': 640},
            ],
          },
          'trackList': [_embedItem('t1', 'Song', 'Artist')],
        }),
      });

      final resolved = await source.resolve('spotify:album:a1');

      expect(resolved.collection?.id, 'spotify:album:a1');
      expect(resolved.tracks.single.album, 'Record');
      expect(resolved.tracks.single.artworkUrl, 'large');
    });

    test(
      'a single track reads artists and year, intl links included',
      () async {
        final requests = <Uri>[];
        final source = _embedSource(requests, {
          '/embed/track/t1': _embedPage({
            'type': 'track',
            'id': 't1',
            'name': 'Song',
            'artists': [
              {'name': 'Artist'},
            ],
            'duration': 200000,
            'releaseDate': {'isoString': '1987-11-12T00:00:00Z'},
          }),
        });

        final resolved = await source.resolve(
          'https://open.spotify.com/intl-de/track/t1',
        );

        expect(requests.single.path, '/embed/track/t1');
        expect(resolved.tracks.single.title, 'Song');
        expect(resolved.tracks.single.year, 1987);
        expect(
          resolved.tracks.single.originalUrl,
          'https://open.spotify.com/track/t1',
        );
      },
    );

    test(
      'a removed entity is not found, a changed page is unreadable',
      () async {
        final source = _embedSource([], {
          '/embed/track/gone': _nextData({
            'props': {
              'pageProps': {'status': 404},
            },
          }),
          '/embed/track/changed': '<html>no data</html>',
        });

        await expectLater(
          source.resolve('https://open.spotify.com/track/gone'),
          throwsA(isA<NotFoundFailure>()),
        );
        await expectLater(
          source.resolve('https://open.spotify.com/track/changed'),
          throwsA(isA<ParseFailure>()),
        );
      },
    );

    test('SoundCloud fills in when YouTube has no match', () async {
      final queries = <String>[];
      final source = _embedSource(
        [],
        {'/embed/track/t1': _trackPage()},
        youtube: _NoResultsYoutube(),
        soundcloudSearch: (query) async {
          queries.add(query);
          return [
            _soundcloudCandidate(title: 'Song (Live)'),
            _soundcloudCandidate(),
          ];
        },
      );

      final resolved = await source.resolve(
        'https://open.spotify.com/track/t1',
      );

      final preview = resolved.tracks.single;
      expect(queries, ['Artist Song']);
      expect(preview.source, SourceType.spotify);
      expect(preview.media?.type, SourceType.soundcloud);
      expect(preview.media?.url, 'https://soundcloud.com/artist/song');
      expect(preview.artworkUrl, 'https://i1.sndcdn.com/art.jpg');
    });

    test('SoundCloud also covers a YouTube failure (bot check)', () async {
      final source = _embedSource(
        [],
        {'/embed/track/t1': _trackPage()},
        youtube: _NoResultsYoutube(error: const YouTubeFailure(botCheck: true)),
        soundcloudSearch: (_) async => [_soundcloudCandidate()],
      );

      final resolved = await source.resolve(
        'https://open.spotify.com/track/t1',
      );

      expect(resolved.tracks.single.media?.type, SourceType.soundcloud);
    });

    test('a SoundCloud upload of another length is not taken', () async {
      final source = _embedSource(
        [],
        {'/embed/track/t1': _trackPage()},
        youtube: _NoResultsYoutube(),
        soundcloudSearch: (_) async => [
          _soundcloudCandidate(duration: const Duration(seconds: 30)),
        ],
      );

      await expectLater(
        source.resolve('https://open.spotify.com/track/t1'),
        throwsA(isA<EmptyResultFailure>()),
      );
    });

    test('artists are not importable', () async {
      final requests = <Uri>[];
      final source = _embedSource(requests, const {});

      await expectLater(
        source.resolve('https://open.spotify.com/artist/x'),
        throwsA(isA<UnsupportedMediaFailure>()),
      );
      expect(requests, isEmpty);
    });
  });
}

Video _video({
  required String title,
  required String author,
  required Duration duration,
}) => Video(
  VideoId('dQw4w9WgXcQ'),
  title,
  author,
  ChannelId('UC_x5XG1OV2P6uZZ5FSM9Ttw'),
  null,
  null,
  null,
  '',
  duration,
  const ThumbnailSet('dQw4w9WgXcQ'),
  null,
  const Engagement(0, null, null),
  false,
);

class _FakeYoutube extends YoutubeTrackSource {
  @override
  Future<List<Video>> search(String query, {int limit = 10}) async => [
    _video(
      title: query.replaceAll(' audio', ''),
      author: 'Artist',
      duration: const Duration(seconds: 200),
    ),
  ];
}

Map<String, dynamic> _embedItem(String id, String title, String artists) => {
  'uri': 'spotify:track:$id',
  'title': title,
  'subtitle': artists,
  'duration': 200000,
  'entityType': 'track',
};

String _embedPage(Map<String, dynamic> entity) => _nextData({
  'props': {
    'pageProps': {
      'state': {
        'data': {'entity': entity},
      },
    },
  },
});

String _nextData(Map<String, dynamic> data) =>
    '<html><script id="__NEXT_DATA__" type="application/json">'
    '${jsonEncode(data)}</script></html>';

SpotifyTrackSource _embedSource(
  List<Uri> requests,
  Map<String, String> pages, {
  YoutubeTrackSource? youtube,
  Future<List<TrackPreview>> Function(String query)? soundcloudSearch,
}) {
  final dio = Dio(BaseOptions(responseType: ResponseType.plain));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options.uri);
        final page = pages[options.uri.path];
        if (page == null) {
          handler.reject(
            DioException(requestOptions: options, message: 'unexpected'),
          );
          return;
        }
        handler.resolve(
          Response<String>(
            requestOptions: options,
            statusCode: 200,
            data: page,
          ),
        );
      },
    ),
  );
  return SpotifyTrackSource(
    youtube: youtube ?? _FakeYoutube(),
    dio: dio,
    soundcloud: soundcloudSearch == null ? null : _NoDownloadSource(),
    soundcloudSearch: soundcloudSearch,
    searchSpacing: Duration.zero,
  );
}

class _FailingYoutube extends Fake implements YoutubeExplode {
  _FailingYoutube(this.error);

  final Object error;

  @override
  VideoClient get videos => _FailingVideos(error);
}

class _FailingVideos extends Fake implements VideoClient {
  _FailingVideos(this.error);

  final Object error;

  @override
  Future<Video> get(dynamic videoId) async => throw error;
}

class _NoResultsYoutube extends YoutubeTrackSource {
  _NoResultsYoutube({this.error});

  final Object? error;

  @override
  Future<List<Video>> search(String query, {int limit = 10}) async {
    if (error case final error?) throw error;
    return const [];
  }
}

class _NoDownloadSource extends Fake implements TrackSource {}

TrackPreview _soundcloudCandidate({
  String title = 'Song',
  String artist = 'Artist',
  Duration duration = const Duration(seconds: 200),
}) => TrackPreview(
  id: '42',
  title: title,
  artist: artist,
  duration: duration,
  source: SourceType.soundcloud,
  originalUrl: 'https://soundcloud.com/artist/song',
  artworkUrl: 'https://i1.sndcdn.com/art.jpg',
  urlFile: '',
);

String _trackPage() => _embedPage({
  'type': 'track',
  'id': 't1',
  'name': 'Song',
  'artists': [
    {'name': 'Artist'},
  ],
  'duration': 200000,
});

class _MemorySink implements IOSink {
  final bytes = <int>[];

  @override
  void add(List<int> data) => bytes.addAll(data);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ManifestCountingYoutube extends Fake implements YoutubeExplode {
  _ManifestCountingYoutube(this.error, {this.successOnRequest});

  final Object error;
  final int? successOnRequest;
  int manifestRequests = 0;

  @override
  VideoClient get videos => _ManifestVideos(this);
}

class _ManifestVideos extends Fake implements VideoClient {
  _ManifestVideos(this.owner);

  final _ManifestCountingYoutube owner;

  @override
  StreamClient get streams => _ManifestStreams(owner);
}

class _ManifestStreams extends Fake implements StreamClient {
  _ManifestStreams(this.owner);

  final _ManifestCountingYoutube owner;

  @override
  Future<StreamManifest> getManifest(
    dynamic videoId, {
    bool fullManifest = false,
    List<YoutubeApiClient>? ytClients,
    bool requireWatchPage = true,
  }) async {
    owner.manifestRequests++;
    if (owner.manifestRequests == owner.successOnRequest) {
      return StreamManifest([
        AudioOnlyStreamInfo(
          VideoId('dQw4w9WgXcQ'),
          140,
          Uri.parse('https://example.com/audio?c=ANDROID_VR'),
          StreamContainer.mp4,
          const FileSize(3),
          const Bitrate(128000),
          'mp4a.40.2',
          'medium',
          const [],
          MediaType('audio', 'mp4'),
          null,
        ),
      ]);
    }
    throw owner.error;
  }
}
