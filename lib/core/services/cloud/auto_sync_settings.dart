import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AutoSyncPrefs {
  const AutoSyncPrefs({this.enabled = true, this.wifiOnly = false});

  /// Send imported music and playlists to OwlSonic automatically.
  final bool enabled;

  /// Upload only on Wi-Fi / Ethernet, never over mobile data.
  final bool wifiOnly;

  AutoSyncPrefs copyWith({bool? enabled, bool? wifiOnly}) => AutoSyncPrefs(
    enabled: enabled ?? this.enabled,
    wifiOnly: wifiOnly ?? this.wifiOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is AutoSyncPrefs &&
      other.enabled == enabled &&
      other.wifiOnly == wifiOnly;

  @override
  int get hashCode => Object.hash(enabled, wifiOnly);
}

/// Device-local switches for automatic upload. Not synced between devices.
class AutoSyncSettings {
  AutoSyncSettings({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const enabledKey = 'owlsonic.auto_sync.enabled';
  static const wifiOnlyKey = 'owlsonic.auto_sync.wifi_only';

  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  /// The values in effect; defaults until [load] finishes.
  final current = ValueNotifier<AutoSyncPrefs>(const AutoSyncPrefs());

  Future<AutoSyncPrefs> load() async {
    final prefs = AutoSyncPrefs(
      enabled: await _instance.getBool(enabledKey) ?? true,
      wifiOnly: await _instance.getBool(wifiOnlyKey) ?? false,
    );
    current.value = prefs;
    return prefs;
  }

  Future<void> setEnabled(bool value) async {
    await _instance.setBool(enabledKey, value);
    current.value = current.value.copyWith(enabled: value);
  }

  Future<void> setWifiOnly(bool value) async {
    await _instance.setBool(wifiOnlyKey, value);
    current.value = current.value.copyWith(wifiOnly: value);
  }
}

/// What kind of connection the device has right now.
abstract interface class NetworkProbe {
  /// True when the device is online over Wi-Fi or Ethernet.
  Future<bool> isUnmetered();

  /// Emits whenever the connection changes.
  Stream<void> get changes;
}

class ConnectivityNetworkProbe implements NetworkProbe {
  ConnectivityNetworkProbe([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isUnmetered() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  @override
  Stream<void> get changes => _connectivity.onConnectivityChanged.map((_) {});
}

/// Whether automatic upload may run right now.
class AutoSyncPolicy {
  AutoSyncPolicy({required this.settings, required NetworkProbe network})
    : _network = network;

  final AutoSyncSettings settings;
  final NetworkProbe _network;

  AutoSyncPrefs get prefs => settings.current.value;

  Stream<void> get networkChanges => _network.changes;

  /// The switch is on and, with "Wi-Fi only", the connection is not mobile.
  /// Being offline entirely is left to the uploads themselves (they retry).
  Future<bool> allowsUploadNow() async {
    final prefs = this.prefs;
    if (!prefs.enabled) return false;
    if (!prefs.wifiOnly) return true;
    return _network.isUnmetered();
  }
}
