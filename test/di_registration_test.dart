import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/mood_map/bloc/mood_map/mood_map_cubit.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_emotion_repository.dart';

void main() {
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  late Directory scratch;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // The lazily opened database asks path_provider for a folder whenever the
    // first query happens to run, possibly after the test body has finished.
    // Answering it keeps the result independent of that timing.
    scratch = Directory.systemTemp.createTempSync('owlsonic_di_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (_) async => scratch.path);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
    try {
      scratch.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('Music Analysis graph resolves from GetIt', () async {
    await getIt.reset();
    addTearDown(getIt.reset);

    await configureDependencies(appDir: '/tmp/owlsonic-di-test');

    expect(getIt<TrackEmotionRepository>(), isNotNull);
    expect(getIt<MoodMapRepository>(), isNotNull);
    final moodMap = getIt<MoodMapCubit>();
    expect(moodMap, isA<MoodMapCubit>());
    await moodMap.close();
    final status = getIt<MusicAnalysisStatusCubit>();
    expect(status, isA<MusicAnalysisStatusCubit>());
    await status.close();
  });
}
