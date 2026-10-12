import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';
import 'package:owlsonic/layers/presentation/features/wave/ui/wave_screen.dart';

import 'support/ux_harness.dart';

void main() {
  useTestLocalization();

  Future<RecordingPlayerBloc> pumpWave(
    WidgetTester tester, {
    required List<Track> tracks,
    required bool analyzed,
    List<String>? visited,
  }) async {
    final cloud = await CloudStatusRig.create(signedIn: true);
    addTearDown(cloud.dispose);
    final readiness = WaveReadinessCubit(
      repository: FakeMoodRepository([if (analyzed) moodEntry('a')]),
    );
    addTearDown(readiness.close);
    await readiness.initialize();
    final player = RecordingPlayerBloc();
    await pumpApp(
      tester,
      router: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const WaveScreen()),
          GoRoute(
            path: '/${AppRouterNames.importMusic}',
            name: AppRouterNames.importMusic,
            builder: (_, _) {
              visited?.add(AppRouterNames.importMusic);
              return Scaffold(appBar: AppBar());
            },
          ),
        ],
      ),
      providers: [
        BlocProvider<TrackBloc>.value(value: FakeTrackBloc(tracks)),
        BlocProvider<PlayerBloc>.value(value: player),
        BlocProvider<WaveReadinessCubit>.value(value: readiness),
        BlocProvider<CloudStatusCubit>.value(value: cloud.cubit),
      ],
    );
    return player;
  }

  testWidgets('with music, Wave starts in one tap and explains itself', (
    tester,
  ) async {
    final player = await pumpWave(
      tester,
      tracks: [localTrack('a', 'Song')],
      analyzed: true,
    );
    expect(find.byKey(const ValueKey('wave-how-it-works')), findsOneWidget);
    expect(find.textContaining('songs from your own library'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('wave-card-start')));
    await tester.pump();
    await tester.pump();
    expect(player.events.single, isA<PlayerMoodWaveStarted>());
  });

  testWidgets('without music, it says what Wave needs and offers Add music', (
    tester,
  ) async {
    final visited = <String>[];
    await pumpWave(tester, tracks: const [], analyzed: false, visited: visited);

    expect(find.text('Wave needs music'), findsOneWidget);
    expect(find.byKey(const ValueKey('wave-card')), findsNothing);

    await tester.tap(find.text('Add music'));
    await tester.pumpAndSettle();
    expect(visited, [AppRouterNames.importMusic]);
  });

  testWidgets('with music that is not analyzed, play is still possible '
      'elsewhere and Wave says it is getting ready', (tester) async {
    await pumpWave(tester, tracks: [localTrack('a', 'Song')], analyzed: false);
    expect(find.text('Wave is getting ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('wave-card-start')), findsNothing);
  });
}
