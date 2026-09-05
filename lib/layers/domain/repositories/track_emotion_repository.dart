import '../entities/track_emotion_analysis.dart';

abstract interface class TrackEmotionRepository {
  Future<void> saveGlobal(TrackEmotionAnalysis analysis);
  Future<void> saveTemporal(TrackEmotionTemporalAnalysis analysis);

  Future<TrackEmotionAnalysis?> getGlobal({
    required String trackId,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String contentRevision,
    required int audioRevision,
  });

  Future<TrackEmotionTemporalAnalysis?> getTemporal({
    required String trackId,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String contentRevision,
    required int audioRevision,
  });

  Future<List<TrackEmotionAnalysis>> getGlobalsByPipeline({
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
  });

  Stream<void> watchChanges();
}
