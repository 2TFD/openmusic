import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:owlsonic/layers/domain/entities/cloud/auth_challenge.dart';

abstract interface class PendingVerificationStore {
  Future<PendingVerification?> read();
  Future<void> write(PendingVerification pending);
  Future<void> clear();
}

/// E-mail, installation id and timing only: none of it is a credential, and
/// the code itself is never stored.
class SharedPreferencesPendingVerificationStore
    implements PendingVerificationStore {
  SharedPreferencesPendingVerificationStore({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences;

  static const key = 'owlsonic.pending_verification';
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<PendingVerification?> read() async {
    try {
      final value = await _instance.getString(key);
      if (value == null || value.isEmpty) return null;
      return PendingVerification.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(PendingVerification pending) =>
      _instance.setString(key, jsonEncode(pending.toJson()));

  @override
  Future<void> clear() => _instance.remove(key);
}
