import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/retry_policy.dart';
import 'package:owlsonic/layers/data/datasources/remote/soundcloud_track_source.dart';

/// Экран подтверждения импорта ждёт resolve целиком, поэтому цена resolve —
/// это и есть время загрузки UI. Тесты фиксируют количество запросов.
void main() {
  test('playlist hydrates stub tracks in batches, in playlist order', () async {
    final requests = <Uri>[];
    final source = _source(
      requests,
      resolvePlaylist: _playlist(hydratedIds: [1], stubIds: _range(2, 121)),
    );

    final resolved = await source.resolve(
      'https://soundcloud.com/user/sets/mix',
    );

    expect(resolved.tracks.length, 121, reason: '1 готовый + 120 заглушек');
    expect(resolved.tracks.map((track) => track.id).take(3), [
      '1',
      '2',
      '3',
    ], reason: 'порядок плейлиста должен пережить батч-ответ');

    final batches = requests.where((uri) => uri.path == '/tracks').toList();
    expect(batches.length, 3, reason: '120 заглушек = 50 + 50 + 20');
    expect(
      requests.where((uri) => uri.path.startsWith('/tracks/')),
      isEmpty,
      reason: 'запросов на отдельные треки быть не должно',
    );
  });

  test('resolve does not fetch stream urls', () async {
    final requests = <Uri>[];
    final source = _source(
      requests,
      resolvePlaylist: _playlist(hydratedIds: [1, 2], stubIds: const []),
    );

    await source.resolve('https://soundcloud.com/user/sets/mix');

    expect(
      requests.where((uri) => uri.path.contains('/stream')),
      isEmpty,
      reason:
          'стрим-ссылка живёт минуты и всё равно берётся заново при скачивании',
    );
  });

  test('likes follow next_href past the old 200 cap', () async {
    final requests = <Uri>[];
    final source = _source(requests, likesPages: 3, likesPerPage: 200);

    final resolved = await source.resolve('https://soundcloud.com/user/likes');

    expect(resolved.tracks.length, 600);
    expect(requests.where((uri) => uri.path.endsWith('/likes')).length, 3);
  });

  test('likes keep HLS-only tracks: HLS is downloadable', () async {
    final requests = <Uri>[];
    final source = _source(
      requests,
      likesPages: 1,
      likesPerPage: 4,
      hlsOnlyEvery: 2,
    );

    final resolved = await source.resolve('https://soundcloud.com/user/likes');

    expect(resolved.tracks.length, 4);
    expect(resolved.issues, isEmpty);
  });

  test('Go+ 30-second previews are reported, not imported', () async {
    final requests = <Uri>[];
    final source = _source(
      requests,
      likesPages: 1,
      likesPerPage: 4,
      snippedEvery: 2,
    );

    final resolved = await source.resolve('https://soundcloud.com/user/likes');

    expect(resolved.tracks.length, 2);
    expect(resolved.issues.length, 2);
  });

  test(
    'a track slug starting with "likes" is a track, not a likes page',
    () async {
      final requests = <Uri>[];
      final source = _source(requests);

      final resolved = await source.resolve(
        'https://soundcloud.com/artist/likes-you?si=abc',
      );

      expect(resolved.tracks.single.id, '9');
      expect(requests.where((uri) => uri.path.endsWith('/likes')), isEmpty);
    },
  );

  test('a profile link is rejected without network calls', () async {
    final requests = <Uri>[];
    final source = _source(requests);

    await expectLater(
      source.resolve('https://soundcloud.com/artist'),
      throwsA(anything),
    );
    expect(requests.where((uri) => uri.path == '/resolve'), isEmpty);
  });

  test(
    'a discover system playlist is rejected without network calls',
    () async {
      final requests = <Uri>[];
      final source = _source(requests);

      await expectLater(
        source.resolve('https://soundcloud.com/discover/sets/weekly::user'),
        throwsA(anything),
      );
      expect(requests.where((uri) => uri.path == '/resolve'), isEmpty);
    },
  );

  test('a 401 while hydrating retries with a fresh client id', () async {
    final requests = <Uri>[];
    final source = _source(
      requests,
      resolvePlaylist: _playlist(hydratedIds: [1], stubIds: _range(2, 10)),
      rejectFirstBatch: true,
    );

    final resolved = await source.resolve(
      'https://soundcloud.com/user/sets/mix',
    );

    expect(resolved.tracks.length, 10);
    expect(resolved.issues, isEmpty);
  });
}

List<int> _range(int from, int to) =>
    List<int>.generate(to - from + 1, (i) => from + i);

