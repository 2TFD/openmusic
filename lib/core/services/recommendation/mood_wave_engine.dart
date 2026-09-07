import 'dart:math' as math;

import '../../../layers/domain/entities/mood_map.dart';
import '../../../layers/domain/entities/mood_wave.dart';
import '../../../layers/domain/entities/music_analysis.dart';
import '../../../layers/domain/entities/track_embedding.dart';
import '../../../layers/domain/entities/track_temporal_embedding.dart';
import '../../../layers/domain/repositories/mood_map_repository.dart';
import '../../../layers/domain/repositories/track_embedding_repository.dart';
import '../../../layers/domain/repositories/track_temporal_embedding_repository.dart';
import '../../../layers/domain/services/temporal_dtw_similarity.dart';
import '../../../layers/domain/services/vector_similarity.dart';
import '../music_analysis/music_analysis_model_registry.dart';
import 'mood_wave_config.dart';
import 'wave_recommendation_strategy.dart';

class MoodWaveEngine implements WaveRecommendationStrategy {
  MoodWaveEngine({
    required MoodMapRepository moods,
    required TrackEmbeddingRepository globalEmbeddings,
    required TrackTemporalEmbeddingRepository temporalEmbeddings,
    required MusicAnalysisModelRegistry registry,
    required MoodWaveConfig config,
  }) : _moods = moods,
       _globalEmbeddings = globalEmbeddings,
       _temporalEmbeddings = temporalEmbeddings,
       _registry = registry,
       _config = config;

  final MoodMapRepository _moods;
  final TrackEmbeddingRepository _globalEmbeddings;
  final TrackTemporalEmbeddingRepository _temporalEmbeddings;
  final MusicAnalysisModelRegistry _registry;
  final MoodWaveConfig _config;

  MoodWaveConfig get config => _config;

  @override
  WaveSourceType get sourceType => WaveSourceType.mood;

