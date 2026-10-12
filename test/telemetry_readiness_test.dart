import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/telemetry/posthog_analytics_tracker.dart';
import 'package:owlsonic/core/telemetry/sentry_crash_reporter.dart';
import 'package:owlsonic/core/telemetry/telemetry_consent_store.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final class _Capture {
  const _Capture(this.name, this.properties);
  final String name;
  final Map<String, Object> properties;
}

final class _PlaybackStore implements FirstPlaybackStore {
  bool value = false;
  @override
  Future<bool> load() async => value;
  @override
  Future<void> save(bool started) async => value = started;
}

final class _FakeTransport implements PostHogTransport {
  _FakeTransport({this.failSetup = false});

  final bool failSetup;
  final events = <_Capture>[];
  final setupGate = Completer<void>();
  PostHogConfig? config;
  int resets = 0;
  bool enabled = false;

  @override
  Future<void> setup(PostHogConfig value) async {
    config = value;
    await setupGate.future;
    if (failSetup) throw StateError('SDK unavailable');
  }

  @override
  Future<void> enable() async => enabled = true;
  @override
  Future<void> disable() async => enabled = false;
  @override
  Future<void> reset() async => resets++;
  @override
  Future<void> capture(String name, Map<String, Object> properties) async {
    if (enabled) events.add(_Capture(name, Map.of(properties)));
  }
}

PostHogAnalyticsTracker _tracker(
  _FakeTransport fake, {
  _PlaybackStore? store,
}) => PostHogAnalyticsTracker(
  token: 'phc_public_test',
  host: 'https://eu.i.posthog.com',
  transport: fake,
  appVersion: '1.2.3',
  buildNumber: '45',
  firstPlaybackStore: store ?? _PlaybackStore(),
);

