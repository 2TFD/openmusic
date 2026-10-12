import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'crash_reporter.dart';
import 'diagnostics_scrubber.dart';

final class SentryCrashReporter implements CrashReporter {
  SentryCrashReporter({String? dsn, String? environment})
    : _dsn = dsn ?? const String.fromEnvironment('SENTRY_DSN'),
      _environment =
          environment ??
          const String.fromEnvironment(
            'SENTRY_ENVIRONMENT',
            defaultValue: String.fromEnvironment(
              'OWLSONIC_ENV',
              defaultValue: 'development',
            ),
          );

  final String _dsn;
  final String _environment;
  bool _enabled = false;
  bool _desiredEnabled = false;
  bool _sdkOpen = false;
  int _generation = 0;
  Future<void> _pending = Future.value();

  @override
  bool get isAvailable => _dsn.trim().isNotEmpty;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> setEnabled(bool enabled) {
    _desiredEnabled = enabled && isAvailable;
    if (!_desiredEnabled) _enabled = false;
    final generation = ++_generation;
    final next = _pending
        .then((_) async {
          if (!_desiredEnabled || generation != _generation) {
            if (_sdkOpen && !_desiredEnabled) {
              _sdkOpen = false;
              try {
                await Sentry.close();
              } catch (_) {}
            }
            return;
          }
          if (_sdkOpen) {
            _enabled = true;
            return;
          }
          try {
            final info = await PackageInfo.fromPlatform();
            if (!_desiredEnabled || generation != _generation) return;
            await SentryFlutter.init((options) {
              options
                ..dsn = _dsn
                ..environment = _environment
                ..release =
                    '${info.packageName}@${info.version}+${info.buildNumber}'
                ..enableAutoSessionTracking = false
                // ignore: experimental_member_use
                ..attachViewHierarchy = false
                // ignore: experimental_member_use
                ..profilesSampleRate = 0
                ..sendDefaultPii = false
                ..tracesSampleRate = 0
                ..captureFailedRequests = false
                ..attachScreenshot = false;
              options.beforeSend = (event, hint) =>
                  _desiredEnabled ? scrubEvent(event, hint) : null;
              options.beforeBreadcrumb = (crumb, hint) =>
                  _desiredEnabled ? scrubBreadcrumb(crumb, hint) : null;
              options.replay.sessionSampleRate = 0;
              options.replay.onErrorSampleRate = 0;
            });
            _sdkOpen = true;
            if (!_desiredEnabled || generation != _generation) {
              _sdkOpen = false;
              await Sentry.close();
              return;
            }
            _enabled = true;
          } catch (_) {
            _enabled = false;
          }
        })
        .catchError((Object _) {
          _enabled = false;
        });
    _pending = next;
    return next;
  }

  @override
  Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? occurrenceId,
    bool fatal = false,
  }) async {
    if (!_enabled || isExpectedTelemetryError(error)) return;
    try {
      await Sentry.captureException(
        StateError('Unexpected application failure'),
        stackTrace: StackTrace.fromString(
          scrubDiagnostics(stackTrace.toString()),
        ),
        withScope: (scope) {
          scope
            ..setTag('operation', safeOperation(operation))
            ..level = fatal ? SentryLevel.fatal : SentryLevel.error;
        },
      );
    } catch (_) {}
  }

  @override
  Future<void> addBreadcrumb({
    required String operation,
    required AppLogLevel level,
  }) async {
    if (!_enabled) return;
    try {
      await Sentry.addBreadcrumb(
        Breadcrumb(
          category: 'application',
          message: safeOperation(operation),
          level: switch (level) {
            AppLogLevel.debug => SentryLevel.debug,
            AppLogLevel.info => SentryLevel.info,
            AppLogLevel.warning => SentryLevel.warning,
            AppLogLevel.error => SentryLevel.error,
            AppLogLevel.fatal => SentryLevel.fatal,
          },
        ),
      );
    } catch (_) {}
  }
}

String safeOperation(String operation) =>
    RegExp(r'^[a-zA-Z0-9_.]{1,80}$').hasMatch(operation)
    ? operation
    : 'application.unknown';

bool isExpectedTelemetryError(Object error) {
  if (error is OwlSonicApiException) {
    return error.isNetwork ||
        error.isCancelled ||
        error.isUnauthorized ||
        error.retryable ||
        error.statusCode == 422;
  }
  return error is DioException || error is SocketException;
}

/// Strips tokens, signed URLs, e-mails and file paths from an outgoing event.
SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
  for (final exception in event.exceptions ?? const <SentryException>[]) {
    exception.value = 'Unexpected application failure';
    exception.type = 'ApplicationError';
    final stack = exception.stackTrace;
    if (stack != null) exception.stackTrace = _safeStack(stack);
  }
  event.threads = [
    for (final thread in event.threads ?? const <SentryThread>[])
      SentryThread(
        crashed: thread.crashed,
        current: thread.current,
        stacktrace: thread.stacktrace == null
            ? null
            : _safeStack(thread.stacktrace!),
      ),
  ];
  if (event.message != null) {
    event.message!.formatted = 'Unexpected application failure';
  }
  event.user = null;
  event.request = null;
  event.contexts.clear();
  // ignore: deprecated_member_use
  event.extra = null;
  event.breadcrumbs = [];
  event.fingerprint = null;
  event.modules = null;
  event.transaction = null;
  event.culprit = null;
  event.serverName = null;
  event.tags?.removeWhere((key, _) => key != 'operation');
  if (event.tags?['operation'] case final String operation) {
    event.tags!['operation'] = safeOperation(operation);
  }
  return event;
}

SentryStackTrace _safeStack(SentryStackTrace stack) => SentryStackTrace(
  frames: [
    for (final frame in stack.frames)
      SentryStackFrame(
        fileName: frame.fileName?.endsWith('.dart') == true
            ? frame.fileName!.split('/').last.split('\\').last
            : null,
        function:
            frame.function != null &&
                RegExp(r'^[a-zA-Z0-9_.$<>-]{1,120}$').hasMatch(frame.function!)
            ? frame.function
            : null,
        lineNo: frame.lineNo,
        colNo: frame.colNo,
        inApp: frame.inApp,
      ),
  ],
);

Breadcrumb? scrubBreadcrumb(Breadcrumb? crumb, Hint hint) => null;
