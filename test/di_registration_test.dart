import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_backfill_service.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_worker.dart';
import 'package:openmusic/layers/presentation/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/mood_map/mood_map_cubit.dart';
import 'package:openmusic/layers/domain/repositories/mood_map_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_emotion_repository.dart';

void main() {
  test('Music Analysis graph resolves from GetIt', () async {
    await getIt.reset();
    addTearDown(getIt.reset);

    await configureDependencies(appDir: '/tmp/openmusic-di-test');

    expect(getIt<MusicAnalysisBackfill>(), isA<MusicAnalysisBackfillService>());
    expect(getIt<MusicAnalysisWorker>(), isA<MusicAnalysisWorker>());
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
