import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/telemetry/crash_reporter.dart';
import 'package:openmusic/core/telemetry/telemetry_consent_store.dart';
import 'package:openmusic/layers/presentation/models/ui_error.dart';

class TelemetryState extends Equatable {
  const TelemetryState({
    required this.consentEnabled,
    required this.available,
    this.isUpdating = false,
    this.error,
  });

  final bool consentEnabled;
  final bool available;
  final bool isUpdating;
  final UiError? error;

  @override
  List<Object?> get props => [consentEnabled, available, isUpdating, error];
}

class TelemetryCubit extends Cubit<TelemetryState> {
  TelemetryCubit({
    required CrashReporter reporter,
    required TelemetryConsentStore consentStore,
    required bool initialConsent,
  }) : _reporter = reporter,
       _consentStore = consentStore,
       super(
         TelemetryState(
           consentEnabled: initialConsent,
           available: reporter.isAvailable,
         ),
       );

  final CrashReporter _reporter;
  final TelemetryConsentStore _consentStore;

  Future<void> setConsent(bool enabled) async {
    if (state.isUpdating || enabled == state.consentEnabled) return;
    if (enabled && !state.available) return;
    emit(
      TelemetryState(
        consentEnabled: state.consentEnabled,
        available: state.available,
        isUpdating: true,
      ),
    );
    try {
      if (enabled) {
        await _reporter.setEnabled(true);
        try {
          await _consentStore.save(true);
        } catch (error, stackTrace) {
          await _reporter.setEnabled(false);
          Error.throwWithStackTrace(error, stackTrace);
        }
      } else {
        await _consentStore.save(false);
        await _reporter.setEnabled(false);
      }
      if (isClosed) return;
      emit(TelemetryState(consentEnabled: enabled, available: state.available));
    } catch (error, stackTrace) {
      if (isClosed) return;
      emit(
        TelemetryState(
          consentEnabled: _reporter.isEnabled,
          available: state.available,
          error: UiError.fromException(
            error,
            stackTrace,
            operation: 'telemetry.update_consent',
          ),
        ),
      );
    }
  }
}
