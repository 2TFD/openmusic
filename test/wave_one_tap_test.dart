import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/wave_card.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';

import 'support/ux_harness.dart';

void main() {
  useTestLocalization();

  group('default Wave', () {
    test('starts around the average mood of playable analyzed songs', () {
      final summary = WaveReadinessCubit.summarize([
        moodEntry('a', valence: 0.6, arousal: 0.2),
        moodEntry('b', valence: 0.2, arousal: -0.4),
      ]);
      expect(summary.isReady, isTrue);
      expect(summary.readyCount, 2);
      expect(summary.center!.valence, closeTo(0.4, 1e-9));
      expect(summary.center!.arousal, closeTo(-0.1, 1e-9));
    });

    test('uses the listener’s own placement, not only the model’s', () {
      final summary = WaveReadinessCubit.summarize([
        moodEntry(
          'a',
          valence: -0.8,
          arousal: -0.8,
          personal: PersonalMoodAdjustment(
            trackId: 'a',
            valence: 0.5,
            arousal: 0.5,
            updatedAt: DateTime.utc(2026),
          ),
        ),
      ]);
      expect(summary.center!.valence, 0.5);
      expect(summary.center!.arousal, 0.5);
    });

    test('ignores songs that cannot be played yet', () {
      final pending = Track(
        id: 'p',
        title: 'Pending',
        artists: const [Artist(id: 'a', name: 'Owl Artist')],
        duration: const Duration(minutes: 3),
        source: const Source(type: SourceType.localFile, originalUrl: '/p.mp3'),
        addedAt: DateTime(2026),
      );
      final summary = WaveReadinessCubit.summarize([
        moodEntry('p', track: pending, valence: 0.9, arousal: 0.9),
        moodEntry('ok', valence: -0.2, arousal: 0),
      ]);
      expect(summary.readyCount, 1);
      expect(summary.center!.valence, -0.2);
    });

    test('is not ready without analyzed songs', () {
      final summary = WaveReadinessCubit.summarize(const []);
      expect(summary.loaded, isTrue);
      expect(summary.isReady, isFalse);
      expect(summary.center, isNull);
    });

    test('one event: a mood Wave with the default style and variety', () async {
      final cubit = WaveReadinessCubit(
        repository: FakeMoodRepository([
          moodEntry('a', valence: 0.3, arousal: 0.1),
        ]),
      );
      addTearDown(cubit.close);

      final event = await defaultWaveEvent(cubit) as PlayerMoodWaveStarted;
      expect(event.targetValence, closeTo(0.3, 1e-9));
      expect(event.targetArousal, closeTo(0.1, 1e-9));
      expect(event.radius, WaveReadinessCubit.defaultRadius);
      expect(event.mode, MoodWaveMode.stay);
      expect(event.autoPlay, isTrue);
    });

    test('no event when nothing is ready', () async {
      final cubit = WaveReadinessCubit(repository: FakeMoodRepository());
      addTearDown(cubit.close);
      expect(await defaultWaveEvent(cubit), isNull);
    });
  });

  group('Wave card', () {
    Future<RecordingPlayerBloc> pumpCard(
      WidgetTester tester, {
      required List<MoodMapTrack> analyzed,
      PlayerState? state,
      bool signedIn = true,
      Size size = const Size(420, 900),
      Locale locale = const Locale('en'),
    }) async {
      final cloud = await CloudStatusRig.create(signedIn: signedIn);
      addTearDown(cloud.dispose);
      final player = RecordingPlayerBloc(state);
      final readiness = WaveReadinessCubit(
        repository: FakeMoodRepository(analyzed),
      );
      addTearDown(readiness.close);
      await readiness.initialize();
      await pumpApp(
        tester,
        size: size,
        locale: locale,
        home: const Scaffold(body: SingleChildScrollView(child: WaveCard())),
        providers: [
          BlocProvider<PlayerBloc>.value(value: player),
          BlocProvider<WaveReadinessCubit>.value(value: readiness),
          BlocProvider<CloudStatusCubit>.value(value: cloud.cubit),
        ],
      );
      return player;
    }

    testWidgets('Start Wave plays music in one tap, without a settings sheet', (
      tester,
    ) async {
      final player = await pumpCard(
        tester,
        analyzed: [moodEntry('a', valence: 0.4, arousal: 0.2)],
      );

      await tester.tap(find.byKey(const ValueKey('wave-card-start')));
      await tester.pump();
      await tester.pump();

      expect(player.events.single, isA<PlayerMoodWaveStarted>());
      // Nothing technical was put in the way.
      expect(find.byKey(const ValueKey('apply-wave-settings')), findsNothing);
      expect(find.byKey(const ValueKey('wave-radius')), findsNothing);
    });

    testWidgets('offers Choose a mood and Customize as secondary actions', (
      tester,
    ) async {
      await pumpCard(tester, analyzed: [moodEntry('a')]);
      expect(find.text('Start Wave'), findsWidgets);
      expect(
        find.byKey(const ValueKey('wave-card-choose-mood')),
        findsOneWidget,
      );
      expect(find.text('Choose a mood'), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-customize')), findsOneWidget);
      // On a phone Customize is an icon (with a label for screen readers and
      // long-press) so the actions stay on one row.
      expect(find.byTooltip('Customize'), findsOneWidget);
    });

    testWidgets('keeps the Customize label when there is room', (tester) async {
      await pumpCard(
        tester,
        analyzed: [moodEntry('a')],
        size: const Size(700, 900),
      );
      expect(find.text('Customize'), findsOneWidget);
    });

    testWidgets('actions fit a phone in English and Russian without overflow', (
      tester,
    ) async {
      await pumpCard(
        tester,
        analyzed: [moodEntry('a')],
        size: const Size(390, 800),
      );
      // Test fonts are wider than the real ones, so the single-row layout is
      // checked on a device; here: no overflow and comfortable touch targets.
      final customize = tester.getRect(
        find.byKey(const ValueKey('wave-card-customize')),
      );
      expect(customize.width, greaterThanOrEqualTo(44));
      expect(customize.height, greaterThanOrEqualTo(44));
      expect(tester.takeException(), isNull);

      await pumpCard(
        tester,
        analyzed: [moodEntry('a')],
        size: const Size(320, 800),
        locale: const Locale('ru'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('describes the default Wave as library-derived', (
      tester,
    ) async {
      await pumpCard(tester, analyzed: [moodEntry('a')]);
      expect(
        find.text(
          'Music from your library, starting from the mood of your analyzed songs.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('while songs are not analyzed it explains and offers no dead '
        'Start', (tester) async {
      final player = await pumpCard(tester, analyzed: const []);

      expect(find.text('Wave is getting ready'), findsOneWidget);
      expect(
        find.textContaining('You can already play your music'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
      expect(find.text('No analyzed tracks yet'), findsNothing);
      expect(player.events, isEmpty);
    });

    testWidgets('signed out, it says Wave needs the cloud instead of waiting '
        'forever', (tester) async {
      await pumpCard(tester, analyzed: const [], signedIn: false);

      expect(find.text('Wave needs OwlSonic Cloud'), findsOneWidget);
      expect(find.textContaining('Sign in to get your library'), findsOne);
      expect(find.byKey(const ValueKey('wave-card-sign-in')), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
      expect(find.text('Wave is getting ready'), findsNothing);
    });

    testWidgets('signed out but already analyzed music can still start', (
      tester,
    ) async {
      await pumpCard(tester, analyzed: [moodEntry('a')], signedIn: false);
      expect(find.byKey(const ValueKey('wave-card-start')), findsOneWidget);
      expect(find.text('Wave needs OwlSonic Cloud'), findsNothing);
    });

    testWidgets('while Wave plays it says so and can stop', (tester) async {
      await pumpCard(
        tester,
        analyzed: [moodEntry('a')],
        state: PlayerState(
          waveSession: WaveSession.startMood(
            targetValence: -0.5,
            targetArousal: -0.5,
            radius: 0.35,
            mode: MoodWaveMode.stay,
          ),
        ),
      );
      expect(find.text('Wave is playing'), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-stop')), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
    });

    testWidgets('card copy has no technical vocabulary', (tester) async {
      await pumpCard(tester, analyzed: [moodEntry('a')]);
      for (final word in ['valence', 'arousal', 'embedding', 'radius']) {
        expect(find.textContaining(word, findRichText: true), findsNothing);
      }
    });
  });
}
