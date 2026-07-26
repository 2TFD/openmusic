import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/network/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test('retries 429 and uses Retry-After', () async {
      var attempts = 0;
      final delays = <Duration>[];
      final policy = RetryPolicy(
        delay: (duration) async => delays.add(duration),
      );

      final result = await policy.execute(() async {
        attempts++;
        if (attempts == 1) {
          throw _responseError(
            429,
            headers: Headers.fromMap({
              'retry-after': ['0'],
            }),
          );
        }
        return 42;
      });

      expect(result, 42);
      expect(attempts, 2);
      expect(delays, [Duration.zero]);
    });

    test('retries transient failures only up to maxAttempts', () async {
      var attempts = 0;
      final policy = RetryPolicy(maxAttempts: 3, delay: (_) async {});

      await expectLater(
        policy.execute<void>(() async {
          attempts++;
          throw _responseError(503);
        }),
        throwsA(isA<DioException>()),
      );

      expect(attempts, 3);
    });

    test('does not retry non-transient client errors', () async {
      var attempts = 0;
      final policy = RetryPolicy(delay: (_) async {});

      await expectLater(
        policy.execute<void>(() async {
          attempts++;
          throw _responseError(400);
        }),
        throwsA(isA<DioException>()),
      );

      expect(attempts, 1);
    });
  });

  group('failureFromException', () {
    test('keeps typed failures unchanged', () {
      const failure = NotFoundFailure('track', 'id');
      expect(failureFromException(failure), same(failure));
    });

    test('does not classify arbitrary messages by string matching', () {
      expect(
        failureFromException(Exception('sqlite video unavailable')),
        isA<UnknownFailure>(),
      );
    });
  });
}

DioException _responseError(int statusCode, {Headers? headers}) {
  final request = RequestOptions(path: '/test');
  return DioException.badResponse(
    statusCode: statusCode,
    requestOptions: request,
    response: Response<void>(
      requestOptions: request,
      statusCode: statusCode,
      headers: headers,
    ),
  );
}
