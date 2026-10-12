import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/app_router/app_shell.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/ui/mood_map_page.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_account_cubit.dart';
import 'package:owlsonic/layers/presentation/features/account/ui/cloud_account_screen.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/home_screen.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/ui/widgets/wave_card.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/search/bloc/search/search_bloc.dart';
import 'package:owlsonic/layers/presentation/features/search/ui/search_screen.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';

import 'support/ux_harness.dart';

class _FakeDownloads extends Fake implements DownloadStatusCubit {
  _FakeDownloads([this.state = const {}]);

  @override
  final Map<String, DownloadTrackTask> state;
  @override
  Stream<Map<String, DownloadTrackTask>> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeSearchBloc extends Fake implements SearchBloc {
  @override
  SearchState get state => SearchInitial();
  @override
  Stream<SearchState> get stream => const Stream.empty();
  @override
  void add(SearchEvent event) {}
  @override
  Future<void> close() async {}
}

class _FakeAccountCubit extends Fake implements CloudAccountCubit {
  _FakeAccountCubit(this._state);
  final CloudAccountState _state;
  int refreshes = 0;
  @override
  CloudAccountState get state => _state;
  @override
  Stream<CloudAccountState> get stream => const Stream.empty();
  @override
  Future<void> refresh() async => refreshes++;
  @override
  ValueListenable<OfflineProgress>? get offlineProgress => null;
  @override
  Future<void> close() async {}
}

void main() {
  useTestLocalization();

  group('modal sheets are opaque', () {
    test('the sheet surface and theme leave nothing see-through', () {
      expect(AppBlur.sheetColor.a, 1.0);
      expect(AppColors.sheetSurface.a, 1.0);
      // The dimming comes from the barrier, not from the sheet.
      expect(AppColors.sheetBarrier.a, greaterThan(0.5));
      expect(AppColors.sheetBarrier.a, lessThan(1.0));
    });

    testWidgets('History sheet draws on an opaque surface above Home', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                const Text('HOME BEHIND'),
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: AppColors.sheetSurface,
                    builder: (_) => const HistorySheet(),
                  ),
                  child: const Text('open'),
                ),
              ],
            ),
          ),
        ),
        providers: [
          BlocProvider<HistoryBloc>.value(value: FakeHistoryBloc()),
          BlocProvider<PlayerBloc>.value(value: RecordingPlayerBloc()),
          BlocProvider<MusicAnalysisStatusCubit>.value(
            value: FakeAnalysisCubit(),
          ),
        ],
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final surface = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(HistorySheet),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(surface.color.a, 1.0);
      expect(find.text('History'.toUpperCase()), findsOneWidget);
      // Empty history says so inside the sheet.
      expect(find.textContaining('History is empty'), findsOneWidget);
    });

    testWidgets('Customize Wave sheet is opaque and scrolls on a small phone', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: const Size(320, 480),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WaveSettingsSheet(tracks: [], artists: []),
          ),
        ),
        providers: [
          BlocProvider<PlayerBloc>.value(value: RecordingPlayerBloc()),
        ],
      );
      final decorated = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == AppBlur.sheetColor);
      expect(decorated, isNotEmpty);
      expect(tester.takeException(), isNull);
      // Start Wave stays reachable while the settings scroll.
      expect(find.byKey(const ValueKey('apply-wave-settings')), findsOneWidget);
      await tester.dragUntilVisible(
        find.byKey(const ValueKey('wave-radius')),
        find.byKey(const ValueKey('mood-wave-settings')),
        const Offset(0, -80),
      );
      expect(find.byKey(const ValueKey('apply-wave-settings')), findsOneWidget);
    });
  });

  group('Wave customization', () {
    testWidgets('mood is chosen in the dedicated picker and returned', (
      tester,
    ) async {
      final events = <PlayerEvent>[];
      var pickerOpened = 0;
      await pumpApp(
        tester,
        home: Scaffold(
          body: WaveSettingsSheet(
            tracks: const [],
            artists: const [],
            playerState: PlayerState(),
            onEvent: events.add,
            pickMood: (context, current) async {
              pickerOpened++;
              return MoodPoint(valence: 0.8, arousal: 0.7);
            },
          ),
        ),
      );
      expect(find.text('Balanced'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('wave-choose-on-map')));
      await tester.pumpAndSettle();
      expect(pickerOpened, 1);
      expect(find.text('Upbeat and bright'), findsOneWidget);
      expect(find.text('Chosen on the mood map'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('apply-wave-settings')));
      await tester.pump();
      final started = events.single as PlayerMoodWaveStarted;
      expect(started.targetValence, 0.8);
      expect(started.targetArousal, 0.7);
    });
  });

  group('mobile shell keeps content above the mini-player', () {
    Future<void> pumpShell(WidgetTester tester, {required bool playing}) async {
      final track = localTrack('t', 'Playing song');
      await pumpApp(
        tester,
        size: const Size(390, 700),
        router: GoRouter(
          routes: [
            ShellRoute(
              builder: (_, _, child) => AppShell(child: child),
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => Scaffold(
                    body: ListView(
                      children: [
                        for (var i = 0; i < 30; i++)
                          SizedBox(height: 60, child: Text('row $i')),
                        const SizedBox(
                          key: ValueKey('last-row'),
                          height: 60,
                          child: Text('last'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        providers: [
          BlocProvider<PlayerBloc>.value(
            value: RecordingPlayerBloc(
              playing
                  ? PlayerState(
                      currentTrack: track,
                      queue: [track],
                      duration: const Duration(minutes: 3),
                    )
                  : PlayerState(),
            ),
          ),
          BlocProvider<PlaylistBloc>.value(value: FakePlaylistBloc()),
        ],
      );
    }

    testWidgets('the last item scrolls fully above the player', (tester) async {
      await pumpShell(tester, playing: true);
      await tester.dragUntilVisible(
        find.byKey(const ValueKey('last-row')),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      final last = tester.getRect(find.byKey(const ValueKey('last-row')));
      final player = tester.getRect(find.text('Playing song'));
      expect(last.bottom, lessThanOrEqualTo(player.top));
      expect(tester.takeException(), isNull);
    });

    testWidgets('without playback the screen uses the whole area', (
      tester,
    ) async {
      await pumpShell(tester, playing: false);
      expect(find.text('Playing song'), findsNothing);
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      final last = tester.getRect(find.byKey(const ValueKey('last-row')));
      expect(last.bottom, closeTo(700, 0.5));
    });

    testWidgets('the player steps aside while the keyboard is open', (
      tester,
    ) async {
      await pumpShell(tester, playing: true);
      expect(find.text('Playing song'), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(find.text('Playing song'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Library', () {
    final tracks = [
      localTrack('a', 'Alpha song'),
      localTrack('b', 'Beta song'),
      Track(
        id: 'c',
        title: 'Cloud only',
        artists: localTrack('c', '').artists,
        duration: const Duration(minutes: 2),
        source: localTrack('c', '').source,
        addedAt: DateTime(2026, 1, 1),
      ),
    ];

    Future<void> pumpLibrary(
      WidgetTester tester, {
      Map<String, DownloadTrackTask> downloads = const {},
    }) async {
      final cloud = await CloudStatusRig.create();
      addTearDown(cloud.dispose);
      await pumpApp(
        tester,
        size: const Size(390, 800),
        router: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const LibraryScreen()),
            for (final name in [
              AppRouterNames.importMusic,
              AppRouterNames.settings,
            ])
              GoRoute(
                path: '/$name',
                name: name,
                builder: (_, _) => Text('page:$name'),
              ),
          ],
        ),
        providers: [
          BlocProvider<TrackBloc>.value(value: FakeTrackBloc(tracks)),
          BlocProvider<PlayerBloc>.value(value: RecordingPlayerBloc()),
          BlocProvider<DownloadStatusCubit>.value(
            value: _FakeDownloads(downloads),
          ),
          BlocProvider<MusicAnalysisStatusCubit>.value(
            value: FakeAnalysisCubit(),
          ),
          BlocProvider<CloudStatusCubit>.value(value: cloud.cubit),
        ],
      );
    }

    testWidgets('failed downloads move to their own collapsed section', (
      tester,
    ) async {
      await pumpLibrary(
        tester,
        downloads: {
          'c': DownloadTrackTask(
            trackId: 'c',
            originalUrl: 'https://www.youtube.com/watch?v=c',
            status: DownloadStatus.failed,
            createdAt: DateTime(2026, 1, 1),
          ),
        },
      );

      expect(find.text('Cloud only'), findsNothing);
      expect(find.text('Alpha song'), findsOneWidget);
      expect(find.text('Not downloaded (1)'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('library-failed-downloads-retry')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('library-failed-downloads-toggle')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cloud only'), findsOneWidget);
    });

    testWidgets('a new track shows that it is queued, then downloading', (
      tester,
    ) async {
      DownloadTrackTask task(DownloadStatus status) => DownloadTrackTask(
        trackId: 'c',
        originalUrl: 'https://www.youtube.com/watch?v=c',
        status: status,
        createdAt: DateTime(2026, 1, 1),
      );

      await pumpLibrary(tester, downloads: {'c': task(DownloadStatus.queued)});
      expect(find.text('Cloud only'), findsOneWidget);
      expect(find.text('Queued'), findsOneWidget);

      await pumpLibrary(
        tester,
        downloads: {'c': task(DownloadStatus.downloading)},
      );
      expect(find.text('Downloading…'), findsOneWidget);
      expect(find.text('Queued'), findsNothing);
    });

    testWidgets('without failed downloads there is no section', (tester) async {
      await pumpLibrary(tester);
      expect(
        find.byKey(const ValueKey('library-failed-downloads')),
        findsNothing,
      );
    });

    testWidgets('shows the track count, sorting and an obvious Add music', (
      tester,
    ) async {
      await pumpLibrary(tester);
      expect(find.text('3 tracks'), findsOneWidget);
      expect(find.byKey(const ValueKey('library-sort-button')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('library-add-music-button')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('library-add-music-button')));
      await tester.pumpAndSettle();
      expect(find.text('page:${AppRouterNames.importMusic}'), findsOneWidget);
    });

    testWidgets('Available offline hides tracks without a local file', (
      tester,
    ) async {
      await pumpLibrary(tester);
      expect(find.text('Cloud only'), findsOneWidget);
      await tester.tap(find.text('Available offline'));
      await tester.pumpAndSettle();
      expect(find.text('Cloud only'), findsNothing);
      expect(find.text('Alpha song'), findsOneWidget);
      expect(find.text('2 of 3 tracks'), findsOneWidget);
      // Source filters only appear when sources are mixed.
      expect(find.text('YouTube'), findsNothing);
    });

    testWidgets('searching the library narrows the list', (tester) async {
      await pumpLibrary(tester);
      await tester.tap(find.byKey(const ValueKey('library-search-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('library-search-field')),
        'beta',
      );
      await tester.pumpAndSettle();
      expect(find.text('Beta song'), findsOneWidget);
      expect(find.text('Alpha song'), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('library-search-field')),
        'zzz',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('library-no-matches')), findsOneWidget);
    });

    testWidgets('sorting by title reorders the list', (tester) async {
      await pumpLibrary(tester);
      await tester.tap(find.byKey(const ValueKey('library-sort-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Title').last);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Alpha song')).dy,
        lessThan(tester.getTopLeft(find.text('Beta song')).dy),
      );
    });
  });

  group('Account', () {
    Future<_FakeAccountCubit> pumpAccount(
      WidgetTester tester,
      CloudAccountState state,
    ) async {
      final cubit = _FakeAccountCubit(state);
      await pumpApp(
        tester,
        size: const Size(390, 1600),
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => BlocProvider<CloudAccountCubit>.value(
                value: cubit,
                child: const CloudAccountScreen(),
              ),
            ),
            GoRoute(
              path: '/${AppRouterNames.settings}',
              name: AppRouterNames.settings,
              builder: (_, _) => const SizedBox(),
            ),
          ],
        ),
      );
      return cubit;
    }

    final user = CloudUser(
      id: 'u',
      email: 'owl@example.com',
      createdAt: DateTime(2026),
    );

    testWidgets('shows identity, storage and devices in separate groups', (
      tester,
    ) async {
      await pumpAccount(
        tester,
        CloudAccountState(
          status: CloudAccountStatus.signedIn,
          user: user,
          usage: const StorageUsage(
            usedBytes: 512 * 1024 * 1024,
            limitBytes: 1024 * 1024 * 1024,
            remainingBytes: 512 * 1024 * 1024,
            unlimited: false,
            overLimit: false,
          ),
          devices: [
            CloudDevice(
              id: 'd1',
              platform: 'ios',
              deviceName: 'My iPhone',
              appVersion: '1',
              createdAt: DateTime(2026),
              lastSeenAt: DateTime(2026),
              current: true,
            ),
          ],
        ),
      );
      expect(find.byKey(const ValueKey('account-identity')), findsOneWidget);
      expect(find.text('owl@example.com'), findsOneWidget);
      expect(find.text('512.0 MB of 1.0 GB used'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(find.text('My iPhone'), findsOneWidget);
      expect(find.text('This device'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.byKey(const ValueKey('account-delete')), findsOneWidget);
      // Delete sits below Sign out, apart from routine actions.
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('account-delete'))).dy,
        greaterThan(tester.getTopLeft(find.text('Sign out')).dy + 40),
      );
    });

    testWidgets('an empty device list explains itself and can retry', (
      tester,
    ) async {
      final cubit = await pumpAccount(
        tester,
        CloudAccountState(status: CloudAccountStatus.signedIn, user: user),
      );
      expect(
        find.byKey(const ValueKey('account-devices-unavailable')),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('account-devices-unavailable')),
          matching: find.text('Retry'),
        ),
      );
      expect(cubit.refreshes, 1);
    });
  });

  group('Search', () {
    testWidgets('idle search suggests artists from the real library', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: const Size(390, 800),
        home: const SearchScreen(),
        providers: [
          BlocProvider<SearchBloc>.value(value: _FakeSearchBloc()),
          BlocProvider<TrackBloc>.value(
            value: FakeTrackBloc([localTrack('a', 'One')]),
          ),
          BlocProvider<PlayerBloc>.value(value: RecordingPlayerBloc()),
        ],
      );
      expect(find.byKey(const ValueKey('search-idle')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('search-suggestion-Owl Artist')),
        findsOne,
      );
      // No oversized empty-state icon.
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.tap(find.text('SoundCloud'));
      await tester.pump();
      expect(find.byKey(const ValueKey('search-online-hint')), findsOneWidget);
      expect(find.textContaining('not your library'), findsOneWidget);
    });
  });

  group('Mood Map', () {
    late MoodMapCubit cubit;

    Future<void> pumpPicker(
      WidgetTester tester,
      List<MoodMapTrack> entries,
      ValueChanged<MoodPoint?> onResult,
    ) async {
      cubit = MoodMapCubit(
        repository: FakeMoodRepository(entries),
        analytics: const NoopAnalyticsTracker(),
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      await pumpApp(
        tester,
        size: const Size(420, 900),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => onResult(
                await Navigator.of(context).push<MoodPoint>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const MoodMapPage(pickTarget: true),
                    ),
                  ),
                ),
              ),
              child: const Text('open picker'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open picker'));
      await tester.pumpAndSettle();
    }

    Future<void> tapUpbeat(WidgetTester tester) async {
      final viewer = find.byType(InteractiveViewer);
      await tester.tapAt(tester.getTopRight(viewer) + const Offset(-40, 40));
      await tester.pump();
    }

    testWidgets('pick mode returns the chosen mood instead of playing', (
      tester,
    ) async {
      MoodPoint? result;
      var returned = false;
      await pumpPicker(tester, [moodEntry('a', valence: 0.7, arousal: 0.7)], (
        value,
      ) {
        result = value;
        returned = true;
      });
      FilledButton button() => tester.widget<FilledButton>(
        find.byKey(const ValueKey('play-this-mood')),
      );
      expect(button().onPressed, isNull);
      expect(find.text('Use this mood'), findsOneWidget);
      expect(find.text('Play this mood'), findsNothing);

      await tapUpbeat(tester);
      expect(find.text('Upbeat and bright'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('play-this-mood')));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
      expect(result!.valence, greaterThan(0.33));
      expect(result!.arousal, greaterThan(0.33));
    });

    testWidgets('the nearby count appears only when songs are nearby', (
      tester,
    ) async {
      await pumpPicker(tester, [
        moodEntry('a', valence: -0.9, arousal: -0.9),
      ], (_) {});
      await tapUpbeat(tester);
      expect(find.byKey(const ValueKey('mood-nearby-count')), findsNothing);
      // The mood is still understandable and playable without a count.
      expect(find.text('Upbeat and bright'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('play-this-mood')))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('a sparse map says so', (tester) async {
      await pumpPicker(tester, [moodEntry('a')], (_) {});
      expect(
        find.byKey(const ValueKey('mood-map-sparse-hint')),
        findsOneWidget,
      );
      expect(find.textContaining('Only 1 songs'), findsOneWidget);
    });
  });
}