void main() {
  test(
    'independent telemetry choices survive a new preferences store',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      addTearDown(() => SharedPreferencesAsyncPlatform.instance = null);
      final first = SharedPreferencesTelemetryConsentStore();
      expect(await first.load(), isFalse);
      expect(await first.loadAnalytics(), isFalse);
      await first.save(true);
      await first.saveAnalytics(true);
      final restarted = SharedPreferencesTelemetryConsentStore();
      expect(await restarted.load(), isTrue);
      expect(await restarted.loadAnalytics(), isTrue);
      await restarted.saveAnalytics(false);
      expect(await first.load(), isTrue);
      expect(await first.loadAnalytics(), isFalse);
    },
  );

  test('telemetry Settings labels exist in English and Russian', () {
    for (final language in ['en', 'ru']) {
      final json =
          jsonDecode(
                File('assets/translations/$language.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final settings = json['settings'] as Map<String, dynamic>;
      for (final key in [
        'crashReports',
        'crashReportsDescription',
        'usageAnalytics',
        'usageAnalyticsDescription',
        'usageAnalyticsUnavailable',
      ]) {
        expect(
          (settings[key] as String).trim(),
          isNotEmpty,
          reason: '$language settings.$key',
        );
      }
      expect(settings['crashReports'], isNot(settings['usageAnalytics']));
    }
  });

  test('the real PostHog transport is unavailable to widget tests', () {
    final tracker = PostHogAnalyticsTracker(
      token: 'phc_public_test',
      host: 'https://eu.i.posthog.com',
    );
    expect(tracker.isAvailable, isFalse);
  });

  test(
    'PostHog is disabled by default and setup disables automatic capture',
    () async {
      final fake = _FakeTransport();
      final tracker = _tracker(fake);
      await tracker.logEvent('wave_started', properties: {'wave_mode': 'mood'});
      expect(fake.events, isEmpty);
      fake.setupGate.complete();
      await tracker.setEnabled(true);
      final config = fake.config!;
      expect(config.optOut, isTrue);
      expect(config.captureApplicationLifecycleEvents, isFalse);
      expect(config.sessionReplay, isFalse);
      expect(config.rageClickConfig.enabled, isFalse);
      expect(config.personProfiles, PostHogPersonProfiles.never);
      expect(config.maxQueueSize, 100);
      expect(config.capturePushNotificationSubscriptions, isFalse);
      expect(
        await config.beforeSend.single(PostHogEvent(event: r'$screen')),
        isNull,
      );
      final filtered = await config.beforeSend.single(
        PostHogEvent(
          event: 'wave_started',
          properties: {'wave_mode': 'mood', 'email': 'private@example.com'},
        ),
      );
      expect(filtered!.properties, {'wave_mode': 'mood'});
    },
  );

  test(
    'only named events and allowlisted properties reach the transport',
    () async {
      final fake = _FakeTransport()..setupGate.complete();
      final tracker = _tracker(fake);
      await tracker.setEnabled(true);
      await tracker.logEvent(
        'screen_viewed',
        properties: {'email': 'a@example.com'},
      );
      await tracker.logEvent(
        'music_import_completed',
        properties: {
          'source_category': 'spotify',
          'track_id': 'private-id',
          'title': 'Private song',
          'url': 'https://signed.example/a',
        },
      );
      await tracker.logEvent(
        'music_import_failed',
        properties: {
          'source_category': 'not-a-source',
          'error_category': 'network',
          'exception': 'private',
        },
      );
      await tracker.logEvent('wave_started', properties: {'wave_mode': 'mood'});
      expect(fake.events.map((e) => e.name), [
        'music_import_completed',
        'music_import_failed',
        'wave_started',
      ]);
      expect(fake.events.first.properties, {
        'platform': Platform.operatingSystem,
        'app_version': '1.2.3',
        'build_number': '45',
        'source_category': 'spotify',
      });
      expect(fake.events[1].properties['error_category'], 'network');
      expect(fake.events[1].properties.containsKey('source_category'), isFalse);
      expect(fake.events[2].properties['wave_mode'], 'mood');
    },
  );

  test(
    'first playback is once per anonymous identity and resets on switch',
    () async {
      final fake = _FakeTransport()..setupGate.complete();
      final tracker = _tracker(fake);
      await tracker.setEnabled(true);
      await tracker.logEvent('first_playback_started');
      await tracker.logEvent('first_playback_started');
      expect(fake.events.map((e) => e.name), ['first_playback_started']);
      await tracker.resetIdentity();
      await tracker.logEvent('first_playback_started');
      expect(fake.resets, 1);
      expect(fake.events.length, 2);
    },
  );

  test('first playback remains recorded across an app restart', () async {
    final store = _PlaybackStore();
    final first = _FakeTransport()..setupGate.complete();
    final firstTracker = _tracker(first, store: store);
    await firstTracker.setEnabled(true);
    await firstTracker.logEvent('first_playback_started');
    expect(store.value, isTrue);

    final second = _FakeTransport()..setupGate.complete();
    final restarted = _tracker(second, store: store);
    await restarted.setEnabled(true);
    await restarted.logEvent('first_playback_started');
    expect(second.events, isEmpty);
  });

  test(
    'opt-out and account switch discard captures queued during setup',
    () async {
      final fake = _FakeTransport();
      final tracker = _tracker(fake);
      final enabling = tracker.setEnabled(true);
      final queuedA = tracker.logEvent('wave_started');
      final switching = tracker.resetIdentity();
      final queuedB = tracker.logEvent('music_import_completed');
      final optingOut = tracker.setEnabled(false);
      fake.setupGate.complete();
      await Future.wait([enabling, queuedA, switching, queuedB, optingOut]);
      expect(fake.events, isEmpty);
      expect(tracker.isEnabled, isFalse);
      expect(fake.resets, 0); // The SDK never finished starting.
      await tracker.logEvent('wave_started');
      expect(fake.events, isEmpty);
    },
  );

  test('expected network and cancellation errors are not crash reports', () {
    expect(
      isExpectedTelemetryError(
        const OwlSonicApiException(
          kind: OwlSonicApiErrorKind.network,
          code: 'offline',
          message: 'offline',
          retryable: true,
        ),
      ),
      isTrue,
    );
    expect(
      isExpectedTelemetryError(
        DioException(
          requestOptions: RequestOptions(path: '/private'),
          type: DioExceptionType.cancel,
        ),
      ),
      isTrue,
    );
    expect(
      isExpectedTelemetryError(StateError('database corruption')),
      isFalse,
    );
  });

  test('crash reporter without consent or DSN stays inactive', () async {
    final reporter = SentryCrashReporter(dsn: '');
    expect(reporter.isAvailable, isFalse);
    await reporter.setEnabled(true);
    await reporter.captureException(
      StateError('safe test failure'),
      StackTrace.current,
      operation: 'test.safe_failure',
    );
    expect(reporter.isEnabled, isFalse);
  });

  test(
    'opt-out resets the initialized SDK and prevents later capture',
    () async {
      final fake = _FakeTransport()..setupGate.complete();
      final tracker = _tracker(fake);
      await tracker.setEnabled(true);
      await tracker.logEvent('wave_started');
      expect(fake.events.length, 1);
      await tracker.setEnabled(false);
      expect(fake.enabled, isFalse);
      expect(fake.resets, 1);
      await tracker.logEvent('wave_started');
      expect(fake.events.length, 1);
    },
  );

  test('SDK initialization failure leaves the app path usable', () async {
    final fake = _FakeTransport(failSetup: true)..setupGate.complete();
    final tracker = _tracker(fake);
    await tracker.setEnabled(true);
    expect(tracker.isEnabled, isFalse);
    await tracker.logEvent('wave_started');
    expect(fake.events, isEmpty);
  });

  test(
    'Sentry event removes user, request, breadcrumbs and exception text',
    () {
      final event = SentryEvent(
        user: SentryUser(email: 'private@example.com'),
        request: SentryRequest(url: 'https://signed.example/song?token=secret'),
        breadcrumbs: [Breadcrumb(message: 'Private song')],
        exceptions: [
          SentryException(
            type: 'Private song',
            value: 'private@example.com /Music/Song.mp3',
            stackTrace: SentryStackTrace(
              frames: [
                SentryStackFrame(
                  absPath: '/Users/alice/Music/Song.mp3',
                  fileName: '/Users/alice/Music/Song.mp3',
                  function: 'play',
                  lineNo: 12,
                  vars: {'token': 'secret'},
                ),
              ],
            ),
          ),
        ],
      );
      final safe = scrubEvent(event, Hint())!;
      expect(safe.user, isNull);
      expect(safe.request, isNull);
      expect(safe.breadcrumbs, isEmpty);
      expect(safe.exceptions!.single.value, 'Unexpected application failure');
      final frame = safe.exceptions!.single.stackTrace!.frames.single;
      expect(frame.absPath, isNull);
      expect(frame.vars, isEmpty);
      expect(frame.fileName, isNull);
    },
  );
}
