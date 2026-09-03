import '../entities/music_analysis.dart';

enum MusicAnalysisDisposition { cached, analyzed }

abstract interface class MusicAnalysisRepository {
  Future<Set<MusicAnalysisRepresentation>> missingRepresentations({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  });

  Future<MusicAnalysisDisposition> analyzeTrack({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  });
}
