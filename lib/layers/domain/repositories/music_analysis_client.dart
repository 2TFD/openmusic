import '../entities/music_analysis.dart';

abstract interface class MusicAnalysisClient {
  String get baseUrl;

  Future<MusicAnalysisModels> getModels();

  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  });
}
