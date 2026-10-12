import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/bootstrap/app_initializer.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/telemetry/crash_reporter.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/telemetry/telemetry_consent_store.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/presentation/features/telemetry/bloc/telemetry/telemetry_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';

void main() {
  group('failureFromException', () {
    test('classifies remote status codes', () {
      expect(_mapDio(403), isA<RemoteAccessFailure>());
      expect(_mapDio(404), isA<NotFoundFailure>());
      expect(_mapDio(429), isA<RateLimitFailure>());
      expect(_mapDio(503), isA<RemoteServiceFailure>());
    });

    test('distinguishes permission and generic storage failures', () {
      expect(
        failureFromException(
          const FileSystemException('denied', '', OSError('', 13)),
        ),
        isA<PermissionFailure>(),
      );
      expect(
        failureFromException(const FileSystemException('disk failure')),
        isA<StorageFailure>(),
      );
    });
  });

  test('UiError gives repeated failures unique occurrence IDs', () async {
    final reporter = _FakeCrashReporter();
    AppLogger.configure(reporter);

    final first = UiError.fromException(
      StateError('first'),
      StackTrace.current,
      operation: 'test.first',
    );
    final second = UiError.fromException(
      StateError('second'),
      StackTrace.current,
      operation: 'test.second',
    );
    await pumpEventQueue();

    expect(first.localeKey, second.localeKey);
    expect(first.occurrenceId, isNot(second.occurrenceId));
    expect(reporter.capturedOperations, ['test.first', 'test.second']);
    expect(reporter.capturedOccurrenceIds, [
      first.occurrenceId,
      second.occurrenceId,
    ]);
    AppLogger.configure(const NoopCrashReporter());
  });

  test('AppInitializer retries only the failed step', () async {
    var completedRuns = 0;
    var retriedRuns = 0;
    final initializer = AppInitializer([
      BootstrapStep(BootstrapPhase.localization, () async {
        completedRuns++;
      }),
      BootstrapStep(BootstrapPhase.audio, () async {
        retriedRuns++;
        if (retriedRuns == 1) throw StateError('temporary');
      }),
    ]);

    await expectLater(initializer.initialize(), throwsStateError);
    expect(initializer.currentPhase, BootstrapPhase.audio);
    await initializer.initialize();

    expect(completedRuns, 1);
    expect(retriedRuns, 2);
    expect(initializer.isComplete, isTrue);
  });

  test(
    'TelemetryCubit persists independent crash and analytics consent',
    () async {
      final reporter = _FakeCrashReporter(available: true);
      final analytics = _FakeAnalyticsTracker();
      final store = _FakeConsentStore();
      final cubit = TelemetryCubit(
        reporter: reporter,
        analytics: analytics,
        consentStore: store,
        initialConsent: false,
      );

      await cubit.setConsent(true);
      expect(cubit.state.consentEnabled, isTrue);
      expect(reporter.isEnabled, isTrue);
      expect(analytics.isEnabled, isFalse);
      expect(store.value, isTrue);
      await cubit.setAnalyticsConsent(true);
      expect(analytics.isEnabled, isTrue);
      expect(store.analyticsValue, isTrue);

      await cubit.setConsent(false);
      expect(cubit.state.consentEnabled, isFalse);
      expect(reporter.isEnabled, isFalse);
      expect(analytics.isEnabled, isTrue);
      expect(store.value, isFalse);
      await cubit.setAnalyticsConsent(false);
      expect(analytics.isEnabled, isFalse);
      expect(store.analyticsValue, isFalse);
      await cubit.close();
    },
  );

  test(
    'TelemetryCubit rolls reporting back when opt-in cannot persist',
    () async {
      final reporter = _FakeCrashReporter(available: true);
      final analytics = _FakeAnalyticsTracker();
      final cubit = TelemetryCubit(
        reporter: reporter,
        analytics: analytics,
        consentStore: _FailingConsentStore(),
        initialConsent: false,
      );

      await cubit.setConsent(true);

      expect(cubit.state.consentEnabled, isFalse);
      expect(cubit.state.error, isNotNull);
      expect(reporter.isEnabled, isFalse);
      expect(analytics.isEnabled, isFalse);
      await cubit.close();
    },
  );
}

Failure _mapDio(int statusCode) => failureFromException(
  DioException.badResponse(
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/test'),
    response: Response<void>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
    ),
  ),
);

final class _FakeConsentStore implements TelemetryConsentStore {
  bool value = false;
  bool analyticsValue = false;

  @override
  Future<bool> load() async => value;

  @override
  Future<void> save(bool enabled) async => value = enabled;

  @override
  Future<bool> loadAnalytics() async => analyticsValue;

  @override
  Future<void> saveAnalytics(bool enabled) async => analyticsValue = enabled;
}

final class _FailingConsentStore implements TelemetryConsentStore {
  @override
  Future<bool> load() async => false;

  @override
  Future<void> save(bool enabled) => throw StateError('write failed');

  @override
  Future<bool> loadAnalytics() async => false;

  @override
  Future<void> saveAnalytics(bool enabled) => throw StateError('write failed');
}

final class _FakeCrashReporter implements CrashReporter {
  _FakeCrashReporter({this.available = true});

  final bool available;
  final List<String> capturedOperations = [];
  final List<String?> capturedOccurrenceIds = [];
  bool _enabled = false;

  @override
  bool get isAvailable => available;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> setEnabled(bool enabled) async => _enabled = enabled;

  @override
  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? occurrenceId,
    bool fatal = false,
  }) async {
    capturedOperations.add(operation);
    capturedOccurrenceIds.add(occurrenceId);
  }

  @override
  Future<void> addBreadcrumb({
    required String operation,
    required AppLogLevel level,
  }) async {}
}

final class _FakeAnalyticsTracker implements AnalyticsTracker {
  bool _enabled = false;

  @override
  bool get isAvailable => true;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> setEnabled(bool enabled) async => _enabled = enabled;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? properties}) async {}

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {}
}
