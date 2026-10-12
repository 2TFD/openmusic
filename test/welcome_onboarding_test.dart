import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/config/app_links.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/ui/welcome_screen.dart';

import 'support/first_run_fakes.dart';
import 'support/ux_harness.dart';

void main() {
  useTestLocalization();

  late MemoryOnboardingStore onboarding;
  late List<WelcomeAccountIntent> openedAccount;

  Future<void> pumpWelcome(
    WidgetTester tester, {
    bool configured = true,
    Locale locale = const Locale('en'),
  }) async {
    onboarding = MemoryOnboardingStore();
    openedAccount = [];
    final onboardingCubit = OnboardingCubit(onboarding);
    addTearDown(onboardingCubit.close);
    await onboardingCubit.initialize();
    await pumpApp(
      tester,
      locale: locale,
      home: WelcomeScreen(onOpenAccount: openedAccount.add),
      providers: [
        BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        BlocProvider<CloudSessionCubit>.value(
          value: FakeSessionCubit(configured: configured),
        ),
      ],
    );
  }

  Future<void> tapAndSettle(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pump();
    await tester.pump();
  }

  group('first-run welcome', () {
    testWidgets('says what OwlSonic is in one short screen', (tester) async {
      await pumpWelcome(tester);

      expect(find.text('Your music. Everywhere.'), findsOneWidget);
      expect(
        find.text(
          'Bring the music you own. Listen across devices. '
          'Rediscover your library with Wave.',
        ),
        findsOneWidget,
      );
      expect(find.text('Your music'), findsOneWidget);
      expect(find.text('Everywhere'), findsOneWidget);
      expect(find.text('Rediscover'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I have an account'), findsOneWidget);
      expect(find.text('Continue on this device'), findsOneWidget);
    });

    testWidgets('tells people what an account uploads before they choose, '
        'and does not promise sync without one', (tester) async {
      await pumpWelcome(tester);
      expect(
        find.text(
          'With an account, music you add is uploaded to OwlSonic Cloud.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Without an account, your music stays on this device.'),
        findsOneWidget,
      );
      for (final stale in ['neural', 'AI', 'valence', 'embedding', 'ML ']) {
        expect(find.textContaining(stale), findsNothing, reason: stale);
      }
    });

    testWidgets('has no separate consent step that changes nothing', (
      tester,
    ) async {
      await pumpWelcome(tester);
      expect(find.text('Agree and continue'), findsNothing);
      expect(find.byKey(const ValueKey('privacy-step')), findsNothing);
    });

    testWidgets('is localized in Russian', (tester) async {
      await pumpWelcome(tester, locale: const Locale('ru'));
      expect(find.text('Твоя музыка. Везде.'), findsOneWidget);
      expect(find.text('Начать'), findsOneWidget);
      expect(find.text('У меня есть аккаунт'), findsOneWidget);
      expect(find.text('Продолжить на этом устройстве'), findsOneWidget);
      expect(find.text('Your music. Everywhere.'), findsNothing);
    });

    testWidgets('Continue on this device never needs an account', (
      tester,
    ) async {
      await pumpWelcome(tester);
      await tapAndSettle(tester, 'welcome-continue-local');
      expect(onboarding.completed, isTrue);
      expect(openedAccount, isEmpty);
    });

    testWidgets('Get started opens account creation', (tester) async {
      await pumpWelcome(tester);
      await tapAndSettle(tester, 'welcome-get-started');
      expect(onboarding.completed, isTrue);
      expect(openedAccount, [WelcomeAccountIntent.register]);
    });

    testWidgets('I have an account opens sign-in', (tester) async {
      await pumpWelcome(tester);
      await tapAndSettle(tester, 'welcome-have-account');
      expect(onboarding.completed, isTrue);
      expect(openedAccount, [WelcomeAccountIntent.login]);
    });
  });

  group('builds without a cloud', () {
    testWidgets('offers only the local path', (tester) async {
      await pumpWelcome(tester, configured: false);
      expect(find.byKey(const ValueKey('welcome-have-account')), findsNothing);
      expect(find.byKey(const ValueKey('welcome-account-note')), findsNothing);
      expect(find.text('Everywhere'), findsNothing);

      await tapAndSettle(tester, 'welcome-continue-local');
      expect(onboarding.completed, isTrue);
      expect(openedAccount, isEmpty);
    });
  });

  testWidgets('privacy policy and terms are reachable before any sign-in', (
    tester,
  ) async {
    final opened = <Uri>[];
    final previous = AppLinks.opener;
    AppLinks.opener = (uri) async {
      opened.add(uri);
      return true;
    };
    addTearDown(() => AppLinks.opener = previous);
    for (final configured in [true, false]) {
      await pumpWelcome(tester, configured: configured);
      await tester.ensureVisible(find.byKey(const ValueKey('legal-privacy')));
      await tester.tap(find.byKey(const ValueKey('legal-privacy')));
      await tester.tap(find.byKey(const ValueKey('legal-terms')));
      await tester.pump();
    }
    expect(opened.map((uri) => '$uri'), [
      'https://owlsonic.stream/privacy',
      'https://owlsonic.stream/terms',
      'https://owlsonic.stream/privacy',
      'https://owlsonic.stream/terms',
    ]);
  });
}
