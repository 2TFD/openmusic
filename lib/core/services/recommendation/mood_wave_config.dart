class MoodWaveConfig {
  const MoodWaveConfig({
    this.batchSize = 5,
    this.remainingQueueThreshold = 3,
    this.recentContextSize = 3,
    this.radiusExpansionStep = 0.15,
    this.maxRadiusExpansion = 0.75,
    this.moodWeight = 0.50,
    this.globalWeight = 0.30,
    this.temporalWeight = 0.20,
    this.stayUserTargetWeight = 0.85,
    this.exploreUserTargetWeight = 0.65,
    this.exploreRadiusMultiplier = 1.25,
    this.liftValenceStep = 0.08,
    this.liftArousalStep = 0.03,
    this.calmValenceStep = 0,
    this.calmArousalStep = 0.08,
    this.moodNormalizationDistance = 2.8284271247461903,
  }) : assert(batchSize > 0),
       assert(remainingQueueThreshold >= 0),
       assert(recentContextSize > 0),
       assert(radiusExpansionStep > 0),
       assert(maxRadiusExpansion >= 0),
       assert(moodWeight >= 0),
       assert(globalWeight >= 0),
       assert(temporalWeight >= 0),
       assert(moodWeight + globalWeight + temporalWeight > 0),
       assert(stayUserTargetWeight >= 0 && stayUserTargetWeight <= 1),
       assert(exploreUserTargetWeight >= 0 && exploreUserTargetWeight <= 1),
       assert(exploreRadiusMultiplier >= 1),
       assert(liftValenceStep >= 0),
       assert(liftArousalStep >= 0),
       assert(calmValenceStep >= 0),
       assert(calmArousalStep >= 0),
       assert(moodNormalizationDistance > 0);

  static const algorithmVersion = 'mood_wave_v1';
  static const temporalAlgorithmVersion = 'temporal_dtw_v1';

  final int batchSize;
  final int remainingQueueThreshold;
  final int recentContextSize;
  final double radiusExpansionStep;
  final double maxRadiusExpansion;
  final double moodWeight;
  final double globalWeight;
  final double temporalWeight;
  final double stayUserTargetWeight;
  final double exploreUserTargetWeight;
  final double exploreRadiusMultiplier;
  final double liftValenceStep;
  final double liftArousalStep;
  final double calmValenceStep;
  final double calmArousalStep;
  final double moodNormalizationDistance;
}
