import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/app_router/app_shell.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/desktop_home.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/home_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';

import 'support/ux_harness.dart';

class _History extends FakeHistoryBloc {
  _History(this.tracks);
  final List<Track> tracks;
  @override
  HistoryState get state => HistoryLoaded(tracks: tracks);
}

void main() {
  useTestLocalization();

  Track track(String id, String title, {int day = 1}) =>
      localTrack(id, title, addedAt: DateTime(2026, 1, day));

  Future<RecordingPlayerBloc> pumpHome(
    WidgetTester tester, {
    required List<Track> tracks,
    List<Track> history = const [],
    PlayerState? player,
    bool analyzed = true,
    bool inShell = false,
    Size size = const Size(390, 844),
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    final cloud = await CloudStatusRig.create(
      signedIn: true,
      sync: CloudSyncStatus(lastSyncedAt: DateTime.utc(2026)),
    );
    addTearDown(cloud.dispose);
    final readiness = WaveReadinessCubit(
      repository: FakeMoodRepository([
        if (analyzed) moodEntry('a', valence: .2, arousal: .1),
      ]),
    );
    addTearDown(readiness.close);
    await readiness.initialize();
    final bloc = RecordingPlayerBloc(player);
    GoRoute home() => GoRoute(
      path: '/',
      builder: (_, _) => MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const HomeScreen(),
      ),
    );
    await pumpApp(
      tester,
      size: size,
      locale: locale,
      router: GoRouter(
        routes: [
          if (inShell)
            ShellRoute(
              builder: (_, _, child) => AppShell(child: child),
              routes: [home()],
            )
          else
            home(),
          for (final name in [
            AppRouterNames.search,
            AppRouterNames.importMusic,
            AppRouterNames.library,
            AppRouterNames.account,
            AppRouterNames.moodMap,
            AppRouterNames.allPlaylists,
          ])
            GoRoute(
              path: '/$name',
              name: name,
              builder: (_, _) => const SizedBox(),
            ),
        ],
      ),
      providers: [
        BlocProvider<TrackBloc>.value(value: FakeTrackBloc(tracks)),
        BlocProvider<HistoryBloc>.value(value: _History(history)),
        BlocProvider<PlaylistBloc>.value(value: FakePlaylistBloc()),
        BlocProvider<PlayerBloc>.value(value: bloc),
        BlocProvider<MusicAnalysisStatusCubit>.value(
          value: FakeAnalysisCubit(),
        ),
        BlocProvider<CloudSessionCubit>.value(
          value: FakeSessionCubit(signedIn: true),
        ),
        BlocProvider<CloudStatusCubit>.value(value: cloud.cubit),
        BlocProvider<WaveReadinessCubit>.value(value: readiness),
      ],
    );
    return bloc;
  }

  final library = [
    for (var i = 1; i <= 8; i++) track('t$i', 'Song $i', day: i),
  ];

  double top(WidgetTester tester, Finder finder) =>
      tester.getTopLeft(finder).dy;

  testWidgets('sections appear in the Wave-first order', (tester) async {
    await pumpHome(tester, tracks: library, history: library.take(2).toList());
    final order = [
      top(tester, find.byKey(const ValueKey('home-library-hero'))),
      top(tester, find.byKey(const ValueKey('wave-card'))),
      top(tester, find.text('RECENTLY ADDED')),
    ];
    expect(order, orderedEquals([...order]..sort()));
    expect(order.toSet(), hasLength(3));
    // No bottom navigation bar.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('My Library is a compact utility card', (tester) async {
    await pumpHome(tester, tracks: library);
    final hero = tester.getRect(
      find.byKey(const ValueKey('home-library-hero')),
    );
    // Real fonts give ~65dp; test fonts are wider and wrap the status line.
    expect(hero.height, lessThan(150));
    expect(find.text('8 tracks'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-add-music-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('cloud-status-line')), findsOneWidget);
  });

  group('Wave card', () {
    testWidgets('idle: title, tagline, Start Wave, Choose a mood, Customize', (
      tester,
    ) async {
      final player = await pumpHome(tester, tracks: library);
      expect(find.text('Wave'), findsOneWidget);
      expect(find.text('Your music, rediscovered.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('wave-card-choose-mood')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('wave-card-customize')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('wave-card-start')));
      await tester.pump();
      await tester.pump();
      expect(player.events.single, isA<PlayerMoodWaveStarted>());
    });

    testWidgets('playing: noticeably shorter, no transport controls', (
      tester,
    ) async {
      await pumpHome(tester, tracks: library);
      final idle = tester.getSize(find.byKey(const ValueKey('wave-card')));

      await pumpHome(
        tester,
        tracks: library,
        player: PlayerState(
          waveSession: WaveSession.startMood(
            targetValence: .4,
            targetArousal: -.2,
            radius: .35,
            mode: MoodWaveMode.stay,
          ),
        ),
      );
      final active = tester.getSize(find.byKey(const ValueKey('wave-card')));
      expect(active.height, lessThan(idle.height - 20));
      expect(find.text('Wave is playing'), findsOneWidget);
      expect(find.text('Mood: Bright and warm'), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-stop')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('wave-card-choose-mood')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('wave-card-customize')), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
      expect(find.byIcon(Icons.pause), findsNothing);
      expect(find.byIcon(Icons.skip_next), findsNothing);
    });

    testWidgets('unavailable: no Start button while nothing is analyzed', (
      tester,
    ) async {
      await pumpHome(tester, tracks: library, analyzed: false);
      expect(find.text('Wave is getting ready'), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
    });
  });

  testWidgets('Continue Listening is gone, even with play history', (
    tester,
  ) async {
    await pumpHome(tester, tracks: library, history: library.take(3).toList());
    expect(find.text('CONTINUE LISTENING'), findsNothing);
    expect(find.byKey(const ValueKey('home-continue-listening')), findsNothing);
    // History stays reachable from Home.
    expect(find.text('History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Recently Added', () {
    testWidgets('is an artwork shelf of 108–124dp that scrolls sideways', (
      tester,
    ) async {
      await pumpHome(tester, tracks: library);
      final card = find.byKey(const ValueKey('home-shelf-t8'));
      final size = tester.getSize(card);
      expect(size.width, inInclusiveRange(108, 124));
      // Newest first, about three visible across, more beyond the edge.
      final visible = library.reversed.where(
        (t) => tester.any(find.byKey(ValueKey('home-shelf-${t.id}'))),
      );
      expect(visible.length, greaterThanOrEqualTo(3));
      final last = find.byKey(const ValueKey('home-shelf-t1'));
      await tester.drag(find.byType(ListView).first, const Offset(-3000, 0));
      await tester.pumpAndSettle();
      expect(tester.getRect(last).right, lessThanOrEqualTo(390));
      expect(tester.getRect(last).left, greaterThan(0));
    });

    testWidgets('a one-song library still lays out', (tester) async {
      await pumpHome(tester, tracks: [library.first]);
      expect(find.byKey(const ValueKey('home-shelf-t1')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('Home scrolls fully above the mini-player', (tester) async {
    final playing = library.first;
    await pumpHome(
      tester,
      tracks: library,
      history: library.take(3).toList(),
      inShell: true,
      size: const Size(390, 700),
      player: PlayerState(
        currentTrack: playing,
        queue: [playing],
        duration: const Duration(minutes: 3),
      ),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    final history = tester.getRect(find.text('History').last);
    final mini = tester.getRect(find.text('Song 1').last);
    expect(history.bottom, lessThanOrEqualTo(mini.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop Home keeps its own Wave card and copy', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final cloud = await CloudStatusRig.create(signedIn: true);
      addTearDown(cloud.dispose);
      final readiness = WaveReadinessCubit(
        repository: FakeMoodRepository([moodEntry('a')]),
      );
      addTearDown(readiness.close);
      await readiness.initialize();
      await pumpApp(
        tester,
        size: const Size(1280, 800),
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => DesktopHome(tracks: library),
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
      expect(find.text('Your music, rediscovered.'), findsNothing);
      expect(find.byKey(const ValueKey('desktop-library-panel')), findsOne);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
