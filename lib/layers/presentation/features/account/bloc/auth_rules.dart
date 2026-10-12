import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';

/// Client-side mirror of the documented auth rules; the backend stays the
/// authority.
class AuthRules {
  const AuthRules._();

  static const passwordMinLength = 8;
  static const passwordMaxLength = 128;
  static const codeLength = 6;

  /// Fallback only when a 429 arrives without `Retry-After`.
  static const defaultCooldown = Duration(seconds: 60);

  /// Rule for new passwords (register, reset). Existing accounts may still
  /// log in with older passwords, so login never uses this.
  static String? validateNewPassword(String value) {
    if (value.isEmpty) return 'auth.errors.passwordRequired';
    final length = value.runes.length;
    if (length < passwordMinLength) return 'auth.errors.passwordTooShort';
    if (length > passwordMaxLength) return 'auth.errors.passwordTooLong';
    return null;
  }

  static String? validateConfirmation(String password, String confirmation) {
    if (confirmation.isEmpty) return 'auth.errors.confirmRequired';
    return password == confirmation ? null : 'auth.errors.passwordMismatch';
  }

  static String? validateCode(String value) =>
      RegExp(r'^[0-9]{6}$').hasMatch(value) ? null : 'auth.errors.codeFormat';

  /// Keeps ASCII digits only, so a pasted "123 456" or "123-456" works.
  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');
}

/// A localization key plus its named arguments.
class AuthMessage {
  const AuthMessage(this.key, [this.args = const {}]);
  final String key;
  final Map<String, String> args;

  @override
  bool operator ==(Object other) =>
      other is AuthMessage &&
      other.key == key &&
      other.args.toString() == args.toString();

  @override
  int get hashCode => Object.hash(key, args.toString());
}

/// Maps a backend failure to a friendly message. Branches on `error.code` and
/// validation `type`, never on the server's `message`, and never exposes raw
/// exception text.
AuthMessage authMessageFor(OwlSonicApiException error) {
  if (error.isNetwork) return const AuthMessage('auth.errors.network');
  final seconds = error.retryAfter?.inSeconds;
  switch (error.code) {
    case 'INVALID_CODE':
      return const AuthMessage('auth.errors.invalidCode');
    case 'CODE_ATTEMPTS_EXCEEDED':
      return const AuthMessage('auth.errors.codeAttempts');
    case 'RESEND_COOLDOWN':
      return AuthMessage('auth.errors.resendCooldown', {
        'seconds': '${seconds ?? AuthRules.defaultCooldown.inSeconds}',
      });
    case 'RATE_LIMITED':
      return seconds == null
          ? const AuthMessage('auth.errors.rateLimited')
          : AuthMessage('auth.errors.rateLimitedWait', {'seconds': '$seconds'});
    case 'EMAIL_NOT_VERIFIED':
      return const AuthMessage('auth.errors.emailNotVerified');
    case 'EMAIL_DELIVERY_FAILED':
      return const AuthMessage('auth.errors.emailDeliveryFailed');
    case 'EMAIL_ALREADY_REGISTERED':
      return const AuthMessage('auth.errors.emailAlreadyRegistered');
    case 'INVALID_CREDENTIALS':
      return const AuthMessage('auth.errors.invalidCredentials');
    case 'INVALID_REQUEST':
    case 'validation_error':
      if (error.hasValidation('password_too_short') ||
          error.hasValidation('password_too_long')) {
        return AuthMessage(
          error.hasValidation('password_too_short')
              ? 'auth.errors.passwordTooShort'
              : 'auth.errors.passwordTooLong',
        );
      }
      if (error.hasValidation('invalid_code_format')) {
        return const AuthMessage('auth.errors.codeFormat');
      }
      if (error.validationTypes(field: 'email').isNotEmpty) {
        return const AuthMessage('cloud.errors.emailInvalid');
      }
      return const AuthMessage('auth.errors.invalidRequest');
  }
  final status = error.statusCode ?? 0;
  if (status >= 500 || error.code == 'SERVICE_UNAVAILABLE') {
    return const AuthMessage('auth.errors.backendUnavailable');
  }
  return const AuthMessage('auth.errors.generic');
}
