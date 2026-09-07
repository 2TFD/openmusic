import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/mood_map.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:openmusic/layers/domain/entities/wave_session.dart';
import 'package:openmusic/layers/domain/repositories/mood_map_repository.dart';
import 'package:openmusic/layers/presentation/blocs/mood_map/mood_map_cubit.dart';
import 'package:openmusic/layers/presentation/mood_map/mood_map_view_policy.dart';
import 'package:openmusic/layers/presentation/screens/mood_map_page.dart';

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

  testWidgets('embedded Mood Map keeps zoom, target selection and track view', (
    tester,
  ) async {
    final track = Track(
      id: 'map-track',
      title: 'Map Track',
      artists: const [Artist(id: 'artist', name: 'Map Artist')],
      duration: const Duration(minutes: 3),
      source: const Source(
        type: SourceType.localFile,
        originalUrl: '/map-track.mp3',
      ),
      filePath: '/map-track.mp3',
      addedAt: DateTime.utc(2026),
    );
    final entry = MoodMapTrack(
      track: track,
      modelAnalysis: TrackEmotionAnalysis(
        id: 'emotion',
        trackId: track.id,
        representation: 'audio.emotion.global',
        modelId: 'model',
        modelVersion: '1',
        preprocessingVersion: '1',
        contentRevision: 'audio:0',
        audioRevision: 0,
        valence: 0,
        arousal: 0,
        moodDistribution: MoodDistribution(const {'calm': 0.8}),
        analyzedAt: DateTime.utc(2026),
      ),
    );
    final cubit = MoodMapCubit(repository: const _EmptyMoodMapRepository());
    addTearDown(cubit.close);
    MoodPoint? selectedTarget;

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
            home: BlocProvider.value(
              value: cubit,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 360,
                    child: MoodMapPanel(
                      state: MoodMapState(
                        status: MoodMapStatus.ready,
                        tracks: [entry],
                        selectedTrackId: track.id,
                      ),
                      onTargetChanged: (target) => selectedTarget = target,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.maxScale, MoodMapViewPolicy.maxScale);
    expect(
      find.byKey(const ValueKey('mood-map-track-map-track')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('mood-map-track-map-track')));
    await tester.pump();
    expect(find.text('Map Track'), findsNothing);
    expect(selectedTarget, isNotNull);

    selectedTarget = null;
    final size = tester.getSize(find.byType(InteractiveViewer));
    final transform = Matrix4.identity()
      ..setEntry(0, 0, 4)
      ..setEntry(1, 1, 4)
      ..setEntry(0, 3, -size.width * 1.5)
      ..setEntry(1, 3, -size.height * 1.5);
    viewer.transformationController!.value = transform;
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mood-map-track-map-track')));
    await tester.pumpAndSettle();
    expect(find.text('Map Track'), findsOneWidget);
    expect(find.text('Map Artist'), findsOneWidget);

    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();
    await tester.tapAt(
      tester.getTopLeft(find.byType(InteractiveViewer)) + const Offset(20, 20),
    );
    await tester.pump();
    expect(selectedTarget, isNotNull);
  });
}

class _EmptyMoodMapRepository implements MoodMapRepository {
  const _EmptyMoodMapRepository();

  @override
  Future<List<MoodMapTrack>> loadTracks() async => const [];

  @override
  Future<void> resetPersonalPosition(String trackId) async {}

  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {}

  @override
  Stream<void> watchChanges() => const Stream.empty();
}
