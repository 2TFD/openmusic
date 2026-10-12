import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/ui/welcome_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/mini_player_bar.dart';
import 'package:owlsonic/layers/presentation/features/startup/ui/startup_screen.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_feature_card.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';

import 'support/first_run_fakes.dart';

void main() {
  const preferencesChannel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, (_) async => {});
    await EasyLocalization.ensureInitialized();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, null);
  });

  void useNarrowLargeTextViewport(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget largeTextApp(Widget home) => MaterialApp(
    theme: AppTheme.dark,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(2)),
      child: child!,
    ),
    home: home,
  );

  testWidgets('flagship card grows for long copy at large text sizes', (
    tester,
  ) async {
    useNarrowLargeTextViewport(tester);
    await tester.pumpWidget(
      largeTextApp(
        Scaffold(
          body: OwlSonicFeatureCard(
            label: 'Карта настроения',
            title: 'Исследовать по настроению',
            description: 'Двигайтесь по библиотеке через ощущения',
            glyph: OwlSonicGlyphType.moodMap,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(OwlSonicFeatureCard)).height,
      greaterThan(110),
    );
  });

  testWidgets('startup screen does not overflow narrow viewport', (
    tester,
  ) async {
    useNarrowLargeTextViewport(tester);

    await tester.pumpWidget(largeTextApp(const StartupScreen()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mini player track copy fits at extreme system text scale', (
    tester,
  ) async {
    useNarrowLargeTextViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(3.2)),
          child: child!,
        ),
        home: const Scaffold(
          body: SizedBox(
            width: 182,
            height: 58,
            child: MiniPlayerTrackInfo(
              title: '19c0a624 with a long track title',
              artist: 'Unknown Artist with a long name',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('19c0a624 with a long track title'), findsOneWidget);
    expect(find.text('Unknown Artist with a long name'), findsOneWidget);
  });

  testWidgets('welcome remains scrollable with large text', (tester) async {
    useNarrowLargeTextViewport(tester);
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => firstRunProviders(
            onboarding: MemoryOnboardingStore(),
            child: MaterialApp(
              theme: AppTheme.dark,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: const WelcomeScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
