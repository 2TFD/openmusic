class TrackWaveConfig {
  const TrackWaveConfig({
    this.batchSize = 5,
    this.globalCandidatePoolSize = 50,
    this.recentContextSize = 3,
    this.globalWeight = 0.65,
    this.temporalWeight = 0.35,
    this.recentProfileWeight = 0.35,
  }) : assert(batchSize > 0),
       assert(globalCandidatePoolSize > 0),
       assert(recentContextSize > 0),
       assert(globalWeight >= 0),
       assert(temporalWeight >= 0),
       assert(globalWeight + temporalWeight > 0),
       assert(recentProfileWeight >= 0 && recentProfileWeight <= 1);

  static const algorithmVersion = 'track_wave_v1';

  final int batchSize;
  final int globalCandidatePoolSize;
  final int recentContextSize;
  final double globalWeight;
  final double temporalWeight;
  final double recentProfileWeight;
}
