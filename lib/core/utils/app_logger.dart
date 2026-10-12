import 'dart:developer' as dev;
import 'dart:async';

import 'package:owlsonic/core/telemetry/crash_reporter.dart';

class AppLogger {
  static CrashReporter _reporter = const NoopCrashReporter();

  static void configure(CrashReporter reporter) => _reporter = reporter;

  static Future<void> log(String message) => warning(message);

  static Future<void> debug(String message, {String? operation}) =>
      _write(message, level: AppLogLevel.debug, operation: operation);

  static Future<void> info(String message, {String? operation}) =>
      _write(message, level: AppLogLevel.info, operation: operation);

  static Future<void> warning(
    String message, {
    String? operation,
    Object? error,
    StackTrace? stackTrace,
  }) => _write(
    message,
    level: AppLogLevel.warning,
    operation: operation,
    error: error,
    stackTrace: stackTrace,
  );

  static Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? message,
    String? occurrenceId,
    bool fatal = false,
  }) async {
    dev.log(operation, name: 'AppLogger', level: fatal ? 1200 : 1000);
    unawaited(
      _reporter
          .captureException(
            error,
            stackTrace,
            operation: operation,
            occurrenceId: occurrenceId,
            fatal: fatal,
          )
          .catchError((Object _) {}),
    );
  }

  static Future<void> _write(
    String message, {
    required AppLogLevel level,
    String? operation,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    dev.log(
      operation ?? 'application.${level.name}',
      name: 'AppLogger',
      level: _developerLevel(level),
    );
    unawaited(
      _reporter
          .addBreadcrumb(
            operation: operation ?? 'application.${level.name}',
            level: level,
          )
          .catchError((Object _) {}),
    );
  }

  static int _developerLevel(AppLogLevel level) => switch (level) {
    AppLogLevel.debug => 500,
    AppLogLevel.info => 800,
    AppLogLevel.warning => 900,
    AppLogLevel.error => 1000,
    AppLogLevel.fatal => 1200,
  };
}
