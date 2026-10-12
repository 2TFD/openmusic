import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';

String authText(BuildContext context, AuthMessage message) =>
    context.tr(message.key, namedArgs: message.args);

/// Password input with a show/hide toggle. [showRequirement] adds the
/// "At least 8 characters" hint (registration and reset only).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.showRequirement = false,
    this.validator,
    this.autofillHint = AutofillHints.password,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool showRequirement;
  final String? Function(String?)? validator;
  final String autofillHint;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: !_visible,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: [widget.autofillHint],
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.showRequirement
            ? context.tr('auth.password.helper')
            : null,
        suffixIcon: IconButton(
          tooltip: context.tr(
            _visible ? 'auth.password.hide' : 'auth.password.show',
          ),
          icon: Icon(
            _visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
    );
  }
}

/// Six-digit numeric code input. One field (not six boxes) so that pasting
/// the whole code, keyboard suggestions and OTP autofill all work.
class CodeField extends StatelessWidget {
  const CodeField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.validator,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.oneTimeCode],
      textAlign: TextAlign.center,
      style: AppText.display2.copyWith(letterSpacing: 8),
      inputFormatters: const [_SixDigitsFormatter()],
      decoration: InputDecoration(
        labelText: context.tr('auth.verify.codeLabel'),
        counterText: '',
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted,
    );
  }
}

/// Strips everything but digits (so "123 456" pastes cleanly) and caps at 6.
class _SixDigitsFormatter extends TextInputFormatter {
  const _SixDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = AuthRules.digitsOnly(newValue.text);
    if (digits.length > AuthRules.codeLength) {
      digits = digits.substring(0, AuthRules.codeLength);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

/// Inline error / notice line used by the auth screens.
class AuthStatusLine extends StatelessWidget {
  const AuthStatusLine({super.key, this.error, this.notice});
  final AuthMessage? error;
  final AuthMessage? notice;

  @override
  Widget build(BuildContext context) {
    final message = error ?? notice;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m),
      child: Semantics(
        liveRegion: true,
        child: Text(
          authText(context, message),
          key: ValueKey(error != null ? 'auth-error' : 'auth-notice'),
          style: AppText.bodyS.copyWith(
            color: error != null ? AppColors.error : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}

class BusyLabel extends StatelessWidget {
  const BusyLabel({super.key, required this.busy, required this.label});
  final bool busy;
  final String label;

  @override
  Widget build(BuildContext context) => busy
      ? const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(label);
}
