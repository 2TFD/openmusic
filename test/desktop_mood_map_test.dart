import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/ui/mood_map_page.dart';

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

  testWidgets(
    'desktop Mood Map uses a large canvas and selects track details',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final track = Track(
        id: 'desktop-track',
        title: 'Desktop Song',
        artists: const [Artist(id: 'a', name: 'Owl Artist')],
        duration: const Duration(minutes: 3),
        source: const Source(
          type: SourceType.localFile,
          originalUrl: '/song.mp3',
        ),
        filePath: '/song.mp3',
        addedAt: DateTime.utc(2026),
      );
      final entry = MoodMapTrack(
        track: track,
        modelAnalysis: TrackEmotionAnalysis(
          id: 'e',
          trackId: track.id,
          representation: 'audio.emotion.global',
          modelId: 'model',
          modelVersion: '1',
          preprocessingVersion: '1',
          contentRevision: 'audio:0',
          audioRevision: 0,
          valence: 0,
          arousal: 0,
          moodDistribution: MoodDistribution(const {'calm': .8}),
          analyzedAt: DateTime.utc(2026),
        ),
      );
      final cubit = MoodMapCubit(
        analytics: const NoopAnalyticsTracker(),
        repository: _OneTrackRepository(entry),
      );
      addTearDown(cubit.close);
      await cubit.initialize();

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
                child: const MoodMapPage(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(InteractiveViewer)).width,
        greaterThan(500),
      );
      await tester.tap(
        find.byKey(const ValueKey('mood-map-track-desktop-track')),
      );
      await tester.pump();
      expect(find.text('Desktop Song'), findsOneWidget);
      expect(find.text('Owl Artist'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );
}

class _OneTrackRepository implements MoodMapRepository {
  const _OneTrackRepository(this.entry);
  final MoodMapTrack entry;

  @override
  Future<List<MoodMapTrack>> loadTracks() async => [entry];
  @override
  Stream<void> watchChanges() => const Stream.empty();
  @override
  Future<void> resetPersonalPosition(String trackId) async {}
  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {}
}
