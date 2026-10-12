import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/password_reset_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/auth_fields.dart';

/// Login → Forgot password → Reset password → Login. Pops with the e-mail
/// address after a successful reset; it never signs the user in.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listenWhen: (previous, current) =>
          previous.step != current.step &&
          current.step == PasswordResetStep.done,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('auth.reset.updated'))),
        );
        if (context.canPop()) context.pop(state.email);
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          title: Text(context.tr('auth.reset.title'), style: AppText.display3),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              children: [
                if (state.step == PasswordResetStep.email)
                  _EmailStep(state: state, initialEmail: initialEmail)
                else
                  _CodeStep(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailStep extends StatefulWidget {
  const _EmailStep({required this.state, required this.initialEmail});
  final PasswordResetState state;
  final String initialEmail;

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(
    text: widget.state.email.isNotEmpty
        ? widget.state.email
        : widget.initialEmail,
  );

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<PasswordResetCubit>().requestCode(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.tr('auth.reset.emailDescription'), style: AppText.bodyM),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            key: const ValueKey('reset-email'),
            controller: _email,
            enabled: !state.submitting,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: context.tr('cloud.email')),
            validator: (value) {
              final key = CloudAccountCubit.validateEmail(value ?? '');
              return key == null ? null : context.tr(key);
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          AuthStatusLine(error: state.error),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            key: const ValueKey('reset-send'),
            onPressed: state.submitting ? null : _submit,
            child: BusyLabel(
              busy: state.submitting,
              label: context.tr('auth.reset.sendCode'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeStep extends StatefulWidget {
  const _CodeStep({required this.state});
  final PasswordResetState state;

  @override
  State<_CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends State<_CodeStep> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<PasswordResetCubit>().reset(
      code: _code.text,
      newPassword: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<PasswordResetCubit>();
    String? tr(String? key) => key == null ? null : context.tr(key);
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              state.email,
              style: AppText.display3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              context.tr('auth.reset.codeDescription'),
              style: AppText.bodyM,
            ),
            const SizedBox(height: AppSpacing.xl),
            CodeField(
              key: const ValueKey('reset-code'),
              controller: _code,
              autofocus: true,
              enabled: !state.submitting,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              validator: (value) => tr(AuthRules.validateCode(value ?? '')),
            ),
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              key: const ValueKey('reset-password'),
              controller: _password,
              focusNode: _passwordFocus,
              label: context.tr('auth.password.new'),
              enabled: !state.submitting,
              showRequirement: true,
              autofillHint: AutofillHints.newPassword,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _confirmFocus.requestFocus(),
              validator: (value) =>
                  tr(AuthRules.validateNewPassword(value ?? '')),
            ),
            const SizedBox(height: AppSpacing.m),
            PasswordField(
              key: const ValueKey('reset-confirm'),
              controller: _confirm,
              focusNode: _confirmFocus,
              label: context.tr('auth.password.confirm'),
              enabled: !state.submitting,
              autofillHint: AutofillHints.newPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) => tr(
                AuthRules.validateConfirmation(_password.text, value ?? ''),
              ),
            ),
            AuthStatusLine(
              error: state.error,
              notice:
                  state.notice ??
                  (state.codeDead
                      ? const AuthMessage('auth.errors.codeAttempts')
                      : null),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              key: const ValueKey('reset-submit'),
              onPressed: state.submitting || state.codeDead ? null : _submit,
              child: BusyLabel(
                busy: state.submitting,
                label: context.tr('auth.reset.submit'),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            OutlinedButton(
              key: const ValueKey('reset-resend'),
              onPressed: state.canResend
                  ? () {
                      cubit.requestCode(state.email);
                      _code.clear();
                    }
                  : null,
              child: Text(
                state.resendSecondsLeft > 0
                    ? context.tr(
                        'auth.reset.resendIn',
                        namedArgs: {'seconds': '${state.resendSecondsLeft}'},
                      )
                    : context.tr('auth.reset.resend'),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('reset-change-email'),
                onPressed: state.submitting ? null : cubit.changeEmail,
                child: Text(context.tr('auth.reset.changeEmail')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
