import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/home_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';

import 'support/ux_harness.dart';

void main() {
  useTestLocalization();

  final synced = CloudSyncStatus(lastSyncedAt: DateTime.utc(2026, 1, 1));
  final visited = <String>[];

  setUp(visited.clear);

  GoRouter homeRouter() => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      for (final name in [
        AppRouterNames.search,
        AppRouterNames.importMusic,
        AppRouterNames.library,
        AppRouterNames.account,
        AppRouterNames.wave,
        AppRouterNames.moodMap,
        AppRouterNames.allPlaylists,
      ])
        GoRoute(
          path: '/$name',
          name: name,
          builder: (_, _) {
            visited.add(name);
            return Scaffold(appBar: AppBar(), body: Text('page:$name'));
          },
        ),
    ],
  );

  Future<({CloudStatusRig cloud, RecordingPlayerBloc player})> pumpHome(
    WidgetTester tester, {
    List<Track> tracks = const [],
    bool signedIn = false,
    CloudSyncStatus? sync,
    bool analyzed = true,
    int pending = 0,
  }) async {
    final cloud = await CloudStatusRig.create(
      signedIn: signedIn,
      sync: sync ?? (signedIn ? synced : const CloudSyncStatus()),
      pending: pending,
    );
    addTearDown(cloud.dispose);
    final readiness = WaveReadinessCubit(
      repository: FakeMoodRepository([
        if (analyzed) moodEntry('a', valence: 0.2, arousal: 0.1),
      ]),
    );
    addTearDown(readiness.close);
    await readiness.initialize();
    final player = RecordingPlayerBloc();
    await pumpApp(
      tester,
      router: homeRouter(),
      providers: [
        BlocProvider<TrackBloc>.value(value: FakeTrackBloc(tracks)),
        BlocProvider<HistoryBloc>.value(value: FakeHistoryBloc()),
        BlocProvider<PlaylistBloc>.value(value: FakePlaylistBloc()),
        BlocProvider<PlayerBloc>.value(value: player),
        BlocProvider<MusicAnalysisStatusCubit>.value(
          value: FakeAnalysisCubit(),
        ),
        BlocProvider<CloudSessionCubit>.value(
          value: FakeSessionCubit(signedIn: signedIn),
        ),
        BlocProvider<CloudStatusCubit>.value(value: cloud.cubit),
        BlocProvider<WaveReadinessCubit>.value(value: readiness),
      ],
    );
    return (cloud: cloud, player: player);
  }

  final tracks = [
    localTrack('a', 'First song', addedAt: DateTime(2026, 1, 2)),
    localTrack('b', 'Second song', addedAt: DateTime(2026, 1, 3)),
  ];

  group('empty Home', () {
    testWidgets('signed out: a clear first step and a way to sign in', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('Your music starts here'), findsOneWidget);
      expect(
        find.textContaining('Add your songs to start listening.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('home-add-music')), findsOneWidget);
      expect(find.text('Add music'), findsOneWidget);
      expect(find.text('Sign in to access your library'), findsOneWidget);

      // No active Wave that would lead to "No analyzed tracks yet".
      expect(find.byKey(const ValueKey('wave-card')), findsNothing);
      expect(find.text('Start Wave'), findsNothing);
      expect(find.text('No analyzed tracks yet'), findsNothing);
      expect(find.text('Explore by Mood'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('home-add-music')));
      await tester.pumpAndSettle();
      expect(visited, [AppRouterNames.importMusic]);
    });

    testWidgets('signed out: sign-in leads to Account', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.byKey(const ValueKey('home-sign-in')));
      await tester.pumpAndSettle();
      expect(visited, [AppRouterNames.account]);
    });

    testWidgets('signed in with an empty cloud library: add music, no '
        'sign-in prompt', (tester) async {
      await pumpHome(tester, signedIn: true);
      expect(find.text('Your music starts here'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-add-music')), findsOneWidget);
      expect(find.byKey(const ValueKey('home-sign-in')), findsNothing);
    });

    testWidgets('signed in and still syncing: does not claim the library is '
        'empty', (tester) async {
      await pumpHome(tester, signedIn: true, sync: const CloudSyncStatus());
      expect(find.byKey(const ValueKey('home-syncing-library')), findsOne);
      expect(find.text('Syncing your library…'), findsWidgets);
      expect(find.text('Your music starts here'), findsNothing);
      expect(find.byKey(const ValueKey('home-add-music')), findsNothing);
    });

    testWidgets('signed in but sync failed: empty state with a retry', (
      tester,
    ) async {
      final rig = await pumpHome(
        tester,
        signedIn: true,
        sync: const CloudSyncStatus(
          phase: CloudSyncPhase.failed,
          lastErrorCode: 'network_unavailable',
        ),
      );
      expect(find.text('You’re offline'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-add-music')), findsOneWidget);
      expect(rig.cloud.syncRequests, 0);
    });
  });

  group('Home with music', () {
    testWidgets('library comes first, with Search, Add music and Account '
        'in reach', (tester) async {
      await pumpHome(tester, tracks: tracks);

      final library = find.byKey(const ValueKey('home-library-hero'));
      final wave = find.byKey(const ValueKey('wave-card'));
      expect(library, findsOneWidget);
      expect(find.text('My library'), findsOneWidget);
      expect(find.text('2 tracks'), findsOneWidget);
      expect(
        tester.getTopLeft(library).dy,
        lessThan(tester.getTopLeft(wave).dy),
        reason: 'Library sits above Wave without scrolling',
      );
      expect(tester.getBottomLeft(library).dy, lessThan(300));

      expect(find.byTooltip('Search'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-account-button')), findsOne);
      expect(
        find.byKey(const ValueKey('home-add-music-button')),
        findsOneWidget,
      );
      expect(find.text('Add music'), findsOneWidget);
    });

    testWidgets('Mood Map is no longer a separate Home destination', (
      tester,
    ) async {
      await pumpHome(tester, tracks: tracks);
      expect(find.text('Explore by Mood'), findsNothing);
      expect(find.text('Move through your library by feeling'), findsNothing);
      expect(find.text('MOOD MAP'), findsNothing);
      // It is reached from Wave instead.
      expect(find.text('Choose a mood'), findsOneWidget);
    });

    testWidgets('actions lead where they say', (tester) async {
      await pumpHome(tester, tracks: tracks);

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      expect(visited.last, AppRouterNames.search);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('home-add-music-button')));
      await tester.pumpAndSettle();
      expect(visited.last, AppRouterNames.importMusic);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tapAt(
        tester.getTopLeft(find.byKey(const ValueKey('home-library-hero'))) +
            const Offset(80, 24),
      );
      await tester.pumpAndSettle();
      expect(visited.last, AppRouterNames.library);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('wave-card-choose-mood')));
      await tester.pumpAndSettle();
      expect(visited.last, AppRouterNames.moodMap);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('home-account-button')));
      await tester.pumpAndSettle();
      expect(visited.last, AppRouterNames.account);
    });

    testWidgets('Start Wave begins listening in one tap', (tester) async {
      final rig = await pumpHome(tester, tracks: tracks);
      await tester.tap(find.byKey(const ValueKey('wave-card-start')));
      await tester.pump();
      await tester.pump();
      expect(rig.player.events.single, isA<PlayerMoodWaveStarted>());
    });

    testWidgets('music that is not analyzed yet can be played while Wave '
        'gets ready', (tester) async {
      final rig = await pumpHome(
        tester,
        tracks: tracks,
        analyzed: false,
        signedIn: true,
      );
      expect(find.text('Wave is getting ready'), findsOneWidget);
      expect(find.textContaining('You can already play'), findsOneWidget);
      expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
      expect(find.byKey(const ValueKey('home-library-hero')), findsOne);
      expect(rig.player.events, isEmpty);
    });

    testWidgets('signed out and not analyzed: Wave says it needs the cloud', (
      tester,
    ) async {
      await pumpHome(tester, tracks: tracks, analyzed: false);
      expect(find.text('Wave needs OwlSonic Cloud'), findsOneWidget);
      expect(find.text('Wave is getting ready'), findsNothing);
    });

    testWidgets('signed out: says the music is on this device only', (
      tester,
    ) async {
      await pumpHome(tester, tracks: tracks);
      expect(find.text('On this device only · Sign in'), findsOneWidget);
      expect(find.text('Your music is up to date'), findsNothing);
    });

    testWidgets('signed in: says the library is up to date', (tester) async {
      await pumpHome(tester, tracks: tracks, signedIn: true);
      expect(find.text('Your music is up to date'), findsOneWidget);
      expect(find.text('On this device only · Sign in'), findsNothing);
    });

    testWidgets('signed in and uploading: shows the real count', (
      tester,
    ) async {
      await pumpHome(tester, tracks: tracks, signedIn: true, pending: 3);
      expect(find.text('Uploading 3 tracks…'), findsOneWidget);
      expect(find.text('Your music is up to date'), findsNothing);
    });
  });
}
