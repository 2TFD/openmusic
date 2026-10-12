import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/app_router/app_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/legal_links.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_logo.dart';

/// Which Account form the user asked for.
enum WelcomeAccountIntent { register, login }

/// First-run: one short screen with three ways in. Listening on this device
/// never needs an account. The cloud choices open the Account form, which
/// states what signing in uploads next to its button.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.onOpenAccount});

  /// Opens Account after onboarding. Defaults to the app router.
  final ValueChanged<WelcomeAccountIntent>? onOpenAccount;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _busy = false;

  void _openAccount(WelcomeAccountIntent intent) {
    final callback = widget.onOpenAccount;
    if (callback != null) {
      callback(intent);
      return;
    }
    AppRouter.router.pushNamed(
      AppRouterNames.account,
      queryParameters: intent == WelcomeAccountIntent.register
          ? const {'mode': 'register'}
          : const {},
    );
  }

  Future<void> _finish({WelcomeAccountIntent? openAccount}) async {
    if (_busy) return;
    setState(() => _busy = true);
    await context.read<OnboardingCubit>().completeOnboarding();
    if (openAccount != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openAccount(openAccount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = context.read<CloudSessionCubit>().state.configured;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Wide windows get a two-column composition; narrow ones keep the
            // compact single column used on phones.
            final wide = constraints.maxWidth >= 860;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1040 : 480),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    wide ? AppSpacing.xxxl : AppSpacing.xxl,
                  ),
                  child: _WelcomeStep(
                    wide: wide,
                    configured: configured,
                    busy: _busy,
                    onGetStarted: () =>
                        _finish(openAccount: WelcomeAccountIntent.register),
                    onHaveAccount: () =>
                        _finish(openAccount: WelcomeAccountIntent.login),
                    onContinueLocal: _finish,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    this.wide = false,
    required this.configured,
    required this.busy,
    required this.onGetStarted,
    required this.onHaveAccount,
    required this.onContinueLocal,
  });

  final bool wide;
  final bool configured;
  final bool busy;
  final VoidCallback onGetStarted;
  final VoidCallback onHaveAccount;
  final VoidCallback onContinueLocal;

  Widget _intro(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: OwlSonicLogo(width: wide ? 168 : 112, opacity: .9),
      ),
      SizedBox(height: wide ? 48 : AppSpacing.xxxl),
      Text(
        context.tr('welcome.title'),
        style: wide
            ? AppText.display1.copyWith(fontSize: 48, height: 1.05)
            : AppText.display1,
      ),
      const SizedBox(height: AppSpacing.m),
      Text(
        context.tr('welcome.subtitle'),
        style: (wide ? AppText.bodyL.copyWith(fontSize: 17) : AppText.bodyL)
            .copyWith(color: AppColors.textSub),
      ),
    ],
  );

  List<Widget> _points(BuildContext context) => [
    _Point(
      icon: Icons.library_music_outlined,
      title: context.tr('welcome.yourMusic'),
      body: context.tr('welcome.yourMusicBody'),
    ),
    if (configured)
      _Point(
        icon: Icons.devices_outlined,
        title: context.tr('welcome.everywhere'),
        body: context.tr('welcome.everywhereBody'),
      ),
    _Point(
      icon: Icons.waves_rounded,
      title: context.tr('welcome.rediscover'),
      body: context.tr('welcome.rediscoverBody'),
    ),
  ];

  List<Widget> _actions(BuildContext context) => [
    if (configured) ...[
      Text(
        context.tr('welcome.accountNote'),
        key: const ValueKey('welcome-account-note'),
        style: AppText.bodyM.copyWith(fontSize: 12),
      ),
      const SizedBox(height: AppSpacing.m),
      FilledButton(
        key: const ValueKey('welcome-get-started'),
        onPressed: busy ? null : onGetStarted,
        child: Text(context.tr('welcome.getStarted')),
      ),
      const SizedBox(height: AppSpacing.s),
      OutlinedButton(
        key: const ValueKey('welcome-have-account'),
        onPressed: busy ? null : onHaveAccount,
        child: Text(context.tr('welcome.haveAccount')),
      ),
      const SizedBox(height: AppSpacing.s),
      TextButton(
        key: const ValueKey('welcome-continue-local'),
        onPressed: busy ? null : onContinueLocal,
        child: Text(context.tr('welcome.continueLocal')),
      ),
      const SizedBox(height: AppSpacing.s),
      Text(
        context.tr('welcome.deviceNote'),
        key: const ValueKey('welcome-device-note'),
        style: AppText.bodyM.copyWith(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    ] else
      FilledButton(
        key: const ValueKey('welcome-continue-local'),
        onPressed: busy ? null : onContinueLocal,
        child: Text(context.tr('welcome.getStarted')),
      ),
    const SizedBox(height: AppSpacing.m),
    const LegalLinks(),
  ];

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return Row(
        key: const ValueKey('welcome-step'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: _intro(context)),
          const SizedBox(width: 64),
          Expanded(
            flex: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._points(context),
                  const SizedBox(height: AppSpacing.l),
                  AppSurface(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    radius: AppRadius.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _actions(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      key: const ValueKey('welcome-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _intro(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._points(context),
        const SizedBox(height: AppSpacing.xxl),
        ..._actions(context),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.l),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.accent),
        const SizedBox(width: AppSpacing.l),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.bodyL),
              const SizedBox(height: 2),
              Text(body, style: AppText.bodyM),
            ],
          ),
        ),
      ],
    ),
  );
}
