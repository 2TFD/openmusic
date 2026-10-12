import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';

void main() {
  test('parses ErrorResponse fields verbatim', () {
    final error = OwlSonicApiException.fromResponse(
      statusCode: 503,
      data: {
        'error': {
          'code': 'storage_unavailable',
          'message': 'Try later',
          'retryable': true,
          'request_id': 'req-9',
          'details': [
            {'field': 'audio'},
          ],
        },
      },
      retryAfterHeader: '7',
    );

    expect(error.kind, OwlSonicApiErrorKind.server);
    expect(error.code, 'storage_unavailable');
    expect(error.message, 'Try later');
    expect(error.retryable, isTrue);
    expect(error.requestId, 'req-9');
    expect(error.details, hasLength(1));
    expect(error.retryAfter, const Duration(seconds: 7));
  });

  test('non-retryable flag is respected even for 5xx', () {
    final error = OwlSonicApiException.fromResponse(
      statusCode: 500,
      data: {
        'error': {
          'code': 'internal',
          'message': 'x',
          'retryable': false,
          'request_id': null,
        },
      },
      headerRequestId: 'hdr-1',
    );
    expect(error.retryable, isFalse);
    expect(error.requestId, 'hdr-1');
  });

  test('FastAPI validation errors map to validation_error', () {
    final error = OwlSonicApiException.fromResponse(
      statusCode: 422,
      data: {
        'detail': [
          {
            'loc': ['body', 'email'],
            'msg': 'bad',
            'type': 'value_error',
          },
        ],
      },
    );
    expect(error.code, 'validation_error');
    expect(error.retryable, isFalse);
    expect(error.details, hasLength(1));
  });

  test('401 is classified as unauthorized', () {
    final error = OwlSonicApiException.fromResponse(
      statusCode: 401,
      data: null,
    );
    expect(error.isUnauthorized, isTrue);
  });

  test('transport failures are retryable network errors', () {
    final error = OwlSonicApiException.fromDio(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/v1/me'),
        reason: 'down',
      ),
    );
    expect(error.isNetwork, isTrue);
    expect(error.retryable, isTrue);
  });

  test('cancelled requests are not retryable', () {
    final error = OwlSonicApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/v1/tracks'),
        type: DioExceptionType.cancel,
      ),
    );
    expect(error.isCancelled, isTrue);
    expect(error.retryable, isFalse);
  });

  test('config requires an explicit base URL', () {
    final unset = OwlSonicApiConfig(
      environment: OwlSonicEnvironment.production,
    );
    expect(unset.isConfigured, isFalse);
    final set = OwlSonicApiConfig(
      environment: OwlSonicEnvironment.parse('prod'),
      baseUrl: 'https://api.example/',
    );
    expect(set.environment, OwlSonicEnvironment.production);
    expect(set.baseUrl, 'https://api.example');
    expect(
      () => OwlSonicApiConfig(
        environment: OwlSonicEnvironment.development,
        baseUrl: 'ftp://x',
      ),
      throwsArgumentError,
    );
  });
}
