import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:openmusic/core/errors/failures/failure.dart';

class SpotifyAuthConfig {
  const SpotifyAuthConfig({
    this.clientId = const String.fromEnvironment('SPOTIFY_CLIENT_ID'),
    this.redirectUri = 'openmusic-spotify-login://callback',
  });

  final String clientId;
  final String redirectUri;

  bool get isConfigured => clientId.trim().isNotEmpty;
}

class SpotifyToken {
  const SpotifyToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool get shouldRefresh =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 1)));

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory SpotifyToken.fromJson(Map<String, dynamic> json) => SpotifyToken(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

abstract class SpotifyTokenStore {
  Future<SpotifyToken?> read();
  Future<void> write(SpotifyToken token);
  Future<void> clear();
}

class SecureSpotifyTokenStore implements SpotifyTokenStore {
  SecureSpotifyTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'spotify_oauth_token_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<SpotifyToken?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return SpotifyToken.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(SpotifyToken token) =>
      _storage.write(key: _key, value: jsonEncode(token.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

typedef SpotifyAuthenticate =
    Future<String> Function(String url, String callbackScheme);

class SpotifyAuthService {
  SpotifyAuthService({
    required SpotifyAuthConfig config,
    required SpotifyTokenStore tokenStore,
    Dio? dio,
    SpotifyAuthenticate? authenticate,
  }) : _config = config,
       _tokenStore = tokenStore,
       _dio = dio ?? Dio(),
       _authenticate =
           authenticate ??
           ((url, scheme) => FlutterWebAuth2.authenticate(
             url: url,
             callbackUrlScheme: scheme,
           ));

  final SpotifyAuthConfig _config;
  final SpotifyTokenStore _tokenStore;
  final Dio _dio;
  final SpotifyAuthenticate _authenticate;

  bool get isConfigured => _config.isConfigured;

  Future<bool> get isConnected async => await _tokenStore.read() != null;

  Future<String> accessToken({bool forceLogin = false}) async {
    if (!_config.isConfigured) {
      throw const ValidationFailure('SPOTIFY_CLIENT_ID');
    }
    var token = forceLogin ? null : await _tokenStore.read();
    if (token == null) return _authorize();
    if (!token.shouldRefresh) return token.accessToken;
    token = await _refresh(token.refreshToken);
    return token.accessToken;
  }

  Future<String> refreshAccessToken() async {
    final token = await _tokenStore.read();
    if (token == null) return _authorize();
    return (await _refresh(token.refreshToken)).accessToken;
  }

  Future<void> disconnect() => _tokenStore.clear();

  Future<String> _authorize() async {
    final verifier = _randomUrlSafe(64);
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    final state = _randomUrlSafe(24);
    final redirect = Uri.parse(_config.redirectUri);
    final authUri = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': _config.clientId,
      'response_type': 'code',
      'redirect_uri': _config.redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'state': state,
      'scope': 'playlist-read-private playlist-read-collaborative',
    });
    final callback = Uri.parse(
      await _authenticate(authUri.toString(), redirect.scheme),
    );
    if (callback.queryParameters['state'] != state) {
      throw const RemoteAccessFailure();
    }
    final error = callback.queryParameters['error'];
    if (error != null) throw RemoteServiceFailure('Spotify OAuth: $error');
    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) throw const ParseFailure();

    final response = await _dio.post<Map<String, dynamic>>(
      'https://accounts.spotify.com/api/token',
      data: {
        'client_id': _config.clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _config.redirectUri,
        'code_verifier': verifier,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final token = _tokenFromResponse(response.data, fallbackRefresh: null);
    await _tokenStore.write(token);
    return token.accessToken;
  }

  Future<SpotifyToken> _refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://accounts.spotify.com/api/token',
        data: {
          'client_id': _config.clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final token = _tokenFromResponse(
        response.data,
        fallbackRefresh: refreshToken,
      );
      await _tokenStore.write(token);
      return token;
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        await _tokenStore.clear();
        await _authorize();
        final token = await _tokenStore.read();
        if (token == null) throw const RemoteAccessFailure();
        return token;
      }
      rethrow;
    }
  }

  static SpotifyToken _tokenFromResponse(
    Map<String, dynamic>? data, {
    required String? fallbackRefresh,
  }) {
    final access = data?['access_token'] as String?;
    final refresh = data?['refresh_token'] as String? ?? fallbackRefresh;
    final expiresIn = data?['expires_in'] as int? ?? 3600;
    if (access == null || refresh == null) throw const ParseFailure();
    return SpotifyToken(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  static String _randomUrlSafe(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
