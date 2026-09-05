class WaveContinuationConfig {
  const WaveContinuationConfig({
    this.batchSize = 5,
    this.remainingQueueThreshold = 3,
    this.recentContextSize = 3,
  }) : assert(batchSize > 0),
       assert(remainingQueueThreshold >= 0),
       assert(recentContextSize > 0);

  final int batchSize;
  final int remainingQueueThreshold;
  final int recentContextSize;
}
