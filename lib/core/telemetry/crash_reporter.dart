enum AppLogLevel { debug, info, warning, error, fatal }

abstract interface class CrashReporter {
  bool get isAvailable;
  bool get isEnabled;

  Future<void> setEnabled(bool enabled);

  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? occurrenceId,
    bool fatal = false,
  });

  Future<void> addBreadcrumb({
    required String operation,
    required AppLogLevel level,
  });
}

final class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  bool get isAvailable => false;

  @override
  bool get isEnabled => false;

  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? occurrenceId,
    bool fatal = false,
  }) async {}

  @override
  Future<void> addBreadcrumb({
    required String operation,
    required AppLogLevel level,
  }) async {}
}
