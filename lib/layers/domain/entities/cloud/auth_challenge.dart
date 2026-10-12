/// Result of an endpoint that e-mails a six-digit code: register (as
/// `PendingVerificationResponse`), resend-verification and forgot-password
/// (as `CodeRequestAccepted`).
class CodeChallenge {
  const CodeChallenge({
    required this.codeLength,
    required this.codeExpiresAt,
    required this.resendAvailableAt,
    this.email,
  });

  /// Normalized address (trimmed, lower-case). Only register returns it.
  final String? email;
  final int codeLength;
  final DateTime codeExpiresAt;
  final DateTime resendAvailableAt;

  /// Throws [FormatException] when a documented field is missing or invalid.
  factory CodeChallenge.fromJson(
    Map<String, dynamic> json, {
    required String expectedStatus,
    required DateTime receivedAt,
  }) {
    final email = json['email'];
    final codeLength = json['code_length'];
    final expiresIn = json['code_expires_in'];
    final resendIn = json['resend_available_in'];
    if (json['status'] != expectedStatus ||
        codeLength is! int ||
        expiresIn is! num ||
        resendIn is! num ||
        (email != null && email is! String)) {
      throw const FormatException('Invalid code challenge');
    }
    return CodeChallenge(
      email: email as String?,
      codeLength: codeLength,
      codeExpiresAt: receivedAt.add(Duration(seconds: expiresIn.toInt())),
      resendAvailableAt: receivedAt.add(Duration(seconds: resendIn.toInt())),
    );
  }
}

/// A registration that still waits for its e-mail code. Persisted so the
/// code screen can be resumed after an app restart. Never holds the code.
class PendingVerification {
  const PendingVerification({
    required this.email,
    required this.installationId,
    required this.codeExpiresAt,
    required this.resendAvailableAt,
  });

  final String email;

  /// The `device.installation_id` sent to register; verify-email must reuse it.
  final String installationId;
  final DateTime codeExpiresAt;
  final DateTime resendAvailableAt;

  PendingVerification withChallenge(CodeChallenge challenge) =>
      PendingVerification(
        email: email,
        installationId: installationId,
        codeExpiresAt: challenge.codeExpiresAt,
        resendAvailableAt: challenge.resendAvailableAt,
      );

  PendingVerification withResendAvailableAt(DateTime value) =>
      PendingVerification(
        email: email,
        installationId: installationId,
        codeExpiresAt: codeExpiresAt,
        resendAvailableAt: value,
      );

  Map<String, dynamic> toJson() => {
    'email': email,
    'installationId': installationId,
    'codeExpiresAt': codeExpiresAt.toUtc().toIso8601String(),
    'resendAvailableAt': resendAvailableAt.toUtc().toIso8601String(),
  };

  factory PendingVerification.fromJson(Map<String, dynamic> json) =>
      PendingVerification(
        email: json['email'] as String,
        installationId: json['installationId'] as String,
        codeExpiresAt: DateTime.parse(json['codeExpiresAt'] as String),
        resendAvailableAt: DateTime.parse(json['resendAvailableAt'] as String),
      );
}
