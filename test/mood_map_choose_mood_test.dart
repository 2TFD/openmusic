import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/logic/mood_description.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/ui/mood_map_page.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';

import 'support/ux_harness.dart';

void main() {
  useTestLocalization();

  group('mood descriptions', () {
    test('map positions to plain-language names', () {
      String name(double v, double a) =>
          MoodDescription.keyFor(valence: v, arousal: a);
      expect(name(0, 0), 'moodMap.descriptions.balanced');
      expect(name(0.8, 0.8), 'moodMap.descriptions.upbeat');
      expect(name(-0.8, 0.8), 'moodMap.descriptions.intenseDark');
      expect(name(-0.8, -0.8), 'moodMap.descriptions.calmDark');
      expect(name(0.8, -0.8), 'moodMap.descriptions.soft');
      expect(name(0, -0.8), 'moodMap.descriptions.calm');
      expect(name(0, 0.8), 'moodMap.descriptions.energetic');
      expect(name(-0.8, 0), 'moodMap.descriptions.dark');
      expect(name(0.8, 0), 'moodMap.descriptions.bright');
    });
  });

  group('Choose a mood', () {
    late FakeMoodRepository repository;
    late MoodMapCubit cubit;
    late List<PlayerEvent> events;

    Future<void> pumpPage(
      WidgetTester tester, {
      required List<MoodMapTrack> entries,
      Size size = const Size(420, 900),
    }) async {
      repository = FakeMoodRepository(entries);
      cubit = MoodMapCubit(
        repository: repository,
        analytics: const NoopAnalyticsTracker(),
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      events = [];
      await pumpApp(
        tester,
        size: size,
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => BlocProvider.value(
                value: cubit,
                child: MoodMapPage(onEvent: events.add),
              ),
            ),
          ],
        ),
      );
    }

    Future<void> chooseUpbeatMood(WidgetTester tester) async {
      final viewer = find.byType(InteractiveViewer);
      await tester.tapAt(tester.getTopRight(viewer) + const Offset(-40, 40));
      await tester.pump();
    }

    testWidgets('is titled for the task, not the data', (tester) async {
      await pumpPage(tester, entries: [moodEntry('a')]);
      expect(find.text('Choose a mood'), findsOneWidget);
      expect(find.text('Mood Map'), findsNothing);
    });

    testWidgets('Play this mood starts a Wave with the chosen mood', (
      tester,
    ) async {
      await pumpPage(
        tester,
        entries: [moodEntry('a', valence: 0.7, arousal: 0.7)],
      );

      FilledButton button() => tester.widget<FilledButton>(
        find.byKey(const ValueKey('play-this-mood')),
      );
      expect(button().onPressed, isNull, reason: 'nothing chosen yet');
      expect(find.text('Tap the map to choose a mood'), findsOneWidget);

      await chooseUpbeatMood(tester);
      expect(find.text('Upbeat and bright'), findsOneWidget);
      expect(find.textContaining('songs nearby'), findsOneWidget);
      expect(button().onPressed, isNotNull);

      await tester.tap(find.byKey(const ValueKey('play-this-mood')));
      await tester.pump();

      final started = events.single as PlayerMoodWaveStarted;
      expect(started.targetValence, greaterThan(0.33));
      expect(started.targetArousal, greaterThan(0.33));
      expect(started.radius, cubit.state.radius);
      expect(started.mode, MoodWaveMode.stay);
      expect(started.autoPlay, isTrue);
    });

    testWidgets('the old dead-end action is gone and raw values stay hidden', (
      tester,
    ) async {
      await pumpPage(tester, entries: [moodEntry('a')]);
      await chooseUpbeatMood(tester);

      expect(find.text('Use this target'), findsNothing);
      expect(find.byKey(const ValueKey('select-mood-target')), findsNothing);
      for (final word in ['valence', 'arousal', 'radius', 'Model position']) {
        expect(find.textContaining(word, findRichText: true), findsNothing);
      }
      expect(find.textContaining(RegExp(r'V -?\d')), findsNothing);
      expect(find.textContaining(RegExp(r'\d\.\d\d')), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('desktop: a selected song offers Play and Wave from it', (
      tester,
    ) async {
      final entry = moodEntry('a', valence: 0.5, arousal: 0.5);
      await pumpPage(tester, entries: [entry], size: const Size(1280, 800));
      expect(find.byKey(const ValueKey('mood-track-play')), findsNothing);

      cubit.selectTrack('a');
      await flushMicrotasks();
      await tester.pump();

      expect(find.text('Song a'), findsOneWidget);
      expect(find.text('Upbeat and bright'), findsOneWidget);
      expect(find.text('Calm'), findsWidgets, reason: 'tag without a score');
      expect(find.textContaining('%'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('mood-track-play')));
      await tester.pump();
      final play = events.last as PlayerQueueSet;
      expect(play.tracks.single.id, 'a');
      expect(play.startTrack?.id, 'a');
      expect(play.autoPlay, isTrue);

      await tester.tap(find.byKey(const ValueKey('mood-track-wave')));
      await tester.pump();
      expect((events.last as PlayerTrackWaveStarted).track.id, 'a');
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('desktop: Play this mood starts a Wave from the page', (
      tester,
    ) async {
      await pumpPage(
        tester,
        entries: [moodEntry('a')],
        size: const Size(1280, 800),
      );
      cubit.setTarget(0.7, -0.6);
      await flushMicrotasks();
      await tester.pump();
      expect(find.text('Soft and gentle'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('play-this-mood')));
      await tester.pump();

      final started = events.single as PlayerMoodWaveStarted;
      expect(started.targetValence, 0.7);
      expect(started.targetArousal, -0.6);
      // The "Wave is playing" confirmation clears itself.
      await tester.pump(const Duration(seconds: 10));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    testWidgets('personal placement stays, shows plainly, and can be reset', (
      tester,
    ) async {
      final personal = moodEntry(
        'a',
        valence: -0.5,
        arousal: -0.5,
        personal: PersonalMoodAdjustment(
          trackId: 'a',
          valence: 0.6,
          arousal: 0.6,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await pumpPage(
        tester,
        entries: [personal, moodEntry('b')],
        size: const Size(1280, 800),
      );

      cubit.selectTrack('a');
      await flushMicrotasks();
      await tester.pump();
      expect(find.text('You placed this song here.'), findsOneWidget);
      // The song is described by where the listener put it, not the model.
      expect(find.text('Upbeat and bright'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('mood-track-reset')));
      await tester.pump();
      expect(repository.reset, ['a']);

      cubit.selectTrack('b');
      await flushMicrotasks();
      await tester.pump();
      expect(find.text('Placed by OwlSonic.'), findsOneWidget);
      expect(find.byKey(const ValueKey('mood-track-reset')), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    test('saving a placement keeps the exact position', () async {
      final repo = FakeMoodRepository([moodEntry('a')]);
      final cubit = MoodMapCubit(
        repository: repo,
        analytics: const NoopAnalyticsTracker(),
      );
      addTearDown(cubit.close);
      await cubit.initialize();

      await cubit.savePersonalPosition('a', 0.25, -0.75);

      expect(repo.saved.single.trackId, 'a');
      expect(repo.saved.single.valence, 0.25);
      expect(repo.saved.single.arousal, -0.75);
    });

    testWidgets('an empty map explains itself without technical words', (
      tester,
    ) async {
      await pumpPage(tester, entries: const []);
      expect(find.text('Your map is getting ready'), findsOneWidget);
      expect(find.textContaining('analyzed tracks'), findsNothing);
    });
  });
}
