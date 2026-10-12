import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/download_task_repository.dart';
import 'package:owlsonic/layers/domain/usecases/retry_track_download_use_case.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';

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
  testWidgets('compact desktop table keeps columns and sorts duration', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final downloads = DownloadStatusCubit(
      tasks: const Stream.empty(),
      retryDownload: RetryTrackDownloadUseCase(_UnusedDownloadRepository()),
    );
    addTearDown(downloads.close);
    final player = _RecordingPlayerBloc();
    Track track(String id, String title, int minutes) => Track(
      id: id,
      title: title,
      artists: const [Artist(id: 'a', name: 'Artist')],
      duration: Duration(minutes: minutes),
      source: const Source(
        type: SourceType.localFile,
        originalUrl: '/song.mp3',
      ),
      filePath: '/song.mp3',
      addedAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => MaterialApp(
            theme: AppTheme.dark,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: MultiBlocProvider(
              providers: [
                BlocProvider<DownloadStatusCubit>.value(value: downloads),
                BlocProvider<PlayerBloc>.value(value: player),
              ],
              child: Scaffold(
                body: DesktopLibraryTrackTable(
                  tracks: [track('a', 'Alpha', 5), track('b', 'Beta', 1)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Artist'), findsWidgets);
    expect(
      tester.getTopLeft(find.text('Alpha')).dy,
      lessThan(tester.getTopLeft(find.text('Beta')).dy),
    );
    await tester.tap(find.text('DURATION'));
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Beta')).dy,
      lessThan(tester.getTopLeft(find.text('Alpha')).dy),
    );

    // A click plays the row inside the whole library queue.
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    final played = player.events.whereType<PlayerQueueSet>().toList();
    expect(played, hasLength(1));
    expect(played.single.startTrack?.id, 'a');
    expect(played.single.tracks, hasLength(2));
    expect(find.byKey(const ValueKey('track-selection-bar')), findsNothing);
    expect(find.byType(Checkbox), findsNothing, reason: 'no selection mode');

    // Cmd+click starts selection mode; then a click toggles, not plays.
    player.events.clear();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.tap(find.text('Beta'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    expect(player.events.whereType<PlayerQueueSet>(), isEmpty);

    await tester.tap(find.byTooltip('Play selected'));
    await tester.pumpAndSettle();
    final queued = player.events.whereType<PlayerQueueSet>().single;
    expect(queued.tracks.map((t) => t.id), ['b', 'a'], reason: 'list order');

    // Esc leaves selection mode; clicks play again.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('track-selection-bar')), findsNothing);

    // Cmd+A selects everything.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}

class _RecordingPlayerBloc extends Fake implements PlayerBloc {
  final events = <Object?>[];

  @override
  Stream<PlayerState> get stream => const Stream.empty();

  @override
  void add(PlayerEvent event) => events.add(event);

  @override
  Future<void> close() async {}
}

class _UnusedDownloadRepository extends Fake
    implements DownloadTaskRepository {}
