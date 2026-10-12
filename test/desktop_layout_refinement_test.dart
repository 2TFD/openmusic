import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/desktop_home.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/ui/welcome_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';

import 'support/first_run_fakes.dart';
import 'support/ux_harness.dart';

void main() {
  useTestLocalization();

  // The override must be cleared before the test body ends: the binding
  // checks foundation debug variables before tearDown callbacks run.
  void desktopTest(
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) => testWidgets(description, (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  group('desktop Welcome', () {
    Future<void> pumpWelcome(
      WidgetTester tester,
      Size size, {
      Locale locale = const Locale('en'),
    }) async {
      final cubit = OnboardingCubit(MemoryOnboardingStore());
      addTearDown(cubit.close);
      await cubit.initialize();
      await pumpApp(
        tester,
        size: size,
        locale: locale,
        home: WelcomeScreen(onOpenAccount: (_) {}),
        providers: [
          BlocProvider<OnboardingCubit>.value(value: cubit),
          BlocProvider<CloudSessionCubit>.value(value: FakeSessionCubit()),
        ],
      );
    }

    desktopTest('wide windows put the message and the actions side by side', (
      tester,
    ) async {
      await pumpWelcome(tester, const Size(1280, 800));
      final title = tester.getRect(find.text('Your music. Everywhere.'));
      final start = tester.getRect(
        find.byKey(const ValueKey('welcome-get-started')),
      );
      expect(title.right, lessThan(start.left));
      // The composition is centered, not a small form in a corner.
      expect(title.left, greaterThan(100));
      expect(
        find.byKey(const ValueKey('welcome-have-account')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('welcome-continue-local')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    desktopTest('narrow windows stack into one readable column', (
      tester,
    ) async {
      await pumpWelcome(tester, const Size(800, 700));
      final title = tester.getRect(find.text('Your music. Everywhere.'));
      final start = tester.getRect(
        find.byKey(const ValueKey('welcome-get-started')),
      );
      expect(title.bottom, lessThan(start.top));
      expect(tester.takeException(), isNull);
    });

    desktopTest('Russian does not overflow at any desktop width', (
      tester,
    ) async {
      for (final size in const [Size(800, 700), Size(1280, 800)]) {
        await pumpWelcome(tester, size, locale: const Locale('ru'));
        expect(tester.takeException(), isNull, reason: '$size');
      }
    });
  });

  group('desktop Home', () {
    final tracks = [
      localTrack('a', 'First song', addedAt: DateTime(2026, 1, 2)),
      localTrack('b', 'Second song', addedAt: DateTime(2026, 1, 3)),
    ];

    Future<void> pumpHome(WidgetTester tester, Size size) async {
      final cloud = await CloudStatusRig.create(signedIn: true);
      addTearDown(cloud.dispose);
      final readiness = WaveReadinessCubit(
        repository: FakeMoodRepository([moodEntry('a')]),
      );
      addTearDown(readiness.close);
      await readiness.initialize();
      await pumpApp(
        tester,
        size: size,
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => DesktopHome(tracks: tracks),
            ),
          ],
        ),
        providers: [
          BlocProvider<PlayerBloc>.value(value: RecordingPlayerBloc()),
          BlocProvider<HistoryBloc>.value(value: FakeHistoryBloc()),
          BlocProvider<PlaylistBloc>.value(value: FakePlaylistBloc()),
          BlocProvider<WaveReadinessCubit>.value(value: readiness),
          BlocProvider<CloudStatusCubit>.value(value: cloud.cubit),
        ],
      );
    }

    for (final size in const [
      Size(800, 700),
      Size(1000, 800),
      Size(1280, 800),
      Size(1440, 900),
      Size(1920, 1080),
    ]) {
      desktopTest('lays out without overflow at ${size.width.toInt()}'
          '×${size.height.toInt()}', (tester) async {
        await pumpHome(tester, size);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('wave-card')), findsOneWidget);
        expect(find.text('First song'), findsOneWidget);
        // Wide windows use the free space beside Wave for Library and
        // History; narrow ones keep them as chips below it.
        final panel = find.byKey(const ValueKey('desktop-library-panel'));
        if (size.width >= 1000) {
          expect(panel, findsOneWidget);
          final wave = tester.getRect(find.byKey(const ValueKey('wave-card')));
          expect(tester.getRect(panel).left, greaterThan(wave.right));
        } else {
          expect(panel, findsNothing);
        }
      });
    }
  });
}
