import '../../../layers/domain/entities/wave_session.dart';
import '../../../layers/domain/repositories/track_embedding_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/repositories/track_temporal_embedding_repository.dart';
import '../music_analysis/music_analysis_model_registry.dart';
import 'audio_wave_support.dart';
import 'track_wave_config.dart';
import 'wave_recommendation_strategy.dart';

class TrackWaveEngine implements WaveRecommendationStrategy {
  TrackWaveEngine({
    required TrackRepository tracks,
    required TrackEmbeddingRepository globalEmbeddings,
    required TrackTemporalEmbeddingRepository temporalEmbeddings,
    required MusicAnalysisModelRegistry registry,
    required TrackWaveConfig config,
  }) : _loader = AudioWaveDataLoader(
         tracks: tracks,
         globals: globalEmbeddings,
         temporals: temporalEmbeddings,
         registry: registry,
       ),
       _config = config;

  final AudioWaveDataLoader _loader;
  final TrackWaveConfig _config;

  TrackWaveConfig get config => _config;

  @override
  WaveSourceType get sourceType => WaveSourceType.track;

  Future<WaveRecommendationBatch> generate({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) => generateWave(
    session: session,
    currentTrackId: currentTrackId,
    queuedTrackIds: queuedTrackIds,
  );

  @override
  Future<WaveRecommendationBatch> generateWave({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) async {
    final source = session.source;
    if (source is! TrackWaveSource) {
      throw ArgumentError('TrackWaveEngine requires a TrackWaveSource');
    }
    final extraRevisions = source.seedAudioRevision == null
        ? const <String, int>{}
        : {source.trackId: source.seedAudioRevision!};
    final data = await _loader.load(additionalAudioRevisions: extraRevisions);
    final recentProfileIds =
        session.profileTrackIds.length <= _config.recentContextSize
        ? session.profileTrackIds
        : session.profileTrackIds.sublist(
            session.profileTrackIds.length - _config.recentContextSize,
          );
    final seedVectors = [
      if (data.globals[source.trackId] case final embedding?) embedding.vector,
    ];
    final recentVectors = [
      for (final id in recentProfileIds)
        if (data.globals[id] case final embedding?) embedding.vector,
    ];
    final profile = AudioWaveScoring.blendedCentroid(
      seedVectors: seedVectors,
      recentVectors: recentVectors,
      recentWeight: _config.recentProfileWeight,
    );
    if (profile == null) {
      return WaveRecommendationBatch(candidates: const [], session: session);
    }

    final excluded = <String>{
      source.trackId,
      ...session.recentTrackIds,
      ...session.cycleTrackIds,
      ...queuedTrackIds,
      ?currentTrackId,
    };
    final globalRanked = <({String id, double cosine, double similarity})>[];
    for (final track in data.tracks) {
      if (excluded.contains(track.id) || !isPlayableWaveTrack(track)) continue;
      final embedding = data.globals[track.id];
      if (embedding == null) continue;
      final cosine = AudioWaveScoring.cosine(profile, embedding.vector);
      if (cosine == null) continue;
      globalRanked.add((
        id: track.id,
        cosine: cosine,
        similarity: AudioWaveScoring.normalizeCosine(cosine),
      ));
    }
    globalRanked.sort((left, right) {
      final score = right.similarity.compareTo(left.similarity);
      return score != 0 ? score : left.id.compareTo(right.id);
    });
    final pool = globalRanked.take(_config.globalCandidatePoolSize);
    final seedTemporal = [
      if (data.temporals[source.trackId] case final embedding?)
        embedding.segments,
    ];
    final recentTemporal = [
      for (final id in recentProfileIds)
        if (data.temporals[id] case final embedding?) embedding.segments,
    ];
    final candidates = <WaveCandidate>[];
    for (final global in pool) {
      final temporal = data.temporals[global.id];
      final temporalSimilarity = temporal == null
          ? null
          : AudioWaveScoring.blendedTemporal(
              seedProfiles: seedTemporal,
              recentProfiles: recentTemporal,
              candidate: temporal.segments,
              recentWeight: _config.recentProfileWeight,
            );
      final score = AudioWaveScoring.weightedScore(
        globalSimilarity: global.similarity,
        temporalSimilarity: temporalSimilarity,
        globalWeight: _config.globalWeight,
        temporalWeight: _config.temporalWeight,
      );
      candidates.add(
        WaveCandidate(
          track: data.byId[global.id]!,
          globalCosineSimilarity: global.cosine,
          globalSimilarity: global.similarity,
          temporalSimilarity: temporalSimilarity,
          finalScore: score.score,
          availableWeight: score.availableWeight,
        ),
      );
    }
    candidates.sort(_compareCandidates);
    final selected = candidates.take(_config.batchSize).toList(growable: false);
    return WaveRecommendationBatch(
      candidates: selected,
      session: session.withGeneratedTracks(
        selected.map((candidate) => candidate.track.id),
      ),
    );
  }

  static int _compareCandidates(WaveCandidate left, WaveCandidate right) {
    final finalScore = right.finalScore.compareTo(left.finalScore);
    if (finalScore != 0) return finalScore;
    final global = (right.globalSimilarity ?? -1).compareTo(
      left.globalSimilarity ?? -1,
    );
    if (global != 0) return global;
    return left.track.id.compareTo(right.track.id);
  }
}
