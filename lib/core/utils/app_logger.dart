import 'dart:developer' as dev;

import 'package:openmusic/core/telemetry/crash_reporter.dart';

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
    dev.log(
      message ?? operation,
      name: 'AppLogger',
      level: fatal ? 1200 : 1000,
      error: error,
      stackTrace: stackTrace,
    );
    await _reporter.captureException(
      error,
      stackTrace,
      operation: operation,
      occurrenceId: occurrenceId,
      fatal: fatal,
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
      message,
      name: 'AppLogger',
      level: _developerLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
    await _reporter.addBreadcrumb(
      operation: operation ?? 'application.${level.name}',
      level: level,
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
