import 'package:owlsonic/layers/domain/entities/mood_wave.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'mood_wave_engine.dart';
import 'wave_recommendation_engine.dart';

class WaveOrchestrator {
  final WaveRecommendationEngine? waveRecommendationEngine;
  final MoodWaveEngine? moodWaveEngine;

  const WaveOrchestrator({this.waveRecommendationEngine, this.moodWaveEngine});

  bool canGenerate(WaveSession session) =>
      waveRecommendationEngine != null ||
      (moodWaveEngine != null && session.source is MoodWaveSource);

  int get remainingQueueThreshold =>
      waveRecommendationEngine?.continuationConfig.remainingQueueThreshold ??
      moodWaveEngine?.config.remainingQueueThreshold ??
      3;

  int get recentContextSize =>
      waveRecommendationEngine?.continuationConfig.recentContextSize ??
      moodWaveEngine?.config.recentContextSize ??
      3;

  int get recentCooldownSize =>
      waveRecommendationEngine?.continuationConfig.recentCooldownSize ??
      recentContextSize;

  List<int> get cooldownRelaxationSteps =>
      waveRecommendationEngine?.continuationConfig.cooldownRelaxationSteps ??
      const [0];

  Future<WaveRecommendationBatch?> generateWave(
    WaveSession session, {
    required String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) async {
    final engine = waveRecommendationEngine;
    if (engine != null) {
      return engine.generate(
        session: session,
        currentTrackId: currentTrackId,
        queuedTrackIds: queuedTrackIds,
      );
    }
    if (session.source is MoodWaveSource) {
      return moodWaveEngine?.generate(
        session: session,
        currentTrackId: currentTrackId,
        queuedTrackIds: queuedTrackIds,
      );
    }
    return null;
  }

  Future<WaveRecommendationBatch?> generateWaveWithFallback(
    WaveSession session, {
    required String? currentTrackId,
    required Set<String> futureQueueTrackIds,
    required bool excludeFutureQueue,
  }) async {
    final fullRecent = session.recentTrackIds;
    final attempts = <WaveSession>[session];
    final newCycle = session.beginNewCycle();
    if (session.cycleTrackIds.isNotEmpty) attempts.add(newCycle);
    for (final limit in cooldownRelaxationSteps) {
      final relaxed = limit <= 0
          ? const <String>[]
          : fullRecent.length <= limit
          ? fullRecent
          : fullRecent.sublist(fullRecent.length - limit);
      final previousRecent = attempts.last.recentTrackIds;
      if (previousRecent.length == relaxed.length &&
          previousRecent.every(relaxed.contains)) {
        continue;
      }
      attempts.add(newCycle.copyWith(recentTrackIds: relaxed));
    }
    WaveRecommendationBatch? lastBatch;
    for (final attempt in attempts) {
      final batch = await generateWave(
        attempt,
        currentTrackId: currentTrackId,
        queuedTrackIds: excludeFutureQueue ? futureQueueTrackIds : const {},
      );
      if (batch == null) continue;
      lastBatch = batch;
      if (!batch.isEmpty) {
        return WaveRecommendationBatch(
          candidates: batch.candidates,
          session: batch.session.copyWith(
            recentTrackIds: fullRecent,
            profileTrackIds: session.profileTrackIds,
          ),
        );
      }
    }
    return lastBatch == null
        ? null
        : WaveRecommendationBatch(
            candidates: const [],
            session: lastBatch.session.copyWith(
              recentTrackIds: fullRecent,
              profileTrackIds: session.profileTrackIds,
            ),
          );
  }
}
