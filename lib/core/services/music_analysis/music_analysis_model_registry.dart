import '../../../layers/domain/entities/music_analysis.dart';
import '../../../layers/domain/repositories/music_analysis_client.dart';

class MusicAnalysisModelRegistry {
  MusicAnalysisModelRegistry(this._client);

  final MusicAnalysisClient _client;
  Future<MusicAnalysisModels>? _cached;

  Future<MusicAnalysisModels> getModels({bool refresh = false}) {
    if (refresh) _cached = null;
    return _cached ??= _client.getModels().catchError((Object error) {
      _cached = null;
      throw error;
    });
  }

  Future<MusicAnalysisModel> require(
    MusicAnalysisRepresentation representation,
  ) async => (await getModels()).require(representation);
}
