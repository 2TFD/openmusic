import 'package:dio/dio.dart';

enum OwlSonicApiErrorKind {
  /// The backend answered with an ErrorResponse / non-2xx status.
  server,

  /// No usable response: DNS, socket, TLS or timeout.
  network,

  /// Request was cancelled by the client.
  cancelled,

  /// Session missing or rejected after the single refresh attempt.
  unauthorized,

  /// Cloud mode is not configured for this build.
  notConfigured,

  /// The response could not be decoded into the documented schema.
  invalidResponse,
}

/// Structured representation of the backend ErrorResponse:
/// `{"error": {"code", "message", "retryable", "request_id", "details"}}`.
class OwlSonicApiException implements Exception {
  const OwlSonicApiException({
    required this.kind,
    required this.code,
    required this.message,
    required this.retryable,
    this.statusCode,
    this.requestId,
    this.details = const [],
    this.retryAfter,
  });

  final OwlSonicApiErrorKind kind;
  final int? statusCode;
  final String code;
  final String message;
  final bool retryable;
  final String? requestId;
  final List<Object?> details;
  final Duration? retryAfter;

  bool get isUnauthorized =>
      kind == OwlSonicApiErrorKind.unauthorized || statusCode == 401;
  bool get isNetwork => kind == OwlSonicApiErrorKind.network;
  bool get isCancelled => kind == OwlSonicApiErrorKind.cancelled;

  /// `type` ids from the validation `details` entries, optionally restricted
  /// to a field (`field` is matched against the last `loc` segment).
  Iterable<String> validationTypes({String? field}) sync* {
    for (final detail in details) {
      if (detail is! Map || detail['type'] is! String) continue;
      final loc = detail['loc'];
      if (field != null &&
          !(loc is List && loc.isNotEmpty && loc.last == field)) {
        continue;
      }
      yield detail['type'] as String;
    }
  }

  bool hasValidation(String type, {String? field}) =>
      validationTypes(field: field).contains(type);

  static const notConfigured = OwlSonicApiException(
    kind: OwlSonicApiErrorKind.notConfigured,
    code: 'client_not_configured',
    message: 'OwlSonic cloud is not configured for this build',
    retryable: false,
  );

  static const signedOut = OwlSonicApiException(
    kind: OwlSonicApiErrorKind.unauthorized,
    code: 'signed_out',
    message: 'Sign in to OwlSonic to continue',
    retryable: false,
    statusCode: 401,
  );

  /// The request belonged to a session that ended (sign-out or another
  /// account signed in) before it completed. Its result is discarded.
  static const sessionChanged = OwlSonicApiException(
    kind: OwlSonicApiErrorKind.cancelled,
    code: 'session_changed',
    message: 'The OwlSonic session changed during the request',
    retryable: false,
  );

  factory OwlSonicApiException.fromDio(DioException error) {
    final response = error.response;
    switch (error.type) {
      case DioExceptionType.cancel:
        return const OwlSonicApiException(
          kind: OwlSonicApiErrorKind.cancelled,
          code: 'cancelled',
          message: 'Request cancelled',
          retryable: false,
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const OwlSonicApiException(
          kind: OwlSonicApiErrorKind.network,
          code: 'timeout',
          message: 'The OwlSonic server did not respond in time',
          retryable: true,
        );
      case DioExceptionType.connectionError:
        return const OwlSonicApiException(
          kind: OwlSonicApiErrorKind.network,
          code: 'network_unavailable',
          message: 'Cannot reach the OwlSonic server',
          retryable: true,
        );
      case DioExceptionType.badCertificate:
        return const OwlSonicApiException(
          kind: OwlSonicApiErrorKind.network,
          code: 'bad_certificate',
          message: 'The OwlSonic server certificate was rejected',
          retryable: false,
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        if (response == null) {
          return const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.network,
            code: 'network_unavailable',
            message: 'Cannot reach the OwlSonic server',
            retryable: true,
          );
        }
        return OwlSonicApiException.fromResponse(
          statusCode: response.statusCode,
          data: response.data,
          headerRequestId: response.headers.value('x-request-id'),
          retryAfterHeader: response.headers.value('retry-after'),
        );
    }
  }

  /// Parses the documented ErrorResponse and FastAPI's HTTPValidationError
  /// (`{"detail": [...]}`), which the spec lists for several 422 responses.
  factory OwlSonicApiException.fromResponse({
    required int? statusCode,
    required Object? data,
    String? headerRequestId,
    String? retryAfterHeader,
  }) {
    final retryAfterSeconds = int.tryParse(retryAfterHeader?.trim() ?? '');
    final retryAfter = retryAfterSeconds == null || retryAfterSeconds < 0
        ? null
        : Duration(seconds: retryAfterSeconds);
    final kind = statusCode == 401
        ? OwlSonicApiErrorKind.unauthorized
        : OwlSonicApiErrorKind.server;

    if (data is Map && data['error'] is Map) {
      final body = data['error'] as Map;
      final details = body['details'];
      return OwlSonicApiException(
        kind: kind,
        statusCode: statusCode,
        code: body['code'] is String ? body['code'] as String : 'unknown_error',
        message: body['message'] is String
            ? body['message'] as String
            : 'Request failed',
        retryable: body['retryable'] == true,
        requestId: body['request_id'] is String
            ? body['request_id'] as String
            : headerRequestId,
        details: details is List
            ? List<Object?>.unmodifiable(details)
            : const [],
        retryAfter: retryAfter,
      );
    }

    if (data is Map && data['detail'] is List) {
      return OwlSonicApiException(
        kind: kind,
        statusCode: statusCode,
        code: 'validation_error',
        message: 'The request was rejected by validation',
        retryable: false,
        requestId: headerRequestId,
        details: List<Object?>.unmodifiable(data['detail'] as List),
      );
    }

    final status = statusCode ?? 0;
    return OwlSonicApiException(
      kind: kind,
      statusCode: statusCode,
      code: 'http_$status',
      message: 'Request failed with HTTP $status',
      retryable:
          status == 429 || status == 502 || status == 503 || status == 504,
      requestId: headerRequestId,
      retryAfter: retryAfter,
    );
  }

  @override
  String toString() {
    final status = statusCode == null ? '' : ' HTTP $statusCode';
    final request = requestId == null ? '' : ' request_id=$requestId';
    return 'OwlSonicApiException($code$status retryable=$retryable$request: '
        '$message)';
  }
}
