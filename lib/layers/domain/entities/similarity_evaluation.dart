enum ResearchSimilarityMethod {
  audioGlobal('audio_global_cosine_v1'),
  lyricsSemantic('lyrics_semantic_cosine_v1'),
  temporalAligned('temporal_aligned_v1'),
  temporalDtw('temporal_dtw_v1'),

  /// Read-only compatibility for evaluations collected before schema v15.
  @Deprecated('Legacy Track.embedding ranking was removed in schema v15')
  legacy('legacy_cosine_v1');

  const ResearchSimilarityMethod(this.version);
  final String version;
}

class SimilarityEvaluation {
  SimilarityEvaluation({
    required this.id,
    required this.seedTrackId,
    required this.candidateTrackId,
    required this.method,
    required this.sourceRepresentationModelId,
    required this.sourceRepresentationModelVersion,
    required this.sourcePreprocessingVersion,
    required this.scoreShown,
    this.rawDistance,
    this.soundRating,
    this.atmosphereRating,
    this.trajectoryRating,
    this.wouldListenNext,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (id.isEmpty || seedTrackId.isEmpty || candidateTrackId.isEmpty) {
      throw ArgumentError('Evaluation identity must not be empty');
    }
    if (sourceRepresentationModelId.isEmpty ||
        sourceRepresentationModelVersion.isEmpty ||
        sourcePreprocessingVersion.isEmpty) {
      throw ArgumentError('Evaluation model identity must not be empty');
    }
    if (!scoreShown.isFinite || rawDistance?.isFinite == false) {
      throw ArgumentError('Evaluation scores must be finite');
    }
    for (final rating in [soundRating, atmosphereRating, trajectoryRating]) {
      if (rating != null && (rating < 0 || rating > 3)) {
        throw ArgumentError.value(rating, 'rating', 'must be in 0..3');
      }
    }
  }

  final String id;
  final String seedTrackId;
  final String candidateTrackId;
  final ResearchSimilarityMethod method;
  final String sourceRepresentationModelId;
  final String sourceRepresentationModelVersion;
  final String sourcePreprocessingVersion;
  final double scoreShown;
  final double? rawDistance;
  final int? soundRating;
  final int? atmosphereRating;
  final int? trajectoryRating;
  final bool? wouldListenNext;
  final DateTime createdAt;
  final DateTime updatedAt;
}
