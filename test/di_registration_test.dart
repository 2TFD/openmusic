import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_backfill_service.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_worker.dart';
import 'package:openmusic/layers/presentation/blocs/music_analysis_status/music_analysis_status_cubit.dart';

void main() {
  test('Music Analysis graph resolves from GetIt', () async {
    await getIt.reset();
    addTearDown(getIt.reset);

    await configureDependencies(appDir: '/tmp/openmusic-di-test');

    expect(getIt<MusicAnalysisBackfill>(), isA<MusicAnalysisBackfillService>());
    expect(getIt<MusicAnalysisWorker>(), isA<MusicAnalysisWorker>());
    final status = getIt<MusicAnalysisStatusCubit>();
    expect(status, isA<MusicAnalysisStatusCubit>());
    await status.close();
  });
}
