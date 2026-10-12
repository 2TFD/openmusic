import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';

enum VerifyEmailStatus {
  loading,

  /// Nothing to verify on this installation (e.g. after a reinstall).
  missing,
  ready,

  /// Verified and signed in.
  done,
}

class VerifyEmailState {
  const VerifyEmailState({
    this.status = VerifyEmailStatus.loading,
    this.email = '',
    this.submitting = false,
    this.resending = false,
    this.resendSecondsLeft = 0,
    this.codeExpired = false,
    this.codeDead = false,
    this.error,
    this.notice,
  });

  final VerifyEmailStatus status;
  final String email;
  final bool submitting;
  final bool resending;
  final int resendSecondsLeft;

  /// The emailed code is past `code_expires_in`; ask for a new one.
  final bool codeExpired;

  /// Too many wrong tries: the code is dead until a new one is sent.
  final bool codeDead;
  final AuthMessage? error;
  final AuthMessage? notice;

  bool get canSubmit =>
      status == VerifyEmailStatus.ready &&
      !submitting &&
      !codeExpired &&
      !codeDead;
  bool get canResend => !resending && !submitting && resendSecondsLeft == 0;

  VerifyEmailState copyWith({
    VerifyEmailStatus? status,
    String? email,
    bool? submitting,
    bool? resending,
    int? resendSecondsLeft,
    bool? codeExpired,
    bool? codeDead,
    AuthMessage? error,
    AuthMessage? notice,
    bool clearError = false,
    bool clearNotice = false,
  }) => VerifyEmailState(
    status: status ?? this.status,
    email: email ?? this.email,
    submitting: submitting ?? this.submitting,
    resending: resending ?? this.resending,
    resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
    codeExpired: codeExpired ?? this.codeExpired,
    codeDead: codeDead ?? this.codeDead,
    error: clearError ? null : error ?? this.error,
    notice: clearNotice ? null : notice ?? this.notice,
  );
}

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit({
    required CloudAuthRepository auth,
    AnalyticsTracker analytics = const NoopAnalyticsTracker(),
    DateTime Function()? now,
  }) : _auth = auth,
       _analytics = analytics,
       _now = now ?? (() => DateTime.now().toUtc()),
       super(const VerifyEmailState());

  final CloudAuthRepository _auth;
  final AnalyticsTracker _analytics;
  final DateTime Function() _now;
  Timer? _timer;
  DateTime? _resendAt;
  DateTime? _expiresAt;

  Future<void> initialize() async {
    final pending = await _auth.pendingVerification();
    if (isClosed) return;
    if (pending == null) {
      emit(state.copyWith(status: VerifyEmailStatus.missing));
      return;
    }
    _resendAt = pending.resendAvailableAt;
    _expiresAt = pending.codeExpiresAt;
    emit(state.copyWith(status: VerifyEmailStatus.ready, email: pending.email));
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (isClosed) return;
    final now = _now();
    final resendAt = _resendAt;
    final left = resendAt == null || !resendAt.isAfter(now)
        ? 0
        : (resendAt.difference(now).inMilliseconds / 1000).ceil();
    final expiresAt = _expiresAt;
    final expired = expiresAt != null && !expiresAt.isAfter(now);
    if (left != state.resendSecondsLeft || expired != state.codeExpired) {
      emit(state.copyWith(resendSecondsLeft: left, codeExpired: expired));
    }
  }

  Future<void> verify(String code) async {
    if (!state.canSubmit) return;
    final invalid = AuthRules.validateCode(code);
    if (invalid != null) {
      emit(state.copyWith(error: AuthMessage(invalid), clearNotice: true));
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true, clearNotice: true));
    try {
      await _auth.verifyEmail(email: state.email, code: code);
      unawaited(_analytics.logEvent('registration_completed'));
      if (!isClosed) {
        emit(state.copyWith(submitting: false, status: VerifyEmailStatus.done));
      }
    } on OwlSonicApiException catch (error) {
      if (isClosed) return;
      _applyRetryAfter(error);
      emit(
        state.copyWith(
          submitting: false,
          error: authMessageFor(error),
          codeDead: state.codeDead || error.code == 'CODE_ATTEMPTS_EXCEEDED',
        ),
      );
    }
  }

  Future<void> resend() async {
    if (!state.canResend || state.status != VerifyEmailStatus.ready) return;
    emit(state.copyWith(resending: true, clearError: true, clearNotice: true));
    try {
      final challenge = await _auth.resendVerification(email: state.email);
      if (isClosed) return;
      _resendAt = challenge.resendAvailableAt;
      _expiresAt = challenge.codeExpiresAt;
      emit(
        state.copyWith(
          resending: false,
          codeDead: false,
          codeExpired: false,
          notice: const AuthMessage('auth.verify.codeSent'),
        ),
      );
      _tick();
    } on OwlSonicApiException catch (error) {
      if (isClosed) return;
      _applyRetryAfter(error);
      emit(state.copyWith(resending: false, error: authMessageFor(error)));
      _tick();
    }
  }

  /// A cooldown from the server (`Retry-After`) restarts the countdown.
  void _applyRetryAfter(OwlSonicApiException error) {
    if (error.code != 'RESEND_COOLDOWN' && error.code != 'RATE_LIMITED') return;
    _resendAt = _now().add(error.retryAfter ?? AuthRules.defaultCooldown);
  }

  /// Gives up on this registration (used before registering again).
  Future<void> discard() => _auth.clearPendingVerification();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
