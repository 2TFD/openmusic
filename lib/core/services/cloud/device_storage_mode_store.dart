import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local choice: how this installation keeps OwlSonic audio.
/// Not an account preference; never synced.
enum DeviceStorageMode {
  /// Stream cloud tracks; played tracks are kept in a size-limited cache.
  stream,

  /// Download the whole cloud library to this device, with embedded title,
  /// artist, album and cover, so it plays without a connection.
  offline;

  static DeviceStorageMode? parse(String? value) => switch (value) {
    'stream' => stream,
    'offline' => offline,
    _ => null,
  };
}

class DeviceStorageModeStore {
  DeviceStorageModeStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'owlsonic.device_storage_mode';
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  /// The mode in effect, for services that must not wait on preferences
  /// (playback resolves it on every byte-range request). Filled by [load] and
  /// [save]; null until loaded.
  final current = ValueNotifier<DeviceStorageMode?>(null);

  /// The mode used when the user has not chosen yet (mobile never asks).
  static const fallback = DeviceStorageMode.stream;

  DeviceStorageMode get effective => current.value ?? fallback;

  /// Null until the user has chosen on this device.
  Future<DeviceStorageMode?> load() async {
    final mode = DeviceStorageMode.parse(await _instance.getString(key));
    current.value = mode;
    return mode;
  }

  Future<void> save(DeviceStorageMode mode) async {
    await _instance.setString(key, mode.name);
    current.value = mode;
  }
}
