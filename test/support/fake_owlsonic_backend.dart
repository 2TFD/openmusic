import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/auth_token_store.dart';
import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_client.dart';
import 'package:owlsonic/core/network/owlsonic/pending_verification_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/auth_challenge.dart';

class RecordedRequest {
  RecordedRequest(this.method, this.path, this.query, this.headers, this.body);
  final String method;
  final String path;
  final Map<String, dynamic> query;
  final Map<String, dynamic> headers;
  final Object? body;

  String? get bearer {
    final value = headers['Authorization'] as String?;
    return value?.replaceFirst('Bearer ', '');
  }

  Map<String, dynamic> get json => Map<String, dynamic>.from(body as Map);
}

class FakeReply {
  const FakeReply(this.status, [this.body, this.headers = const {}]);
  final int status;
  final Object? body;
  final Map<String, List<String>> headers;

  static FakeReply error(
    int status,
    String code, {
    bool retryable = false,
    String requestId = 'req-1',
    Map<String, List<String>> headers = const {},
  }) => FakeReply(status, {
    'error': {
      'code': code,
      'message': 'Server said $code',
      'retryable': retryable,
      'request_id': requestId,
      'details': [],
    },
  }, headers);
}

typedef FakeHandler = FutureOr<FakeReply> Function(RecordedRequest request);

/// In-process HTTP adapter: routes by "METHOD /path" and records requests.
class FakeOwlSonicBackend implements HttpClientAdapter {
  final requests = <RecordedRequest>[];
  final _routes = <String, FakeHandler>{};
  bool offline = false;

  void on(String route, FakeHandler handler) => _routes[route] = handler;

  List<RecordedRequest> to(String route) => requests
      .where((request) => '${request.method} ${request.path}' == route)
      .toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    Object? body = options.data;
    if (body is FormData) {
      body = {
        'fields': {for (final f in body.fields) f.key: f.value},
        'files': {
          for (final f in body.files)
            f.key: {
              'filename': f.value.filename,
              'contentType': f.value.contentType?.mimeType,
            },
        },
      };
      await requestStream?.drain<void>();
    }
    final request = RecordedRequest(
      options.method,
      options.path,
      options.queryParameters,
      options.headers,
      body,
    );
    requests.add(request);
    final handler = _routes['${options.method} ${options.path}'];
    final reply = handler == null
        ? FakeReply.error(404, 'not_found')
        : await handler(request);
    final bytes = reply.body == null
        ? Uint8List(0)
        : utf8.encode(jsonEncode(reply.body));
    return ResponseBody.fromBytes(
      bytes,
      reply.status,
      headers: {
        if (reply.body != null)
          Headers.contentTypeHeader: [Headers.jsonContentType],
        ...reply.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class MemoryTokenStore implements AuthTokenStore {
  AuthTokens? tokens;
  int writes = 0;

  @override
  Future<void> clear() async => tokens = null;
  @override
  Future<AuthTokens?> read() async => tokens;
  @override
  Future<void> write(AuthTokens value) async {
    writes++;
    tokens = value;
  }
}

class MemoryInstallationIdStorage implements InstallationIdStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String next) async => value = next;
}

class MemoryPendingVerificationStore implements PendingVerificationStore {
  PendingVerification? value;
  @override
  Future<PendingVerification?> read() async => value;
  @override
  Future<void> write(PendingVerification pending) async => value = pending;
  @override
  Future<void> clear() async => value = null;
}

final fakeNow = DateTime.utc(2026, 10, 7, 12);

Map<String, Object?> credentials({
  String access = 'access-2',
  String refresh = 'refresh-2',
  int expiresIn = 900,
}) => {
  'access_token': access,
  'refresh_token': refresh,
  'access_expires_in': expiresIn,
  'refresh_expires_at': '2026-11-07T12:00:00Z',
  'token_type': 'bearer',
};

AuthTokens tokens({
  String access = 'access-1',
  String refresh = 'refresh-1',
  DateTime? accessExpiresAt,
}) => AuthTokens(
  accessToken: access,
  refreshToken: refresh,
  accessExpiresAt: accessExpiresAt ?? fakeNow.add(const Duration(minutes: 10)),
  refreshExpiresAt: fakeNow.add(const Duration(days: 30)),
);

class FakeCloud {
  FakeCloud({AuthTokens? initialTokens}) {
    store.tokens = initialTokens;
    final dio = Dio(BaseOptions(responseType: ResponseType.json))
      ..httpClientAdapter = backend;
    session = AuthSession(store: store, now: () => fakeNow);
    client = OwlSonicApiClient(
      config: OwlSonicApiConfig(
        environment: OwlSonicEnvironment.development,
        baseUrl: 'https://api.test',
      ),
      session: session,
      dio: dio,
      now: () => fakeNow,
    );
  }

  final backend = FakeOwlSonicBackend();
  final store = MemoryTokenStore();
  late final AuthSession session;
  late final OwlSonicApiClient client;
}

Map<String, Object?> libraryItemJson({
  String id = '00000000-0000-0000-0000-000000000001',
  String analysisStatus = 'pending',
  bool favorite = false,
  String? customTitle,
}) => {
  'id': id,
  'title': 'Song',
  'artist_name': 'Artist',
  'album_title': 'Album',
  'album_artist': null,
  'track_number': 1,
  'disc_number': null,
  'year': 2024,
  'genres': ['ambient'],
  'duration_ms': 180000,
  'has_artwork': true,
  'analysis_status': analysisStatus,
  'custom_title': customTitle,
  'custom_artist_name': null,
  'custom_album_title': null,
  'added_at': '2026-10-01T10:00:00Z',
  'updated_at': '2026-10-02T10:00:00Z',
  'favorite': favorite,
  'custom_valence': null,
  'custom_arousal': 0.4,
  'play_count': 3,
  'last_played_at': null,
};