Map<String, dynamic> _playlist({
  required List<int> hydratedIds,
  required List<int> stubIds,
}) => {
  'id': 777,
  'title': 'Mix',
  'description': null,
  'artwork_url': null,
  'tracks': [
    for (final id in hydratedIds) _track(id),
    for (final id in stubIds) {'id': id, 'kind': 'track'},
  ],
};

Map<String, dynamic> _track(
  int id, {
  bool hlsOnly = false,
  bool snipped = false,
}) => {
  'id': id,
  'kind': 'track',
  if (snipped) 'policy': 'SNIP',
  'title': 'Track $id',
  'permalink_url': 'https://soundcloud.com/user/track-$id',
  'duration': 180000,
  'album': null,
  'artwork_url': null,
  'calculated_artwork_url': null,
  'user': {'id': 5, 'username': 'User'},
  'media': {
    'transcodings': [
      {
        'url': 'https://api-v2.soundcloud.com/media/$id/stream/hls',
        'format': {'protocol': 'hls', 'mime_type': 'audio/mp4'},
        'snipped': snipped,
      },
      if (!hlsOnly)
        {
          'url': 'https://api-v2.soundcloud.com/media/$id/stream/progressive',
          'format': {'protocol': 'progressive'},
          'snipped': snipped,
        },
    ],
  },
};

SoundcloudTrackSource _source(
  List<Uri> requests, {
  Map<String, dynamic>? resolvePlaylist,
  int likesPages = 0,
  int likesPerPage = 0,
  int? hlsOnlyEvery,
  int? snippedEvery,
  bool rejectFirstBatch = false,
}) {
  var batchRejected = !rejectFirstBatch;
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options.uri);
        final uri = options.uri;

        // Прогоняем через JSON: боевые ответы приходят из jsonDecode как
        // List<dynamic>/Map<String, dynamic>, а литералы в тесте типизированы
        // строже и маскируют ошибки разбора.
        Response<dynamic> ok(dynamic data) => Response<dynamic>(
          requestOptions: options,
          data: jsonDecode(jsonEncode(data)),
          statusCode: 200,
        );

        if (uri.host == 'soundcloud.com') {
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: 'client_id:"testId"',
              statusCode: 200,
            ),
          );
          return;
        }
        if (uri.path == '/resolve') {
          final target = uri.queryParameters['url'] ?? '';
          if (target.contains('/sets/')) {
            handler.resolve(ok(resolvePlaylist));
            return;
          }
          if (target.endsWith('/artist/likes-you')) {
            handler.resolve(ok(_track(9)));
            return;
          }
          handler.resolve(
            ok({'id': 42, 'permalink': 'user', 'username': 'User'}),
          );
          return;
        }
        if (uri.path.endsWith('/likes')) {
          final page = int.tryParse(uri.queryParameters['page'] ?? '1') ?? 1;
          final offset = (page - 1) * likesPerPage;
          handler.resolve(
            ok({
              'collection': [
                for (var i = 0; i < likesPerPage; i++)
                  {
                    'track': _track(
                      offset + i + 1,
                      hlsOnly:
                          hlsOnlyEvery != null &&
                          (offset + i) % hlsOnlyEvery == 1,
                      snipped:
                          snippedEvery != null &&
                          (offset + i) % snippedEvery == 1,
                    ),
                  },
              ],
              'next_href': page < likesPages
                  ? 'https://api-v2.soundcloud.com/users/42/likes?page=${page + 1}'
                  : null,
            }),
          );
          return;
        }
        if (uri.path.startsWith('/tracks/')) {
          handler.resolve(ok(_track(int.parse(uri.pathSegments.last))));
          return;
        }
        if (uri.path == '/tracks' && !batchRejected) {
          batchRejected = true;
          handler.reject(
            DioException.badResponse(
              statusCode: 401,
              requestOptions: options,
              response: Response<void>(
                requestOptions: options,
                statusCode: 401,
              ),
            ),
          );
          return;
        }
        if (uri.path == '/tracks') {
          final ids = (uri.queryParameters['ids'] ?? '').split(',');
          handler.resolve(
            // Порядок ответа намеренно обратный: источник обязан
            // восстанавливать порядок плейлиста сам.
            ok([for (final id in ids.reversed) _track(int.parse(id))]),
          );
          return;
        }
        handler.reject(
          DioException(requestOptions: options, message: 'unexpected $uri'),
        );
      },
    ),
  );

  final redirectDio = Dio();
  redirectDio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response<dynamic>(requestOptions: options, statusCode: 200),
      ),
    ),
  );

  final source = SoundcloudTrackSource(
    dio: dio,
    redirectDio: redirectDio,
    retryPolicy: RetryPolicy(delay: (_) async {}),
  );
  source.invalidateClientId();
  return source;
}
