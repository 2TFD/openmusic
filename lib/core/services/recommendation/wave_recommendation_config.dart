class WaveContinuationConfig {
  const WaveContinuationConfig({
    this.batchSize = 5,
    this.remainingQueueThreshold = 3,
    this.recentContextSize = 3,
    this.recentCooldownSize = 20,
    this.cooldownRelaxationSteps = const [10, 3, 0],
  }) : assert(batchSize > 0),
       assert(remainingQueueThreshold >= 0),
       assert(recentContextSize > 0),
       assert(recentCooldownSize > 0);

  final int batchSize;
  final int remainingQueueThreshold;
  final int recentContextSize;
  final int recentCooldownSize;
  final List<int> cooldownRelaxationSteps;
}
