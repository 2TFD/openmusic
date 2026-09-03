import '../entities/track_embedding.dart';

abstract interface class TrackEmbeddingRepository {
  Future<void> save(TrackEmbedding embedding);

  Future<TrackEmbedding?> get({
    required String trackId,
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required TrackEmbeddingProvider provider,
    String preprocessingVersion = TrackEmbedding.legacyPreprocessingVersion,
    String? contentRevision,
  });
  Future<List<TrackEmbedding>> getBySpace({
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  });

  Future<List<TrackEmbedding>> getForTrack(String trackId);

  Future<void> deleteForTrack(String trackId);
}
