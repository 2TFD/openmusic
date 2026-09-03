import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/datasources/lyrics/lrclib_lyrics_provider.dart';
import 'package:openmusic/layers/domain/repositories/lyrics_provider.dart';

void main() {
  test(
    'gets exact synced and plain lyrics with required identification',
    () async {
      final transport = _Transport([_Reply(200, _record())]);
      final provider = _provider(transport);

      final result = await provider.resolve(_request());

      expect(result, isA<LyricsProviderFound>());
      final found = result as LyricsProviderFound;
      expect(found.sourceId, '42');
      expect(found.plainText, 'First\nSecond');
      expect(found.syncedText, '[00:01.00]First\n[00:02.00]Second');
      expect(found.matchedDurationMs, 180000);
      expect(transport.requests, hasLength(1));
      expect(
        transport.requests.single.headers['User-Agent'],
        LrclibLyricsProvider.userAgent,
      );
      expect(
        transport.requests.single.queryParameters,
        containsPair('duration', 180),
      );
    },
  );

  test('uses one conservative search fallback after get returns 404', () async {
    final transport = _Transport([
      const _Reply(404, {'code': 404}),
      _Reply(200, [_record()]),
    ]);

    final result = await _provider(transport).resolve(_request());

    expect(result, isA<LyricsProviderFound>());
    expect(transport.requests.map((request) => Uri.parse(request.path).path), [
      '/api/get',
      '/api/search',
    ]);
    expect(
      transport.requests.last.queryParameters.containsKey('duration'),
      isFalse,
    );
  });

  test('returns instrumental as a distinct typed result', () async {
    final transport = _Transport([
      _Reply(200, _record(instrumental: true, plainLyrics: null)),
    ]);

    final result = await _provider(transport).resolve(_request());

    expect(result, isA<LyricsProviderInstrumental>());
    expect((result as LyricsProviderInstrumental).sourceId, '42');
  });

  test('returns not found after get 404 and empty search', () async {
    final transport = _Transport([
      const _Reply(404, {'code': 404}),
      const _Reply(200, []),
    ]);

    expect(
      await _provider(transport).resolve(_request()),
      isA<LyricsProviderNotFound>(),
    );
  });

  test('surfaces 429 Retry-After without retrying', () async {
    final transport = _Transport([
      const _Reply(429, {'code': 429}, headers: {'retry-after': '12'}),
    ]);

    final result = await _provider(transport).resolve(_request());

    expect(result, isA<LyricsProviderTemporaryFailure>());
    expect(
      (result as LyricsProviderTemporaryFailure).code,
      'lrclib_rate_limited',
    );
    expect(result.retryAfter, const Duration(seconds: 12));
    expect(transport.requests, hasLength(1));
  });

  test('maps timeout to a temporary failure', () async {
    final transport = _Transport([const _Reply.timeout()]);

    final result = await _provider(transport).resolve(_request());

    expect(result, isA<LyricsProviderTemporaryFailure>());
    expect((result as LyricsProviderTemporaryFailure).code, 'lrclib_network');
  });

  test('maps malformed response to a permanent failure', () async {
    final transport = _Transport([
      const _Reply(200, {'id': 42, 'trackName': 'Song'}),
    ]);

    final result = await _provider(transport).resolve(_request());

    expect(result, isA<LyricsProviderPermanentFailure>());
    expect(
      (result as LyricsProviderPermanentFailure).code,
      'lrclib_malformed_response',
    );
  });

  test('throttles sequential get and search calls', () async {
    var now = DateTime.utc(2026);
    final delays = <Duration>[];
    final transport = _Transport([
      const _Reply(404, {'code': 404}),
      const _Reply(200, []),
    ]);
    final provider = LrclibLyricsProvider(
      dio: transport.dio,
      clock: () => now,
      delay: (duration) async {
        delays.add(duration);
        now = now.add(duration);
      },
    );

    await provider.resolve(_request());

    expect(delays, [const Duration(milliseconds: 350)]);
  });
}

LrclibLyricsProvider _provider(_Transport transport) => LrclibLyricsProvider(
  dio: transport.dio,
  minimumRequestInterval: Duration.zero,
);

LyricsRequest _request() => LyricsRequest(
  trackId: 'track-1',
  title: 'Artist - Song (Official Audio)',
  artists: const ['Uploader'],
  album: 'Album',
  duration: const Duration(minutes: 3),
);

Map<String, dynamic> _record({
  bool instrumental = false,
  String? plainLyrics = 'First\nSecond',
}) => {
  'id': 42,
  'name': 'Song',
  'trackName': 'Song',
  'artistName': 'Artist',
  'albumName': 'Album',
  'duration': 180,
  'instrumental': instrumental,
  'plainLyrics': plainLyrics,
  'syncedLyrics': instrumental ? null : '[00:01.00]First\n[00:02.00]Second',
};

class _Reply {
  const _Reply(this.statusCode, this.data, {this.headers = const {}})
    : timeout = false;

  const _Reply.timeout()
    : statusCode = null,
      data = null,
      headers = const {},
      timeout = true;

  final int? statusCode;
  final dynamic data;
  final Map<String, String> headers;
  final bool timeout;
}

class _Transport {
  _Transport(List<_Reply> replies) : _replies = [...replies] {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final reply = _replies.removeAt(0);
          if (reply.timeout) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.receiveTimeout,
              ),
            );
            return;
          }
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: reply.statusCode,
              data: reply.data,
              headers: Headers.fromMap({
                for (final entry in reply.headers.entries)
                  entry.key: [entry.value],
              }),
            ),
          );
        },
      ),
    );
  }

  final Dio dio = Dio();
  final List<_Reply> _replies;
  final List<RequestOptions> requests = [];
}
