import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:owlsonic/core/utils/secure_storage_options.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  /// Maps the backend CredentialsResponse. `access_expires_in` is relative to
  /// [receivedAt]; `refresh_expires_at` is absolute.
  factory AuthTokens.fromCredentials(
    Map<String, dynamic> json, {
    required DateTime receivedAt,
  }) {
    final accessToken = json['access_token'];
    final refreshToken = json['refresh_token'];
    final expiresIn = json['access_expires_in'];
    final refreshExpiresAt = DateTime.tryParse(
      json['refresh_expires_at'] as String? ?? '',
    );
    if (accessToken is! String ||
        refreshToken is! String ||
        expiresIn is! num ||
        refreshExpiresAt == null) {
      throw const FormatException('Invalid CredentialsResponse');
    }
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiresAt: receivedAt.add(Duration(seconds: expiresIn.toInt())),
      refreshExpiresAt: refreshExpiresAt.toUtc(),
    );
  }

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  bool accessExpiresSoon(
    DateTime now, {
    Duration skew = const Duration(seconds: 30),
  }) => !now.isBefore(accessExpiresAt.subtract(skew));

  bool refreshExpired(DateTime now) => !now.isBefore(refreshExpiresAt);

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessExpiresAt': accessExpiresAt.toUtc().toIso8601String(),
    'refreshExpiresAt': refreshExpiresAt.toUtc().toIso8601String(),
  };

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    accessExpiresAt: DateTime.parse(json['accessExpiresAt'] as String),
    refreshExpiresAt: DateTime.parse(json['refreshExpiresAt'] as String),
  );

  @override
  String toString() => 'AuthTokens(<redacted>)';
}

abstract interface class AuthTokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

/// Keeps OwlSonic credentials in the OS keychain/keystore only.
class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ?? const FlutterSecureStorage(mOptions: macOsKeychainOptions);

  static const _key = 'owlsonic_auth_tokens_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    final value = await _storage.read(key: _key);
    if (value == null || value.isEmpty) return null;
    try {
      return AuthTokens.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthTokens tokens) =>
      _storage.write(key: _key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
