import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class FirstPlaybackStore {
  Future<bool> load();
  Future<void> save(bool started);
}

final class SharedPreferencesFirstPlaybackStore implements FirstPlaybackStore {
  SharedPreferencesFirstPlaybackStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  static const key = 'telemetry.analytics.first_playback_started';
  SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _instance =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<bool> load() async => await _instance.getBool(key) ?? false;

  @override
  Future<void> save(bool started) => _instance.setBool(key, started);
}

abstract interface class PostHogTransport {
  Future<void> setup(PostHogConfig config);
  Future<void> enable();
  Future<void> disable();
  Future<void> reset();
  Future<void> capture(String name, Map<String, Object> properties);
}

final class SdkPostHogTransport implements PostHogTransport {
  const SdkPostHogTransport();

  @override
  Future<void> setup(PostHogConfig config) => Posthog().setup(config);
  @override
  Future<void> enable() => Posthog().enable();
  @override
  Future<void> disable() => Posthog().disable();
  @override
  Future<void> reset() => Posthog().reset();
  @override
  Future<void> capture(String name, Map<String, Object> properties) =>
      Posthog().capture(eventName: name, properties: properties);
}

/// The only path from application code to PostHog. No account identifier is
/// passed to the SDK; a reset creates a new anonymous identity per session.
class PostHogAnalyticsTracker implements AnalyticsTracker {
  PostHogAnalyticsTracker({
    String? token,
    String? host,
    PostHogTransport? transport,
    String? appVersion,
    String? buildNumber,
    FirstPlaybackStore? firstPlaybackStore,
  }) : _token = token ?? const String.fromEnvironment('POSTHOG_PROJECT_TOKEN'),
       _host = host ?? const String.fromEnvironment('POSTHOG_HOST'),
       _transport = transport ?? const SdkPostHogTransport(),
       _testTransport = transport != null,
       _firstPlaybackStore =
           firstPlaybackStore ?? SharedPreferencesFirstPlaybackStore(),
       _version = appVersion ?? '',
       _build = buildNumber ?? '';

  final String _token;
  final String _host;
  final PostHogTransport _transport;
  final bool _testTransport;
  final FirstPlaybackStore _firstPlaybackStore;
  bool _enabled = false;
  bool _initialized = false;
  bool _firstPlayback = false;
  bool _needsReset = false;
  int _generation = 0;
  Future<void> _pending = Future.value();
  String _version;
  String _build;

  static const eventNames = {
    'registration_completed',
    'music_import_completed',
    'music_import_failed',
    'first_playback_started',
    'wave_started',
    'offline_download_completed',
    'sync_failed',
  };
  static const sources = {
    'local',
    'youtube',
    'soundcloud',
    'spotify',
    'cloud',
    'other',
  };
  static const modes = {'default', 'mood', 'track', 'artist'};
  static const categories = {
    'network',
    'server',
    'authentication',
    'storage',
    'unsupported',
    'unknown',
  };

  @override
  bool get isAvailable =>
      (_testTransport ||
          (!kIsWeb &&
              !Platform.isWindows &&
              !Platform.isLinux &&
              !Platform.environment.containsKey('FLUTTER_TEST'))) &&
      _token.trim().isNotEmpty &&
      Uri.tryParse(_host)?.scheme == 'https';

  @override
  bool get isEnabled => _enabled;

  Future<void> _enqueue(Future<void> Function() action) {
    final next = _pending
        .then((_) => action().timeout(const Duration(seconds: 5)))
        .catchError((Object _) {
          _enabled = false;
        });
    _pending = next;
    return next;
  }

  @override
  Future<void> setEnabled(bool enabled) {
    _enabled = enabled && isAvailable;
    final generation = ++_generation;
    return _enqueue(() async {
      if (!_enabled || generation != _generation) {
        if (_initialized) {
          await _transport.reset();
          await _transport.disable();
        }
        _firstPlayback = false;
        await _firstPlaybackStore.save(false);
        return;
      }
      if (!_initialized) {
        final config = PostHogConfig(_token)
          ..host = _host
          ..optOut = true
          ..captureApplicationLifecycleEvents = false
          ..sessionReplay = false
          ..sendFeatureFlagEvents = false
          ..preloadFeatureFlags = false
          ..surveys = false
          ..capturePushNotificationSubscriptions = false
          ..personProfiles = PostHogPersonProfiles.never
          ..maxQueueSize = 100
          ..flushAt = 10;
        config.rageClickConfig.enabled = false;
        config.beforeSend = [
          (event) {
            if (!eventNames.contains(event.event)) return null;
            event.userProperties = null;
            event.userPropertiesSetOnce = null;
            event.properties?.removeWhere(
              (key, _) => !{
                'platform',
                'app_version',
                'build_number',
                'source_category',
                'error_category',
                'wave_mode',
              }.contains(key),
            );
            return event;
          },
        ];
        await _transport.setup(config);
        if (!_testTransport) {
          final info = await PackageInfo.fromPlatform();
          _version = info.version;
          _build = info.buildNumber;
        }
        _initialized = true;
      }
      _firstPlayback = await _firstPlaybackStore.load();
      if (_needsReset) {
        await _transport.reset();
        _needsReset = false;
      }
      if (generation == _generation && _enabled) await _transport.enable();
    });
  }

  /// Called on every authentication epoch change, including sign-out.
  Future<void> resetIdentity() {
    ++_generation;
    _firstPlayback = false;
    _needsReset = true;
    return _enqueue(() async {
      if (_initialized && _enabled && _needsReset) {
        await _transport.reset();
        _needsReset = false;
      }
      await _firstPlaybackStore.save(false);
    });
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? properties}) {
    if (!_enabled || !eventNames.contains(name)) return Future.value();
    final generation = _generation;
    final safe = <String, Object>{
      'platform': Platform.operatingSystem,
      'app_version': _version,
      'build_number': _build,
    };
    final source = properties?['source_category'];
    if (source is String &&
        sources.contains(source) &&
        (name == 'music_import_completed' || name == 'music_import_failed')) {
      safe['source_category'] = source;
    }
    final category = properties?['error_category'];
    if (category is String &&
        categories.contains(category) &&
        (name == 'music_import_failed' || name == 'sync_failed')) {
      safe['error_category'] = category;
    }
    final mode = properties?['wave_mode'];
    if (name == 'wave_started' && mode is String && modes.contains(mode)) {
      safe['wave_mode'] = mode;
    }
    if (name == 'first_playback_started') {
      if (_firstPlayback) return Future.value();
      _firstPlayback = true;
    }
    return _enqueue(() async {
      if (!_enabled || generation != _generation) return;
      safe['app_version'] = _version;
      safe['build_number'] = _build;
      await _transport.capture(name, safe);
      if (name == 'first_playback_started') {
        await _firstPlaybackStore.save(true);
      }
    });
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {
    // User identification is deliberately unsupported.
  }
}
