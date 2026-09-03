import 'package:openmusic/core/services/recommendation/recommendation_engine.dart';
import 'package:openmusic/layers/domain/entities/recommendation.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/queue_music_analysis_use_case.dart';

abstract interface class GenerateWave {
  Future<List<Track>> execute(WaveConfig config);
}

class GenerateWaveUseCase implements GenerateWave {
  final RecommendationEngine _engine;
  final TrackRepository _tracks;
  final QueueMusicAnalysisUseCase _queueAnalysis;

  GenerateWaveUseCase({
    required RecommendationEngine engine,
    required TrackRepository tracks,
    required QueueMusicAnalysisUseCase queueAnalysis,
  }) : _engine = engine,
       _tracks = tracks,
       _queueAnalysis = queueAnalysis;

  @override
  Future<List<Track>> execute(WaveConfig config) async {
    return (await executeResult(config)).tracks;
  }

  Future<RecommendationResult> executeResult(WaveConfig config) async {
    final result = await _engine.recommend(config);
    if (result.missingSeedTrackIds.isNotEmpty) {
      final tracks = await _tracks.getTracksByIds(result.missingSeedTrackIds);
      for (final track in tracks) {
        await _queueAnalysis(track);
      }
    }
    return result;
  }
}
