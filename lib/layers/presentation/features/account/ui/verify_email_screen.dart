import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/auth_rules.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/verify_email_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/auth_fields.dart';

/// Step two of sign-up: enter the e-mailed six-digit code.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyEmailCubit, VerifyEmailState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == VerifyEmailStatus.done,
      // Signed in; the normal sync starts from the session change.
      listener: (context, _) => context.goNamed(AppRouterNames.home),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          title: Text(context.tr('auth.verify.title'), style: AppText.display3),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
              builder: (context, state) => ListView(
                padding: const EdgeInsets.all(AppSpacing.screenH),
                children: [
                  switch (state.status) {
                    VerifyEmailStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    VerifyEmailStatus.missing => const _Missing(),
                    _ => _VerifyForm(state: state),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Back to the sign-up form; the unusable pending registration is dropped.
Future<void> _createAgain(BuildContext context) async {
  await context.read<VerifyEmailCubit>().discard();
  if (!context.mounted) return;
  if (context.canPop()) {
    context.pop();
  } else {
    context.goNamed(
      AppRouterNames.account,
      queryParameters: const {'mode': 'register'},
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(context.tr('auth.verify.missingTitle'), style: AppText.display3),
      const SizedBox(height: AppSpacing.s),
      Text(context.tr('auth.verify.missingBody'), style: AppText.bodyM),
      const SizedBox(height: AppSpacing.xl),
      FilledButton(
        key: const ValueKey('verify-create-again'),
        onPressed: () => _createAgain(context),
        child: Text(context.tr('auth.verify.createAgain')),
      ),
    ],
  );
}

class _VerifyForm extends StatefulWidget {
  const _VerifyForm({required this.state});
  final VerifyEmailState state;

  @override
  State<_VerifyForm> createState() => _VerifyFormState();
}

class _VerifyFormState extends State<_VerifyForm> {
  final _code = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() => context.read<VerifyEmailCubit>().verify(_code.text);

  Future<void> _resend() async {
    await context.read<VerifyEmailCubit>().resend();
    if (!mounted) return;
    _code.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final hint = state.codeDead
        ? 'auth.verify.dead'
        : state.codeExpired
        ? 'auth.verify.expired'
        : null;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(
              'auth.verify.description',
              namedArgs: {'email': state.email},
            ),
            style: AppText.bodyM,
          ),
          const SizedBox(height: AppSpacing.xl),
          CodeField(
            key: const ValueKey('verify-code'),
            controller: _code,
            focusNode: _focus,
            autofocus: true,
            enabled: !state.submitting,
            onSubmitted: (_) => _submit(),
          ),
          AuthStatusLine(
            error: state.error,
            notice: state.notice ?? (hint == null ? null : AuthMessage(hint)),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            key: const ValueKey('verify-submit'),
            onPressed: state.canSubmit ? _submit : null,
            child: BusyLabel(
              busy: state.submitting,
              label: context.tr('auth.verify.submit'),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          OutlinedButton(
            key: const ValueKey('verify-resend'),
            onPressed: state.canResend ? _resend : null,
            child: BusyLabel(
              busy: state.resending,
              label: state.resendSecondsLeft > 0
                  ? context.tr(
                      'auth.verify.resendIn',
                      namedArgs: {'seconds': '${state.resendSecondsLeft}'},
                    )
                  : context.tr('auth.verify.resend'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(context.tr('auth.verify.trouble'), style: AppText.bodyXS),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('verify-create-again'),
              onPressed: state.submitting ? null : () => _createAgain(context),
              child: Text(context.tr('auth.verify.createAgain')),
            ),
          ),
        ],
      ),
    );
  }
}
