import 'package:dio/dio.dart';

typedef RetryDelay = Future<void> Function(Duration duration);

class RetryPolicy {
  RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 300),
    RetryDelay? delay,
  }) : assert(maxAttempts > 0),
       _delay = delay ?? Future<void>.delayed;

  final int maxAttempts;
  final Duration initialDelay;
  final RetryDelay _delay;

  Future<T> execute<T>(Future<T> Function() operation) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await operation();
      } on DioException catch (error) {
        if (attempt >= maxAttempts || !_isRetryable(error)) rethrow;
        await _delay(_delayFor(error, attempt));
      }
    }
  }

  bool _isRetryable(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse =>
        error.response?.statusCode == 429 ||
            (error.response?.statusCode ?? 0) >= 500,
      DioExceptionType.cancel ||
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown => false,
    };
  }

  Duration _delayFor(DioException error, int attempt) {
    final retryAfter = int.tryParse(
      error.response?.headers.value('retry-after') ?? '',
    );
    if (retryAfter != null && retryAfter >= 0) {
      return Duration(seconds: retryAfter);
    }
    return initialDelay * (1 << (attempt - 1));
  }
}
