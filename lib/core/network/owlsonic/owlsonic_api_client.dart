import 'package:dio/dio.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/auth_token_store.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/utils/app_logger.dart';

typedef JsonMap = Map<String, dynamic>;

/// The only HTTP entry point to the OwlSonic backend.
///
/// - attaches `Authorization: Bearer` for authenticated calls;
/// - on 401 performs one shared refresh and retries the request once;
/// - converts every failure into [OwlSonicApiException];
/// - logs one line per call (method, path, status, duration, request id and,
///   on failure, the underlying transport error), never bodies, query values,
///   tokens or signed URLs.
class OwlSonicApiClient {
  OwlSonicApiClient({
    required OwlSonicApiConfig config,
    required AuthSession session,
    Dio? dio,
    DateTime Function()? now,
  }) : _config = config,
       _session = session,
       _now = now ?? (() => DateTime.now().toUtc()),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: config.connectTimeout,
               receiveTimeout: config.requestTimeout,
               sendTimeout: config.requestTimeout,
               responseType: ResponseType.json,
             ),
           ) {
    if (config.isConfigured) _dio.options.baseUrl = config.baseUrl;
    _session.bindRefresher(_refresh);
  }

  final OwlSonicApiConfig _config;
  final AuthSession _session;
  final DateTime Function() _now;
  final Dio _dio;

  bool get isConfigured => _config.isConfigured;
  AuthSession get session => _session;

  Future<JsonMap> getJson(
    String path, {
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) async =>
      _asMap(await _send('GET', path, query: query, cancelToken: cancelToken));

  Future<JsonMap> postJson(
    String path, {
    Object? body,
    bool authenticated = true,
    CancelToken? cancelToken,
  }) async => _asMap(
    await _send(
      'POST',
      path,
      body: body,
      authenticated: authenticated,
      cancelToken: cancelToken,
    ),
  );

  Future<JsonMap> patchJson(String path, {required Object body}) async =>
      _asMap(await _send('PATCH', path, body: body));

  Future<JsonMap> putJson(String path, {required Object body}) async =>
      _asMap(await _send('PUT', path, body: body));

  /// For endpoints answering 204 / 202 where the body is optional.
  Future<Object?> send(
    String method,
    String path, {
    Object? body,
    bool authenticated = true,
  }) => _send(method, path, body: body, authenticated: authenticated);

  /// Multipart upload. [buildForm] is invoked per attempt because a FormData
  /// stream cannot be replayed after a 401 retry.
  Future<JsonMap> postMultipart(
    String path, {
    required Future<FormData> Function() buildForm,
    Map<String, String> headers = const {},
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async => _asMap(
    await _send(
      'POST',
      path,
      formBuilder: buildForm,
      headers: headers,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      timeout: _config.uploadTimeout,
    ),
  );

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    Future<FormData> Function()? formBuilder,
    Map<String, String> headers = const {},
    bool authenticated = true,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    if (!_config.isConfigured) throw OwlSonicApiException.notConfigured;

    var attempt = 0;
    Future<Object?> perform(String? token) async {
      final stopwatch = Stopwatch()..start();
      final tag = '$method $path#${++attempt}';
      try {
        final response = await _dio.request<Object?>(
          path,
          data: formBuilder != null ? await formBuilder() : body,
          queryParameters: query == null
              ? null
              : {
                  for (final entry in query.entries)
                    if (entry.value != null) entry.key: entry.value,
                },
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          options: Options(
            method: method,
            sendTimeout: timeout,
            receiveTimeout: timeout,
            headers: {
              ...headers,
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          ),
        );
        _logCall(
          tag,
          stopwatch,
          status: response.statusCode,
          requestId: response.headers.value('x-request-id'),
        );
        return response.data;
      } on DioException catch (error) {
        final failure = OwlSonicApiException.fromDio(error);
        _logCall(
          tag,
          stopwatch,
          status: error.response?.statusCode,
          requestId:
              failure.requestId ??
              error.response?.headers.value('x-request-id'),
          error: error,
          failure: failure,
        );
        throw failure;
      }
    }

    if (!authenticated) return perform(null);

    // The session this request belongs to: the one a background job was bound
    // to, else the current one. Its token, retry and result never cross into
    // another session (sign-out, or account B signing in after A).
    final epoch = _session.boundEpoch ?? _session.epoch;
    void ensureSameSession() {
      if (_session.epoch != epoch) throw OwlSonicApiException.sessionChanged;
    }

    ensureSameSession();
    final token = await _session.accessToken();
    if (token == null) throw OwlSonicApiException.signedOut;
    ensureSameSession();
    try {
      final result = await perform(token);
      ensureSameSession();
      return result;
    } on OwlSonicApiException catch (error) {
      if (error.statusCode != 401) rethrow;
      ensureSameSession();
      final next = await _session.refreshAfterUnauthorized(token, epoch: epoch);
      if (next == null) throw OwlSonicApiException.signedOut;
      ensureSameSession();
      // Exactly one retry; a second 401 is surfaced, never looped.
      final result = await perform(next);
      ensureSameSession();
      return result;
    }
  }

  /// `fromDio` folds DNS, TLS, reset and timeout failures into one network
  /// error; this keeps the real cause (Dio type and the underlying exception,
  /// e.g. `HandshakeException`, `SocketException`) for diagnosis.
  void _logCall(
    String tag,
    Stopwatch stopwatch, {
    int? status,
    String? requestId,
    DioException? error,
    OwlSonicApiException? failure,
  }) {
    final ms = stopwatch.elapsedMilliseconds;
    final id = requestId == null ? '' : ' request_id=$requestId';
    if (error == null) {
      AppLogger.info(
        '[OwlSonicApi] $tag -> $status in ${ms}ms$id',
        operation: 'owlsonic.api',
      );
      return;
    }
    final cause = error.error;
    final causeText = cause == null
        ? ''
        : ' cause=${cause.runtimeType}: ${_trim('$cause')}';
    AppLogger.warning(
      '[OwlSonicApi] $tag FAILED in ${ms}ms status=$status$id '
      'dio=${error.type.name} code=${failure?.code} '
      'retryable=${failure?.retryable}$causeText',
      operation: 'owlsonic.api',
    );
  }

  static String _trim(String value) {
    final line = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return line.length > 240 ? '${line.substring(0, 240)}…' : line;
  }

  Future<AuthTokens> _refresh(String refreshToken) async {
    final receivedAt = _now();
    final json = await postJson(
      '/v1/auth/refresh',
      body: {'refresh_token': refreshToken},
      authenticated: false,
    );
    return parseCredentials(json, receivedAt: receivedAt);
  }

  static AuthTokens parseCredentials(
    JsonMap json, {
    required DateTime receivedAt,
  }) {
    try {
      return AuthTokens.fromCredentials(json, receivedAt: receivedAt);
    } on FormatException {
      throw invalidResponse('CredentialsResponse');
    }
  }

  static OwlSonicApiException invalidResponse(String schema) =>
      OwlSonicApiException(
        kind: OwlSonicApiErrorKind.invalidResponse,
        code: 'invalid_response',
        message: 'Unexpected $schema from the OwlSonic server',
        retryable: false,
      );

  static JsonMap _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw invalidResponse('response body');
  }
}
