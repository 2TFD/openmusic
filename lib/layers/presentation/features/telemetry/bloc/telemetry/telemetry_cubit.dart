import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:owlsonic/core/telemetry/crash_reporter.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/telemetry/telemetry_consent_store.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';

class TelemetryState extends Equatable {
  const TelemetryState({
    required this.consentEnabled,
    required this.available,
    this.analyticsEnabled = false,
    this.analyticsAvailable = false,
    this.isUpdating = false,
    this.error,
  });

  final bool consentEnabled;
  final bool available;
  final bool analyticsEnabled;
  final bool analyticsAvailable;
  final bool isUpdating;
  final UiError? error;

  @override
  List<Object?> get props => [
    consentEnabled,
    available,
    analyticsEnabled,
    analyticsAvailable,
    isUpdating,
    error,
  ];
}

class TelemetryCubit extends Cubit<TelemetryState> {
  TelemetryCubit({
    required CrashReporter reporter,
    required AnalyticsTracker analytics,
    required TelemetryConsentStore consentStore,
    required bool initialConsent,
    bool initialAnalyticsConsent = false,
  }) : _reporter = reporter,
       _analytics = analytics,
       _consentStore = consentStore,
       super(
         TelemetryState(
           consentEnabled: initialConsent,
           analyticsEnabled: initialAnalyticsConsent,
           available: reporter.isAvailable,
           analyticsAvailable: analytics.isAvailable,
         ),
       );

  final CrashReporter _reporter;
  final AnalyticsTracker _analytics;
  final TelemetryConsentStore _consentStore;

  Future<void> setConsent(bool enabled) => _update(enabled, analytics: false);
  Future<void> setAnalyticsConsent(bool enabled) =>
      _update(enabled, analytics: true);

  Future<void> _update(bool enabled, {required bool analytics}) async {
    if (state.isUpdating ||
        enabled ==
            (analytics ? state.analyticsEnabled : state.consentEnabled) ||
        (enabled &&
            !(analytics ? state.analyticsAvailable : state.available))) {
      return;
    }
    emit(_state(isUpdating: true));
    try {
      // Persist before enabling so a write failure cannot transmit data.
      if (analytics) {
        await _consentStore.saveAnalytics(enabled);
        await _analytics.setEnabled(enabled);
      } else {
        await _consentStore.save(enabled);
        await _reporter.setEnabled(enabled);
      }
      if (!isClosed)
        emit(
          _state(
            crash: analytics ? state.consentEnabled : enabled,
            usage: analytics ? enabled : state.analyticsEnabled,
          ),
        );
    } catch (error, stackTrace) {
      if (!isClosed)
        emit(
          _state(
            error: UiError.fromException(
              error,
              stackTrace,
              operation: 'telemetry.update_consent',
            ),
          ),
        );
    }
  }

  TelemetryState _state({
    bool? crash,
    bool? usage,
    bool isUpdating = false,
    UiError? error,
  }) => TelemetryState(
    consentEnabled: crash ?? state.consentEnabled,
    analyticsEnabled: usage ?? state.analyticsEnabled,
    available: state.available,
    analyticsAvailable: state.analyticsAvailable,
    isUpdating: isUpdating,
    error: error,
  );
}
