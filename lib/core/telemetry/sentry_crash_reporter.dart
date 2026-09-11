import 'package:sentry_flutter/sentry_flutter.dart';

import 'crash_reporter.dart';

final class SentryCrashReporter implements CrashReporter {
  SentryCrashReporter({String? dsn, String? environment})
    : _dsn = dsn ?? const String.fromEnvironment('SENTRY_DSN'),
      _environment =
          environment ??
          const String.fromEnvironment(
            'SENTRY_ENVIRONMENT',
            defaultValue: 'production',
          );

  final String _dsn;
  final String _environment;
  bool _enabled = false;

  @override
  bool get isAvailable => _dsn.trim().isNotEmpty;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> setEnabled(bool enabled) async {
    if (enabled == _enabled) return;
    if (!enabled) {
      _enabled = false;
      await Sentry.close();
      return;
    }
    if (!isAvailable) return;

    await SentryFlutter.init((options) {
      options
        ..dsn = _dsn
        ..environment = _environment
        ..sendDefaultPii = false
        ..tracesSampleRate = 0
        ..captureFailedRequests = false
        ..attachScreenshot = false;
    });
    _enabled = true;
  }

  @override
  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? occurrenceId,
    bool fatal = false,
  }) async {
    if (!_enabled) return;
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope
          ..setTag('operation', operation)
          ..setTag('occurrence_id', occurrenceId ?? 'unavailable')
          ..level = fatal ? SentryLevel.fatal : SentryLevel.error;
      },
    );
  }

  @override
  Future<void> addBreadcrumb({
    required String operation,
    required AppLogLevel level,
  }) async {
    if (!_enabled) return;
    await Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'application',
        message: operation,
        level: switch (level) {
          AppLogLevel.debug => SentryLevel.debug,
          AppLogLevel.info => SentryLevel.info,
          AppLogLevel.warning => SentryLevel.warning,
          AppLogLevel.error => SentryLevel.error,
          AppLogLevel.fatal => SentryLevel.fatal,
        },
      ),
    );
  }
}