  @override
  Future<WaveRecommendationBatch> generateWave({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) => generate(
    session: session,
    currentTrackId: currentTrackId,
    queuedTrackIds: queuedTrackIds,
  );

  Future<MoodWaveBatch> generate({
    required MoodWaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) async {
    final moodEntries = await _moods.loadTracks();
    final allById = <String, MoodMapTrack>{
      for (final entry in moodEntries) entry.track.id: entry,
    };
    final profileIds = _profileIds(session);
    final recentMood = _meanMood(profileIds, allById);
    final effectiveTarget = effectiveTargetFor(
      session: session,
      recentMood: recentMood,
      config: _config,
    );

    final excludedIds = <String>{
      ...session.recentTrackIds,
      ...session.cycleTrackIds,
      ...queuedTrackIds,
      ?session.seedTrackId,
      ?currentTrackId,
    };
    final available = <String, MoodMapTrack>{};
    for (final entry in moodEntries) {
      final track = entry.track;
      if (available.containsKey(track.id) ||
          excludedIds.contains(track.id) ||
          !track.isReadyToPlay ||
          !track.source.isAvailable ||
          !_validMood(entry.valence, entry.arousal)) {
        continue;
      }
      available[track.id] = entry;
    }

    final distances = {
      for (final entry in available.values)
        entry.track.id: moodDistance(
          trackValence: entry.valence,
          trackArousal: entry.arousal,
          targetValence: effectiveTarget.valence,
          targetArousal: effectiveTarget.arousal,
        ),
    };
    final eligibleTrackCount = distances.values
        .where((distance) => distance <= session.radius)
        .length;
    final modeRadius =
        session.radius *
        (session.mode == MoodWaveMode.explore
            ? _config.exploreRadiusMultiplier
            : 1);
    var effectiveRadius = modeRadius;
    var poolIds = _inside(distances, effectiveRadius);
    var expansion = 0.0;
    while (poolIds.length < _config.batchSize &&
        expansion < _config.maxRadiusExpansion) {
      expansion = math.min(
        _config.maxRadiusExpansion,
        expansion + _config.radiusExpansionStep,
      );
      effectiveRadius = modeRadius + expansion;
      poolIds = _inside(distances, effectiveRadius);
    }

    if (poolIds.isEmpty) {
      return MoodWaveBatch(
        candidates: const [],
        session: session.withGeneratedTracks(
          const [],
          effectiveTarget: effectiveTarget,
        ),
        effectiveRadius: effectiveRadius,
        eligibleTrackCount: eligibleTrackCount,
      );
    }

    final models = await _loadModels();
    final globalModel = models?.find(MusicAnalysisRepresentation.audioGlobal);
    final temporalModel = models?.find(
      MusicAnalysisRepresentation.audioTemporal,
    );
    final allowedAudioRevisions = <String, int>{
      for (final entry in allById.values)
        entry.track.id: entry.track.audioRevision,
    };
    final seedId = session.seedTrackId;
    final seedRevision = session.seedAudioRevision;
    if (seedId != null && seedRevision != null) {
      allowedAudioRevisions[seedId] = seedRevision;
    }
    final globals = globalModel == null
        ? const <String, TrackEmbedding>{}
        : await _loadGlobals(globalModel, allowedAudioRevisions);
    final temporals = temporalModel == null
        ? const <String, TrackTemporalEmbedding>{}
        : await _loadTemporals(temporalModel, allowedAudioRevisions);
    final profileGlobals = [
      for (final id in profileIds)
        if (globals[id] case final embedding?) embedding.vector,
    ];
    final globalProfile = normalizedMean(profileGlobals);
    final profileTemporals = [
      for (final id in profileIds)
        if (temporals[id] case final embedding?) embedding.segments,
    ];

    final candidates = <MoodWaveCandidate>[];
    for (final id in poolIds) {
      final entry = available[id]!;
      final distance = distances[id]!;
      final candidateGlobal = globals[id];
      final globalCosine = globalProfile == null || candidateGlobal == null
          ? null
          : VectorSimilarity.cosine(globalProfile, candidateGlobal.vector);
      final globalSimilarity = globalCosine == null
          ? null
          : normalizeCosine(globalCosine);
      final candidateTemporal = temporals[id];
      final temporalSimilarity =
          profileTemporals.isEmpty || candidateTemporal == null
          ? null
          : _meanTemporalSimilarity(
              profileTemporals,
              candidateTemporal.segments,
            );
      final moodProximity = normalizeMoodProximity(
        distance,
        normalizationDistance: _config.moodNormalizationDistance,
      );
      final score = weightedScore(
        moodProximity: moodProximity,
        globalSimilarity: globalSimilarity,
        temporalSimilarity: temporalSimilarity,
        moodWeight: _config.moodWeight,
        globalWeight: _config.globalWeight,
        temporalWeight: _config.temporalWeight,
      );
      candidates.add(
        MoodWaveCandidate(
          track: entry.track,
          position: MoodPoint(valence: entry.valence, arousal: entry.arousal),
          distance: distance,
          moodProximity: moodProximity,
          globalCosineSimilarity: globalCosine,
          globalSimilarity: globalSimilarity,
          temporalSimilarity: temporalSimilarity,
          finalScore: score.score,
          availableWeight: score.availableWeight,
          withinRequestedRadius: distance <= session.radius,
        ),
      );
    }
    candidates.sort((left, right) {
      final leftTier = _radiusTier(left.distance, session.radius, modeRadius);
      final rightTier = _radiusTier(right.distance, session.radius, modeRadius);
      if (leftTier != rightTier) return leftTier.compareTo(rightTier);
      final scoreOrder = right.finalScore.compareTo(left.finalScore);
      if (scoreOrder != 0) return scoreOrder;
      final distanceOrder = left.distance.compareTo(right.distance);
      if (distanceOrder != 0) return distanceOrder;
      return left.track.id.compareTo(right.track.id);
    });
    final selected = candidates.take(_config.batchSize).toList(growable: false);
    return MoodWaveBatch(
      candidates: selected,
      session: session.withGeneratedTracks(
        selected.map((candidate) => candidate.track.id),
        effectiveTarget: effectiveTarget,
      ),
      effectiveRadius: effectiveRadius,
      eligibleTrackCount: eligibleTrackCount,
    );
  }

  static double moodDistance({
    required double trackValence,
    required double trackArousal,
    required double targetValence,
    required double targetArousal,
  }) {
    final valenceDelta = trackValence - targetValence;
    final arousalDelta = trackArousal - targetArousal;
    return math.sqrt(valenceDelta * valenceDelta + arousalDelta * arousalDelta);
  }

  static double normalizeMoodProximity(
    double distance, {
    double normalizationDistance = 2.8284271247461903,
  }) {
    if (!distance.isFinite || !normalizationDistance.isFinite) return 0;
    if (normalizationDistance <= 0) {
      throw ArgumentError.value(normalizationDistance, 'normalizationDistance');
    }
    return (1 - distance / normalizationDistance).clamp(0, 1).toDouble();
  }

  static double normalizeCosine(double cosine) {
    if (!cosine.isFinite) return 0;
    return ((cosine.clamp(-1, 1) + 1) / 2).toDouble();
  }

  static ({double score, double availableWeight}) weightedScore({
    required double moodProximity,
    required double? globalSimilarity,
    required double? temporalSimilarity,
    double moodWeight = 0.50,
    double globalWeight = 0.30,
    double temporalWeight = 0.20,
  }) {
    if (moodWeight < 0 || globalWeight < 0 || temporalWeight < 0) {
      throw ArgumentError('Mood Wave weights must not be negative');
    }
    var weighted = moodWeight * moodProximity.clamp(0, 1);
    var available = moodWeight;
    if (globalSimilarity != null) {
      weighted += globalWeight * globalSimilarity.clamp(0, 1);
      available += globalWeight;
    }
    if (temporalSimilarity != null) {
      weighted += temporalWeight * temporalSimilarity.clamp(0, 1);
      available += temporalWeight;
    }
    if (available == 0) return (score: 0, availableWeight: 0);
    return (score: weighted / available, availableWeight: available);
  }

  static MoodPoint effectiveTargetFor({
    required MoodWaveSession session,
    required MoodPoint? recentMood,
    required MoodWaveConfig config,
  }) {
    MoodPoint blend(double userWeight) {
      if (recentMood == null) return session.userTarget;
      return MoodPoint(
        valence:
            userWeight * session.userTarget.valence +
            (1 - userWeight) * recentMood.valence,
        arousal:
            userWeight * session.userTarget.arousal +
            (1 - userWeight) * recentMood.arousal,
      );
    }

    return switch (session.mode) {
      MoodWaveMode.stay => blend(config.stayUserTargetWeight),
      MoodWaveMode.explore => blend(config.exploreUserTargetWeight),
      MoodWaveMode.lift => _shift(
        session.generationCount == 0
            ? blend(config.stayUserTargetWeight)
            : session.effectiveTarget,
        valence: config.liftValenceStep,
        arousal: config.liftArousalStep,
      ),
      MoodWaveMode.calm => _shift(
        session.generationCount == 0
            ? blend(config.stayUserTargetWeight)
            : session.effectiveTarget,
        valence: config.calmValenceStep,
        arousal: -config.calmArousalStep,
      ),
    };
  }

  static List<double>? normalizedMean(List<List<double>> vectors) {
    if (vectors.isEmpty) return null;
    final dimension = vectors.first.length;
    if (dimension == 0 || vectors.any((vector) => vector.length != dimension)) {
      return null;
    }
    final mean = List<double>.filled(dimension, 0);
    for (final vector in vectors) {
      for (var index = 0; index < dimension; index++) {
        mean[index] += vector[index] / vectors.length;
      }
    }
    final norm = math.sqrt(
      mean.fold<double>(0, (sum, value) => sum + value * value),
    );
    if (!norm.isFinite || norm == 0) return null;
    return [for (final value in mean) value / norm];
  }

  List<String> _profileIds(MoodWaveSession session) {
    final recent = session.profileTrackIds;
    if (recent.isNotEmpty) {
      return recent.length <= _config.recentContextSize
          ? recent
          : recent.sublist(recent.length - _config.recentContextSize);
    }
    return session.seedTrackId == null ? const [] : [session.seedTrackId!];
  }

  static MoodPoint? _meanMood(
    List<String> ids,
    Map<String, MoodMapTrack> tracks,
  ) {
    final values = <MoodMapTrack>[for (final id in ids) ?tracks[id]];
    if (values.isEmpty) return null;
    return MoodPoint(
      valence:
          values.fold<double>(0, (sum, entry) => sum + entry.valence) /
          values.length,
      arousal:
          values.fold<double>(0, (sum, entry) => sum + entry.arousal) /
          values.length,
    );
  }

  static MoodPoint _shift(
    MoodPoint point, {
    required double valence,
    required double arousal,
  }) => MoodPoint(
    valence: (point.valence + valence).clamp(-1, 1).toDouble(),
    arousal: (point.arousal + arousal).clamp(-1, 1).toDouble(),
  );

  static bool _validMood(double valence, double arousal) =>
      valence.isFinite &&
      arousal.isFinite &&
      valence >= -1 &&
      valence <= 1 &&
      arousal >= -1 &&
      arousal <= 1;

  static List<String> _inside(Map<String, double> distances, double radius) => [
    for (final entry in distances.entries)
      if (entry.value <= radius) entry.key,
  ];

  static int _radiusTier(
    double distance,
    double requestedRadius,
    double modeRadius,
  ) {
    if (distance <= requestedRadius) return 0;
    if (distance <= modeRadius) return 1;
    return 2;
  }

  Future<MusicAnalysisModels?> _loadModels() async {
    try {
      return await _registry.getModels();
    } on Object {
      return null;
    }
  }

  Future<Map<String, TrackEmbedding>> _loadGlobals(
    MusicAnalysisModel model,
    Map<String, int> allowedAudioRevisions,
  ) async {
    try {
      final values = await _globalEmbeddings.getBySpace(
        modality: TrackEmbeddingModality.audio,
        modelId: model.modelId,
        modelVersion: model.modelVersion,
        preprocessingVersion: model.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
      );
      return {
        for (final value in values)
          if (allowedAudioRevisions[value.trackId] case final audioRevision?
              when value.audioRevision == audioRevision &&
                  value.dimensions == model.dimension)
            value.trackId: value,
      };
    } on Object {
      return const {};
    }
  }

  Future<Map<String, TrackTemporalEmbedding>> _loadTemporals(
    MusicAnalysisModel model,
    Map<String, int> allowedAudioRevisions,
  ) async {
    try {
      final values = await _temporalEmbeddings.getBySpace(
        representation: model.representation.apiName,
        modelId: model.modelId,
        modelVersion: model.modelVersion,
        preprocessingVersion: model.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
      );
      return {
        for (final value in values)
          if (allowedAudioRevisions[value.trackId] case final audioRevision?
              when value.audioRevision == audioRevision &&
                  value.dimension == model.dimension)
            value.trackId: value,
      };
    } on Object {
      return const {};
    }
  }

  static double? _meanTemporalSimilarity(
    List<List<TemporalAnalysisSegment>> profiles,
    List<TemporalAnalysisSegment> candidate,
  ) {
    try {
      const dtw = TemporalDtwSimilarity();
      return profiles.fold<double>(
            0,
            (sum, profile) =>
                sum + dtw.compare(profile, candidate).rankingScore,
          ) /
          profiles.length;
    } on ArgumentError {
      return null;
    }
  }
}
