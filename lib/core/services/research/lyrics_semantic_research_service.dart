import '../../../layers/domain/entities/music_analysis.dart';
import '../../../layers/domain/entities/track_embedding.dart';
import '../../../layers/domain/repositories/track_embedding_repository.dart';
import '../../../layers/domain/repositories/track_lyrics_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/services/vector_similarity.dart';
import '../music_analysis/music_analysis_model_registry.dart';

class LyricsSemanticResearchCoverage {
  const LyricsSemanticResearchCoverage({
    required this.analyzed,
    required this.total,
  });

  final int analyzed;
  final int total;
}

class LyricsSemanticResearchCandidate {
  const LyricsSemanticResearchCandidate({
    required this.trackId,
    required this.similarity,
  });

  final String trackId;
  final double similarity;
}

class LyricsSemanticResearchResult {
  const LyricsSemanticResearchResult({
    required this.model,
    required this.coverage,
    required this.seedAvailable,
    required this.candidates,
  });

  final MusicAnalysisModel model;
  final LyricsSemanticResearchCoverage coverage;
  final bool seedAvailable;
  final List<LyricsSemanticResearchCandidate> candidates;
}

/// Experimental lyrics-only similarity. Production ranking uses the same
/// embeddings through [RecommendationEngine], but this service remains
/// independent for inspection and evaluation.
class LyricsSemanticResearchService {
  const LyricsSemanticResearchService({
    required TrackRepository tracks,
    required TrackLyricsRepository lyrics,
    required TrackEmbeddingRepository embeddings,
    required MusicAnalysisModelRegistry registry,
  }) : _tracks = tracks,
       _lyrics = lyrics,
       _embeddings = embeddings,
       _registry = registry;

  final TrackRepository _tracks;
  final TrackLyricsRepository _lyrics;
  final TrackEmbeddingRepository _embeddings;
  final MusicAnalysisModelRegistry _registry;

  Future<LyricsSemanticResearchResult> compare({
    required String seedTrackId,
    Set<String>? candidateTrackIds,
  }) async {
    final library = await _tracks.getTracks();
    final model = await _registry.require(
      MusicAnalysisRepresentation.lyricsGlobal,
    );
    final embeddings = await _embeddings.getBySpace(
      modality: TrackEmbeddingModality.lyrics,
      modelId: model.modelId,
      modelVersion: model.modelVersion,
      preprocessingVersion: model.preprocessingVersion,
      provider: TrackEmbeddingProvider.server,
    );
    final embeddingsByTrack = {
      for (final embedding in embeddings)
        if (embedding.dimensions == model.dimension)
          embedding.trackId: embedding,
    };
    final valid = <String, TrackEmbedding>{};
    for (final track in library) {
      final lyrics = await _lyrics.getForTrack(track.id);
      final embedding = embeddingsByTrack[track.id];
      if (lyrics == null ||
          lyrics.isInstrumental ||
          lyrics.plainText.trim().isEmpty ||
          embedding?.contentRevision != lyrics.contentHash) {
        continue;
      }
      valid[track.id] = embedding!;
    }

    final seed = valid[seedTrackId];
    final coverage = LyricsSemanticResearchCoverage(
      analyzed: valid.length,
      total: library.length,
    );
    if (seed == null) {
      return LyricsSemanticResearchResult(
        model: model,
        coverage: coverage,
        seedAvailable: false,
        candidates: const [],
      );
    }

    final candidates = <LyricsSemanticResearchCandidate>[
      for (final entry in valid.entries)
        if (entry.key != seedTrackId &&
            (candidateTrackIds == null ||
                candidateTrackIds.contains(entry.key)))
          LyricsSemanticResearchCandidate(
            trackId: entry.key,
            similarity: VectorSimilarity.cosine(
              seed.vector,
              entry.value.vector,
            ),
          ),
    ]..sort((left, right) => right.similarity.compareTo(left.similarity));
    return LyricsSemanticResearchResult(
      model: model,
      coverage: coverage,
      seedAvailable: true,
      candidates: List.unmodifiable(candidates),
    );
  }
}
