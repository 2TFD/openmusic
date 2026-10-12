import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract interface class InstallationIdStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class SharedPreferencesInstallationIdStorage implements InstallationIdStorage {
  SharedPreferencesInstallationIdStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'owlsonic.installation_id';
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> read() => _instance.getString(key);
  @override
  Future<void> write(String value) => _instance.setString(key, value);
}

/// Stable per-installation identifier sent as `device.installation_id`.
/// Generated once and reused across launches; not a secret.
class InstallationIdentity {
  InstallationIdentity({
    InstallationIdStorage? storage,
    String Function()? generate,
  }) : _storage = storage ?? SharedPreferencesInstallationIdStorage(),
       _generate = generate ?? (() => const Uuid().v4());

  final InstallationIdStorage _storage;
  final String Function() _generate;
  Future<String>? _cached;

  Future<String> installationId() => _cached ??= _loadOrCreate();

  Future<String> _loadOrCreate() async {
    try {
      final existing = await _storage.read();
      if (existing != null && existing.isNotEmpty) return existing;
      final created = _generate();
      await _storage.write(created);
      return created;
    } catch (_) {
      _cached = null;
      rethrow;
    }
  }

  static String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return Platform.operatingSystem;
  }

  static String? get deviceName {
    try {
      final name = Platform.localHostname.trim();
      return name.isEmpty ? null : name;
    } catch (_) {
      return null;
    }
  }
}
