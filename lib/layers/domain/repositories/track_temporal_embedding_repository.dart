import '../entities/track_embedding.dart';
import '../entities/track_temporal_embedding.dart';

abstract interface class TrackTemporalEmbeddingRepository {
  Future<bool> save(TrackTemporalEmbedding embedding);

  Future<TrackTemporalEmbedding?> get({
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
    required int audioRevision,
  });

  Future<List<TrackTemporalEmbedding>> getBySpace({
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  });
}
