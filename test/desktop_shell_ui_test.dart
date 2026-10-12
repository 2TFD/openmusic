import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/app_router/app_shell.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/import_candidate.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_player_bar.dart';
import 'package:owlsonic/layers/presentation/features/desktop_shell/ui/desktop_shell.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/home/ui/desktop_home.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_workspace/import_workspace_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/wave/bloc/wave_readiness_cubit.dart';
import 'package:owlsonic/layers/presentation/features/import_music/ui/desktop/desktop_import_workspace.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/add_track/add_track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';
import 'package:owlsonic/core/di/di.dart';

/// The five window sizes the desktop layout is reviewed at.
const _sizes = [
  Size(800, 700),
  Size(1000, 800),
  Size(1280, 800),
  Size(1440, 900),
  Size(1920, 1080),
];

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

  tearDown(() async => getIt.reset());

  group('platform selects the shell regardless of width', () {
    _test('desktop platforms always get the desktop shell', (tester) async {
      await getIt.reset();
      getIt.registerFactory<ImportWorkspaceCubit>(() => _FakeImportCubit());
      for (final size in [const Size(600, 700), const Size(1600, 900)]) {
        await _pumpShell(tester, size);
        expect(find.byType(DesktopShell), findsOneWidget, reason: '$size');
        expect(find.byType(DesktopPlayerBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }, variant: TargetPlatformVariant.desktop());

    _test('mobile platforms never get the desktop shell, even when wide', (
      tester,
    ) async {
      await _pumpShell(tester, const Size(1600, 900));
      expect(find.byType(DesktopShell), findsNothing);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.mobile());
  });

  group('sidebar', () {
    _test('expanded sidebar shows a persistent library section', (
      tester,
    ) async {
      await getIt.reset();
      getIt.registerFactory<ImportWorkspaceCubit>(() => _FakeImportCubit());
      await _pumpShell(
        tester,
        const Size(1440, 900),
        playlists: [_playlist('p1', 'Night drive'), _playlist('p2', 'Focus')],
        trackCount: 128,
      );

      expect(find.text('YOUR LIBRARY'), findsOneWidget);
      expect(find.text('New playlist'), findsOneWidget);
      expect(find.text('All playlists'), findsOneWidget);
      expect(find.text('Night drive'), findsOneWidget);
      expect(find.text('Focus'), findsOneWidget);
      expect(find.text('128'), findsOneWidget); // library count
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('sidebar hides and returns from the player bar and Cmd+B', (
      tester,
    ) async {
      await getIt.reset();
      getIt.registerFactory<ImportWorkspaceCubit>(() => _FakeImportCubit());
      await _pumpShell(tester, const Size(1440, 900));
      expect(find.text('YOUR LIBRARY'), findsOneWidget);

      await tester.tap(find.byTooltip('Show or hide sidebar'));
      await tester.pumpAndSettle();
      expect(find.text('YOUR LIBRARY'), findsNothing);

      await tester.tap(find.byTooltip('Show or hide sidebar'));
      await tester.pumpAndSettle();
      expect(find.text('YOUR LIBRARY'), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
      expect(find.text('YOUR LIBRARY'), findsNothing);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('compact desktop collapses to an icon rail', (tester) async {
      await getIt.reset();
      getIt.registerFactory<ImportWorkspaceCubit>(() => _FakeImportCubit());
      await _pumpShell(
        tester,
        const Size(800, 700),
        playlists: [_playlist('p1', 'Night drive')],
      );

      expect(find.text('YOUR LIBRARY'), findsNothing);
      expect(find.text('Night drive'), findsNothing);
      // Main navigation stays reachable through the rail's tooltips/icons.
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('context panel docks only on wide windows with a track', (
      tester,
    ) async {
      await getIt.reset();
      getIt.registerFactory<ImportWorkspaceCubit>(() => _FakeImportCubit());
      final state = PlayerState(
        currentTrack: _track('t1', 'Current song'),
        queue: [_track('t1', 'Current song'), _track('t2', 'Next song')],
      );

      await _pumpShell(tester, const Size(1920, 1080), player: state);
      expect(find.text('NOW PLAYING'), findsOneWidget);
      expect(find.text('Next song'), findsOneWidget);

      await _pumpShell(tester, const Size(1100, 800), player: state);
      expect(find.text('NOW PLAYING'), findsNothing);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  });

  group('desktop home', () {
    _test('empty library shows a deliberate onboarding state', (tester) async {
      for (final size in _sizes) {
        await _pumpHome(tester, size, tracks: const []);
        expect(find.text('Your music starts here'), findsOneWidget);
        // Header button and the empty state's primary action.
        expect(find.text('Add music'), findsNWidgets(2));
        expect(
          find.text('Drop music files anywhere in this window'),
          findsOneWidget,
        );
        expect(
          find.text('Add some music and Wave will help you rediscover it.'),
          findsOne,
        );
        expect(find.text('Explore by Mood'), findsNothing);
        expect(find.text('Recently added'), findsNothing);
        expect(tester.takeException(), isNull, reason: '$size');
      }
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('populated library shows only shelves that have content', (
      tester,
    ) async {
      final tracks = [
        for (var i = 0; i < 12; i++)
          _track('t$i', 'Song $i', addedAt: DateTime(2026, 1, 1 + i)),
      ];
      for (final size in _sizes) {
        await _pumpHome(tester, size, tracks: tracks);
        expect(find.text('RECENTLY ADDED'), findsOneWidget);
        expect(find.text('Song 11'), findsOneWidget, reason: 'newest first');
        // No playlists / history yet: no empty shelves.
        expect(find.text('YOUR PLAYLISTS'), findsNothing);
        expect(find.text('RECENTLY PLAYED'), findsNothing);
        expect(tester.takeException(), isNull, reason: '$size');
      }
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('wide windows show more cards per shelf', (tester) async {
      final tracks = [
        for (var i = 0; i < 12; i++)
          _track('t$i', 'Song $i', addedAt: DateTime(2026, 1, 1 + i)),
      ];
      await _pumpHome(tester, const Size(1920, 1080), tracks: tracks);
      final wide = find.textContaining('Song ').evaluate().length;
      await _pumpHome(tester, const Size(800, 700), tracks: tracks);
      final narrow = find.textContaining('Song ').evaluate().length;
      expect(wide, greaterThan(narrow));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('playlists shelf appears with a new-playlist tile', (tester) async {
      await _pumpHome(
        tester,
        const Size(1440, 900),
        tracks: [_track('t1', 'Song')],
        playlists: [_playlist('p1', 'Night drive')],
      );
      expect(find.text('YOUR PLAYLISTS'), findsOneWidget);
      expect(find.text('Night drive'), findsOneWidget);
      expect(find.text('New Playlist'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('import workspace', () {
    ImportCandidate item(
      String name,
      ImportItemStatus status, {
      Failure? failure,
      String? duplicateOf,
    }) => ImportCandidate(
      path: '/music/$name.mp3',
      fileName: '$name.mp3',
      status: status,
      preview: TrackPreview(
        id: name,
        title: name,
        artist: 'Artist',
        source: SourceType.localFile,
        originalUrl: '/music/$name.mp3',
        urlFile: '/music/$name.mp3',
      ),
      failure: failure,
      duplicateOfTitle: duplicateOf,
      duplicateOfTrackId: duplicateOf == null ? null : 'existing',
    );

    final states = <String, ImportWorkspaceState>{
      'idle': const ImportWorkspaceState(),
      'scanning': ImportWorkspaceState(
        phase: ImportPhase.scanning,
        scanTotal: 3,
        items: [
          item('One', ImportItemStatus.ready),
          const ImportCandidate.scanning(
            path: '/music/Two.mp3',
            name: 'Two.mp3',
          ),
        ],
      ),
      'review': ImportWorkspaceState(
        phase: ImportPhase.review,
        selected: const {'/music/Alpha.mp3'},
        items: [
          item('Alpha', ImportItemStatus.ready),
          item('Dup', ImportItemStatus.duplicate, duplicateOf: 'Dup song'),
          const ImportCandidate(
            path: '/music/Bad.mp3',
            fileName: 'Bad.mp3',
            status: ImportItemStatus.invalid,
            failure: UnsupportedMediaFailure('x'),
          ),
        ],
      ),
      'importing': ImportWorkspaceState(
        phase: ImportPhase.importing,
        importTotal: 3,
        importDone: 1,
        items: [
          item('A', ImportItemStatus.imported),
          item('B', ImportItemStatus.importing),
          item('C', ImportItemStatus.queued),
        ],
      ),
      'done': ImportWorkspaceState(
        phase: ImportPhase.done,
        items: [
          item('A', ImportItemStatus.imported),
          item('B', ImportItemStatus.duplicate, duplicateOf: 'B song'),
          item('C', ImportItemStatus.failed, failure: const StorageFailure()),
        ],
      ),
    };

    for (final entry in states.entries) {
      _test('${entry.key} renders at every desktop size', (tester) async {
        for (final size in _sizes) {
          await _pumpImport(tester, size, entry.value);
          expect(tester.takeException(), isNull, reason: '${entry.key} $size');
        }
      }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
    }

    _test('review shows explicit per-item states and a count', (tester) async {
      await _pumpImport(tester, const Size(1440, 900), states['review']!);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('In library'), findsOneWidget);
      expect(find.text('Invalid'), findsOneWidget);
      expect(find.text('Already in your library: Dup song'), findsOneWidget);
      expect(
        find.text('Unsupported or unreadable audio format'),
        findsOneWidget,
      );
      expect(find.text('Add 1 track'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('progress and partial failure stay visible in the workspace', (
      tester,
    ) async {
      await _pumpImport(tester, const Size(1440, 900), states['importing']!);
      expect(find.text('Adding 2 of 3'), findsOneWidget);
      expect(find.text('Waiting'), findsOneWidget);

      await _pumpImport(tester, const Size(1440, 900), states['done']!);
      expect(find.text('1 added'), findsOneWidget);
      expect(find.text('1 already in library'), findsOneWidget);
      expect(find.text('1 failed'), findsOneWidget);
      expect(find.text('Retry failed'), findsOneWidget);
      expect(find.text('Storage operation failed'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('link failure names the real problem, not "Failed to load"', (
      tester,
    ) async {
      await _pumpImport(
        tester,
        const Size(1440, 900),
        const ImportWorkspaceState(),
        addTrack: AddTrackError(UiError(localeKey: 'errors.unsupportedLink')),
        linkTab: true,
      );
      expect(find.text('Unsupported link'), findsOneWidget);
      expect(find.text('Failed to load'), findsNothing);
      expect(find.text("Couldn't add this link"), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

    _test('link preview is inline, bounded, and offers add/cancel', (
      tester,
    ) async {
      final resolved = ResolvedTrackInput.single(
        const TrackPreview(
          id: 'yt1',
          title: 'A video track',
          artist: 'Some Artist',
          source: SourceType.youtube,
          originalUrl: 'https://youtu.be/x',
          urlFile: '',
          duration: Duration(minutes: 3, seconds: 5),
        ),
      );
      await _pumpImport(
        tester,
        const Size(1440, 900),
        const ImportWorkspaceState(),
        addTrack: AddTrackPreviewLoaded(resolved: resolved),
        linkTab: true,
      );
      expect(find.text('A video track'), findsOneWidget);
      expect(find.text('Some Artist'), findsOneWidget);
      expect(find.textContaining('3:05'), findsOneWidget);
      expect(find.text('Add to Library'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });
}

// ── helpers ────────────────────────────────────────────────────────────────

/// google_fonts downloads fonts over HTTP, which always fails under
/// flutter_test and surfaces as an unhandled async error. The text still lays
/// out with the fallback font, so those specific errors are ignored; anything
/// else still fails the test.
void _test(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  TestVariant<Object?> variant = const DefaultTestVariant(),
}) {
  testWidgets(description, (tester) async {
    final done = Completer<void>();
    runZonedGuarded(
      () async {
        try {
          await body(tester);
          if (!done.isCompleted) done.complete();
        } catch (error, stackTrace) {
          if (!done.isCompleted) done.completeError(error, stackTrace);
        }
      },
      (error, stackTrace) {
        if ('$error'.contains('Failed to load font')) return;
        if (!done.isCompleted) done.completeError(error, stackTrace);
      },
    );
    await done.future;
  }, variant: variant);
}

Track _track(String id, String title, {DateTime? addedAt}) => Track(
  id: id,
  title: title,
  artists: const [Artist(id: 'a', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(type: SourceType.localFile, originalUrl: '/x.mp3'),
  addedAt: addedAt ?? DateTime(2026, 1, 1),
  filePath: '/x.mp3',
);

PlaylistSummary _playlist(String id, String name) => PlaylistSummary(
  id: id,
  name: name,
  createdAt: DateTime(2026, 1, 1),
  trackCount: 4,
  revision: 0,
);

/// Progress indicators animate forever, so `pumpAndSettle` would time out.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Reads translations straight from disk so they are available after a single
/// microtask instead of depending on asset-bundle I/O timing.
class _DiskAssetLoader extends AssetLoader {
  const _DiskAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

Widget _app(Widget Function(BuildContext) home, {GoRouter? router}) =>
    EasyLocalization(
      assetLoader: const _DiskAssetLoader(),
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: Builder(
        builder: (context) => router != null
            ? MaterialApp.router(
                theme: AppTheme.dark,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                routerConfig: router,
              )
            : MaterialApp(
                theme: AppTheme.dark,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: home(context),
              ),
      ),
    );

Future<void> _pumpShell(
  WidgetTester tester,
  Size size, {
  PlayerState? player,
  List<PlaylistSummary> playlists = const [],
  int trackCount = 0,
}) async {
  await _setSize(tester, size);
  final router = GoRouter(
    initialLocation: '/${AppRouterNames.home}',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/${AppRouterNames.home}',
            name: AppRouterNames.home,
            builder: (context, state) => const Text('page'),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<PlayerBloc>.value(
          value: _FakePlayerBloc(player ?? PlayerState()),
        ),
        BlocProvider<PlaylistBloc>.value(
          value: _FakePlaylistBloc(PlaylistLoaded(playlists)),
        ),
        BlocProvider<TrackBloc>.value(
          value: _FakeTrackBloc(
            TrackLoaded([
              for (var i = 0; i < trackCount; i++) _track('$i', 'T'),
            ]),
          ),
        ),
        BlocProvider<MusicAnalysisStatusCubit>.value(
          value: _FakeAnalysisCubit(),
        ),
        BlocProvider<CloudSessionCubit>.value(value: _FakeSessionCubit()),
      ],
      child: _app((_) => const SizedBox(), router: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpHome(
  WidgetTester tester,
  Size size, {
  required List<Track> tracks,
  List<PlaylistSummary> playlists = const [],
}) async {
  await _setSize(tester, size);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => DesktopHome(tracks: tracks),
      ),
    ],
  );
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<PlayerBloc>.value(value: _FakePlayerBloc(PlayerState())),
        BlocProvider<PlaylistBloc>.value(
          value: _FakePlaylistBloc(PlaylistLoaded(playlists)),
        ),
        BlocProvider<HistoryBloc>.value(
          value: _FakeHistoryBloc(const HistoryLoaded(tracks: [])),
        ),
        BlocProvider<WaveReadinessCubit>.value(value: _FakeReadinessCubit()),
        BlocProvider<CloudStatusCubit>.value(value: _FakeCloudStatusCubit()),
      ],
      child: _app((_) => const SizedBox(), router: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpImport(
  WidgetTester tester,
  Size size,
  ImportWorkspaceState state, {
  AddTrackState addTrack = const AddTrackInitial(),
  bool linkTab = false,
}) async {
  await _setSize(tester, size);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ImportWorkspaceCubit>.value(
          value: _FakeImportCubit(state),
        ),
        BlocProvider<AddTrackBloc>.value(value: _FakeAddTrackBloc(addTrack)),
      ],
      child: _app((_) => const DesktopImportWorkspace()),
    ),
  );
  await _settle(tester);
  if (linkTab) {
    await tester.tap(find.text('Link'));
    await _settle(tester);
  }
}

// Bloc fakes: the widgets under test only read `state` and `stream`.

class _FakePlayerBloc extends Fake implements PlayerBloc {
  _FakePlayerBloc(this._state);
  final PlayerState _state;
  @override
  PlayerState get state => _state;
  @override
  Stream<PlayerState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakePlaylistBloc extends Fake implements PlaylistBloc {
  _FakePlaylistBloc(this._state);
  final PlaylistState _state;
  @override
  PlaylistState get state => _state;
  @override
  Stream<PlaylistState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeTrackBloc extends Fake implements TrackBloc {
  _FakeTrackBloc(this._state);
  final TrackState _state;
  @override
  TrackState get state => _state;
  @override
  Stream<TrackState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeHistoryBloc extends Fake implements HistoryBloc {
  _FakeHistoryBloc(this._state);
  final HistoryState _state;
  @override
  HistoryState get state => _state;
  @override
  Stream<HistoryState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeCloudStatusCubit extends Fake implements CloudStatusCubit {
  @override
  CloudStatusState get state =>
      const CloudStatusState(kind: CloudStatusKind.deviceOnly);
  @override
  Stream<CloudStatusState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeReadinessCubit extends Fake implements WaveReadinessCubit {
  @override
  WaveReadinessState get state => const WaveReadinessState(loaded: true);
  @override
  Stream<WaveReadinessState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeSessionCubit extends Fake implements CloudSessionCubit {
  @override
  CloudSessionState get state =>
      const CloudSessionState(configured: true, signedIn: false);
  @override
  Stream<CloudSessionState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeAnalysisCubit extends Fake implements MusicAnalysisStatusCubit {
  @override
  MusicAnalysisStatusState get state => const MusicAnalysisStatusState();
  @override
  Stream<MusicAnalysisStatusState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeImportCubit extends Fake implements ImportWorkspaceCubit {
  _FakeImportCubit([this._state = const ImportWorkspaceState()]);
  final ImportWorkspaceState _state;
  @override
  ImportWorkspaceState get state => _state;
  @override
  Stream<ImportWorkspaceState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _FakeAddTrackBloc extends Fake implements AddTrackBloc {
  _FakeAddTrackBloc(this._state);
  final AddTrackState _state;
  @override
  AddTrackState get state => _state;
  @override
  Stream<AddTrackState> get stream => const Stream.empty();
  @override
  void add(AddTrackEvent event) {}
  @override
  Future<void> close() async {}
}
