import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/spotify/spotify_auth_service.dart';
import 'package:openmusic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/remote/spotify_track_source.dart';
import 'package:openmusic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
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

  test('Spotify auth reports missing build configuration before login', () {
    final auth = SpotifyAuthService(
      config: const SpotifyAuthConfig(clientId: ''),
      tokenStore: _MemoryTokenStore(),
    );

    expect(auth.accessToken, throwsA(isA<ValidationFailure>()));
  });

  test('Spotify auth uses PKCE and stores returned refresh token', () async {
    final store = _MemoryTokenStore();
    final dio = Dio();
    Map<String, dynamic>? tokenRequest;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          tokenRequest = (options.data as Map).cast<String, dynamic>();
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'access_token': 'access',
                'refresh_token': 'refresh',
                'expires_in': 3600,
              },
            ),
          );
        },
      ),
    );
    Uri? authorizationUri;
    final auth = SpotifyAuthService(
      config: const SpotifyAuthConfig(clientId: 'client-id'),
      tokenStore: store,
      dio: dio,
      authenticate: (url, callbackScheme) async {
        authorizationUri = Uri.parse(url);
        return '$callbackScheme://callback?code=code&state='
            '${authorizationUri!.queryParameters['state']}';
      },
    );

    expect(await auth.accessToken(), 'access');
    expect(authorizationUri?.queryParameters['code_challenge_method'], 'S256');
    expect(authorizationUri?.queryParameters['code_challenge'], isNotEmpty);
    expect(tokenRequest, isNot(contains('client_secret')));
    expect(tokenRequest?['code_verifier'], isNotEmpty);
    expect(store.token?.refreshToken, 'refresh');
  });

  test(
    'Spotify auth refreshes an expired token without opening login',
    () async {
      final store = _MemoryTokenStore()
        ..token = SpotifyToken(
          accessToken: 'expired',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        );
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {'access_token': 'renewed', 'expires_in': 3600},
              ),
            );
          },
        ),
      );
      final auth = SpotifyAuthService(
        config: const SpotifyAuthConfig(clientId: 'client-id'),
        tokenStore: store,
        dio: dio,
        authenticate: (_, _) async => fail('must not open OAuth'),
      );

      expect(await auth.accessToken(), 'renewed');
      expect(store.token?.refreshToken, 'refresh');
    },
  );
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

class _MemoryTokenStore implements SpotifyTokenStore {
  SpotifyToken? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<SpotifyToken?> read() async => token;

  @override
  Future<void> write(SpotifyToken token) async => this.token = token;
}
