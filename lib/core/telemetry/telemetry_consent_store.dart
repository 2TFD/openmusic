import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TelemetryConsentStore {
  Future<bool> load();
  Future<void> save(bool enabled);
}

final class SharedPreferencesTelemetryConsentStore
    implements TelemetryConsentStore {
  SharedPreferencesTelemetryConsentStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'telemetry.crash_reporting.enabled';

  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<bool> load() async => await _instance.getBool(key) ?? false;

  @override
  Future<void> save(bool enabled) => _instance.setBool(key, enabled);
}
