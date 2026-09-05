import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_session.dart';
import 'package:openmusic/layers/presentation/blocs/mood_map/mood_map_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/wave_card.dart';

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

  testWidgets('Wave hub renders sources and keeps controls in settings', (
    tester,
  ) async {
    final screen = ValueNotifier(0);
    final state = ValueNotifier(PlayerState());
    final events = <PlayerEvent>[];
    final track = Track(
      id: 'track',
      title: 'Seed song',
      artists: const [Artist(id: 'artist', name: 'Wave Artist')],
      duration: const Duration(minutes: 3),
      source: const Source(type: SourceType.localFile, originalUrl: 'seed.mp3'),
      filePath: 'seed.mp3',
      addedAt: DateTime.utc(2026),
    );
    const artist = ArtistSummary(
      id: 'artist',
      name: 'Wave Artist',
      trackCount: 1,
      totalDuration: Duration(minutes: 3),
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: ValueListenableBuilder<int>(
                valueListenable: screen,
                builder: (context, page, _) => page == 0
                    ? ValueListenableBuilder<PlayerState>(
                        valueListenable: state,
                        builder: (context, value, _) =>
                            WaveCardView(state: value, onConfigure: () {}),
                      )
                    : WaveSettingsSheet(
                        playerState: state.value,
                        tracks: [track],
                        artists: const [artist],
                        moodMapState: const MoodMapState(
                          status: MoodMapStatus.ready,
                        ),
                        onEvent: events.add,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start a Wave'), findsOneWidget);
    expect(find.byKey(const ValueKey('stop-wave')), findsNothing);

    state.value = PlayerState(
      waveSession: WaveSession.startMood(
        targetValence: 0.4,
        targetArousal: -0.2,
        radius: 0.35,
        mode: MoodWaveMode.stay,
      ),
    );
    await tester.pump();
    expect(find.text('Mood · Stay'), findsOneWidget);
    expect(find.byKey(const ValueKey('stop-wave')), findsNothing);

    state.value = PlayerState(
      waveSession: WaveSession.startTrack(
        trackId: track.id,
        trackTitle: track.title,
      ),
    );
    await tester.pump();
    expect(find.text('Based on: Track — Seed song'), findsOneWidget);

    state.value = PlayerState(
      waveSession: WaveSession.startArtist(
        artistId: artist.id,
        artistName: artist.name,
      ),
    );
    await tester.pump();
    expect(find.text('Based on: Artist — Wave Artist'), findsOneWidget);

    state.value = PlayerState(
      waveSession: WaveSession.startMood(
        targetValence: 0.4,
        targetArousal: -0.2,
        radius: 0.35,
        mode: MoodWaveMode.calm,
      ),
    );
    screen.value = 1;
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('stop-wave-in-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('mood-wave-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('wave-radius')), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('mood-wave-settings')),
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('wave-target-map')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byKey(const ValueKey('wave-target-valence')), findsNothing);
    expect(find.byKey(const ValueKey('wave-target-arousal')), findsNothing);
    expect(find.byKey(const ValueKey('choose-mood-target')), findsNothing);

    await tester.tap(find.text('Track'));
    await tester.pump();
    expect(find.byKey(const ValueKey('track-wave-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('wave-radius')), findsNothing);

    await tester.tap(find.text('Artist'));
    await tester.pump();
    expect(find.byKey(const ValueKey('artist-wave-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('wave-radius')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('wave-artist-artist')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('apply-wave-settings')));
    await tester.pumpAndSettle();

    expect(events, hasLength(1));
    final event = events.single as PlayerArtistWaveStarted;
    expect(event.artistId, artist.id);
    expect(event.artistName, artist.name);
  });
}
