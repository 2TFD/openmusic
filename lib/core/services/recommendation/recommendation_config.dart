class RecommendationConfig {
  const RecommendationConfig({
    this.globalCandidatePoolSize = 200,
    this.globalWeight = 0.52,
    this.temporalWeight = 0.28,
    this.lyricsWeight = 0.20,
  }) : assert(globalCandidatePoolSize > 0),
       assert(globalWeight >= 0),
       assert(temporalWeight >= 0),
       assert(lyricsWeight >= 0),
       assert(
         globalWeight + temporalWeight + lyricsWeight > 0.999999 &&
             globalWeight + temporalWeight + lyricsWeight < 1.000001,
       );

  static const algorithmVersion = 'audio_temporal_lyrics_hybrid_v1';
  static const temporalAlgorithmVersion = 'temporal_dtw_v1';

  final int globalCandidatePoolSize;
  final double globalWeight;
  final double temporalWeight;
  final double lyricsWeight;
}
