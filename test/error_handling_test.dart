import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/bootstrap/app_initializer.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/telemetry/crash_reporter.dart';
import 'package:openmusic/core/telemetry/telemetry_consent_store.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/presentation/blocs/telemetry/telemetry_cubit.dart';
import 'package:openmusic/layers/presentation/models/ui_error.dart';

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

  test('TelemetryCubit persists opt-in and controls reporter', () async {
    final reporter = _FakeCrashReporter(available: true);
    final store = _FakeConsentStore();
    final cubit = TelemetryCubit(
      reporter: reporter,
      consentStore: store,
      initialConsent: false,
    );

    await cubit.setConsent(true);
    expect(cubit.state.consentEnabled, isTrue);
    expect(reporter.isEnabled, isTrue);
    expect(store.value, isTrue);

    await cubit.setConsent(false);
    expect(cubit.state.consentEnabled, isFalse);
    expect(reporter.isEnabled, isFalse);
    expect(store.value, isFalse);
    await cubit.close();
  });

  test(
    'TelemetryCubit rolls reporting back when opt-in cannot persist',
    () async {
      final reporter = _FakeCrashReporter(available: true);
      final cubit = TelemetryCubit(
        reporter: reporter,
        consentStore: _FailingConsentStore(),
        initialConsent: false,
      );

      await cubit.setConsent(true);

      expect(cubit.state.consentEnabled, isFalse);
      expect(cubit.state.error, isNotNull);
      expect(reporter.isEnabled, isFalse);
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

  @override
  Future<bool> load() async => value;

  @override
  Future<void> save(bool enabled) async => value = enabled;
}

final class _FailingConsentStore implements TelemetryConsentStore {
  @override
  Future<bool> load() async => false;

  @override
  Future<void> save(bool enabled) => throw StateError('write failed');
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
