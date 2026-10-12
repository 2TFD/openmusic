import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingStore {
  Future<bool> load();
  Future<void> save(bool completed);
}

class SharedPreferencesOnboardingStore implements OnboardingStore {
  SharedPreferencesOnboardingStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'onboarding.completed';

  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<bool> load() async {
    return await _instance.getBool(key) ?? false;
  }

  @override
  Future<void> save(bool completed) async {
    await _instance.setBool(key, completed);
  }
}
