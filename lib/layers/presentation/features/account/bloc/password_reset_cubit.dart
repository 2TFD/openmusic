import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';

enum PasswordResetStep { email, code, done }

class PasswordResetState {
  const PasswordResetState({
    this.step = PasswordResetStep.email,
    this.email = '',
    this.submitting = false,
    this.resendSecondsLeft = 0,
    this.codeDead = false,
    this.error,
    this.notice,
  });

  final PasswordResetStep step;
  final String email;
  final bool submitting;
  final int resendSecondsLeft;
  final bool codeDead;
  final AuthMessage? error;
  final AuthMessage? notice;

  bool get canResend => !submitting && resendSecondsLeft == 0;

  PasswordResetState copyWith({
    PasswordResetStep? step,
    String? email,
    bool? submitting,
    int? resendSecondsLeft,
    bool? codeDead,
    AuthMessage? error,
    AuthMessage? notice,
    bool clearError = false,
    bool clearNotice = false,
  }) => PasswordResetState(
    step: step ?? this.step,
    email: email ?? this.email,
    submitting: submitting ?? this.submitting,
    resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
    codeDead: codeDead ?? this.codeDead,
    error: clearError ? null : error ?? this.error,
    notice: clearNotice ? null : notice ?? this.notice,
  );
}

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({
    required CloudAuthRepository auth,
    DateTime Function()? now,
  }) : _auth = auth,
       _now = now ?? (() => DateTime.now().toUtc()),
       super(const PasswordResetState());

  final CloudAuthRepository _auth;
  final DateTime Function() _now;
  Timer? _timer;
  DateTime? _resendAt;

  static const neutralNotice = AuthMessage('auth.reset.codeSentNeutral');

  void _startTimer(DateTime resendAt) {
    _resendAt = resendAt;
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (isClosed) return;
    final resendAt = _resendAt;
    final now = _now();
    final left = resendAt == null || !resendAt.isAfter(now)
        ? 0
        : (resendAt.difference(now).inMilliseconds / 1000).ceil();
    if (left != state.resendSecondsLeft) {
      emit(state.copyWith(resendSecondsLeft: left));
    }
  }

  /// Requests a code. The outcome never says whether the address exists, and
  /// a cooldown means a code was just sent, so both lead to the code step.
  Future<void> requestCode(String email) async {
    if (state.submitting) return;
    if (state.step == PasswordResetStep.code && !state.canResend) return;
    emit(state.copyWith(submitting: true, clearError: true, clearNotice: true));
    try {
      final challenge = await _auth.forgotPassword(email: email);
      if (isClosed) return;
      _startTimer(challenge.resendAvailableAt);
      emit(
        state.copyWith(
          step: PasswordResetStep.code,
          email: email.trim(),
          submitting: false,
          codeDead: false,
          notice: neutralNotice,
        ),
      );
    } on OwlSonicApiException catch (error) {
      if (isClosed) return;
      if (error.code == 'RESEND_COOLDOWN') {
        _startTimer(_now().add(error.retryAfter ?? AuthRules.defaultCooldown));
        emit(
          state.copyWith(
            step: PasswordResetStep.code,
            email: email.trim(),
            submitting: false,
            notice: neutralNotice,
          ),
        );
        return;
      }
      if (error.code == 'RATE_LIMITED') {
        _startTimer(_now().add(error.retryAfter ?? AuthRules.defaultCooldown));
      }
      emit(state.copyWith(submitting: false, error: authMessageFor(error)));
    }
  }

  Future<void> reset({
    required String code,
    required String newPassword,
  }) async {
    if (state.submitting || state.step != PasswordResetStep.code) return;
    emit(state.copyWith(submitting: true, clearError: true, clearNotice: true));
    try {
      await _auth.resetPassword(
        email: state.email,
        code: code,
        newPassword: newPassword,
      );
      if (!isClosed) {
        emit(state.copyWith(submitting: false, step: PasswordResetStep.done));
      }
    } on OwlSonicApiException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          submitting: false,
          error: authMessageFor(error),
          codeDead: state.codeDead || error.code == 'CODE_ATTEMPTS_EXCEEDED',
        ),
      );
    }
  }

  /// Back to the e-mail step (wrong address, or a dead code).
  void changeEmail() => emit(
    state.copyWith(
      step: PasswordResetStep.email,
      codeDead: false,
      clearError: true,
      clearNotice: true,
    ),
  );

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
