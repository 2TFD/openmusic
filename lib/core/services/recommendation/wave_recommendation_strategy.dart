import '../../../layers/domain/entities/wave_session.dart';

abstract interface class WaveRecommendationStrategy {
  WaveSourceType get sourceType;

  Future<WaveRecommendationBatch> generateWave({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  });
}
