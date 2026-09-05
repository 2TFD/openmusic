import 'dart:math' as math;

import '../../../layers/domain/entities/music_analysis.dart';
import '../../../layers/domain/entities/track.dart';
import '../../../layers/domain/entities/track_embedding.dart';
import '../../../layers/domain/entities/track_temporal_embedding.dart';
import '../../../layers/domain/repositories/track_embedding_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/repositories/track_temporal_embedding_repository.dart';
import '../../../layers/domain/services/temporal_dtw_similarity.dart';
import '../../../layers/domain/services/vector_similarity.dart';
import '../music_analysis/music_analysis_model_registry.dart';

class AudioWaveLibraryData {
  const AudioWaveLibraryData({
    required this.tracks,
    required this.byId,
    required this.globals,
    required this.temporals,
  });

  final List<Track> tracks;
  final Map<String, Track> byId;
  final Map<String, TrackEmbedding> globals;
  final Map<String, TrackTemporalEmbedding> temporals;
}

class AudioWaveDataLoader {
  const AudioWaveDataLoader({
    required TrackRepository tracks,
    required TrackEmbeddingRepository globals,
    required TrackTemporalEmbeddingRepository temporals,
    required MusicAnalysisModelRegistry registry,
  }) : _tracks = tracks,
       _globals = globals,
       _temporals = temporals,
       _registry = registry;

  final TrackRepository _tracks;
  final TrackEmbeddingRepository _globals;
  final TrackTemporalEmbeddingRepository _temporals;
  final MusicAnalysisModelRegistry _registry;

  Future<AudioWaveLibraryData> load({
    Map<String, int> additionalAudioRevisions = const {},
  }) async {
    List<Track> tracks;
    try {
      tracks = await _tracks.getTracks();
    } on Object {
      tracks = const [];
    }
    final byId = <String, Track>{for (final track in tracks) track.id: track};
    final revisions = <String, int>{
      for (final track in tracks) track.id: track.audioRevision,
      ...additionalAudioRevisions,
    };
    MusicAnalysisModels? models;
    try {
      models = await _registry.getModels();
    } on Object {
      models = null;
    }
    final globalModel = models?.find(MusicAnalysisRepresentation.audioGlobal);
    final temporalModel = models?.find(
      MusicAnalysisRepresentation.audioTemporal,
    );
    return AudioWaveLibraryData(
      tracks: tracks,
      byId: byId,
      globals: globalModel == null
          ? const {}
          : await _loadGlobals(globalModel, revisions),
      temporals: temporalModel == null
          ? const {}
          : await _loadTemporals(temporalModel, revisions),
    );
  }

  Future<Map<String, TrackEmbedding>> _loadGlobals(
    MusicAnalysisModel model,
    Map<String, int> revisions,
  ) async {
    try {
      final values = await _globals.getBySpace(
        modality: TrackEmbeddingModality.audio,
        modelId: model.modelId,
        modelVersion: model.modelVersion,
        preprocessingVersion: model.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
      );
      return {
        for (final value in values)
          if (revisions[value.trackId] case final revision?
              when value.audioRevision == revision &&
                  value.dimensions == model.dimension &&
                  value.modality == TrackEmbeddingModality.audio &&
                  value.modelId == model.modelId &&
                  value.modelVersion == model.modelVersion &&
                  value.preprocessingVersion == model.preprocessingVersion &&
                  value.provider == TrackEmbeddingProvider.server)
            value.trackId: value,
      };
    } on Object {
      return const {};
    }
  }

  Future<Map<String, TrackTemporalEmbedding>> _loadTemporals(
    MusicAnalysisModel model,
    Map<String, int> revisions,
  ) async {
    try {
      final values = await _temporals.getBySpace(
        representation: model.representation.apiName,
        modelId: model.modelId,
        modelVersion: model.modelVersion,
        preprocessingVersion: model.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
      );
      return {
        for (final value in values)
          if (revisions[value.trackId] case final revision?
              when value.audioRevision == revision &&
                  value.dimension == model.dimension &&
                  value.representation == model.representation.apiName &&
                  value.modelId == model.modelId &&
                  value.modelVersion == model.modelVersion &&
                  value.preprocessingVersion == model.preprocessingVersion &&
                  value.provider == TrackEmbeddingProvider.server)
            value.trackId: value,
      };
    } on Object {
      return const {};
    }
  }
}

class AudioWaveScoring {
  const AudioWaveScoring._();

  static List<double>? normalizedCentroid(Iterable<List<double>> vectors) {
    final normalized = vectors
        .map(_normalize)
        .whereType<List<double>>()
        .toList();
    if (normalized.isEmpty) return null;
    final dimension = normalized.first.length;
    if (normalized.any((vector) => vector.length != dimension)) return null;
    final mean = List<double>.filled(dimension, 0);
    for (final vector in normalized) {
      for (var index = 0; index < dimension; index++) {
        mean[index] += vector[index] / normalized.length;
      }
    }
    return _normalize(mean);
  }

  static List<double>? blendedCentroid({
    required Iterable<List<double>> seedVectors,
    required Iterable<List<double>> recentVectors,
    required double recentWeight,
  }) {
    final seed = normalizedCentroid(seedVectors);
    final recent = normalizedCentroid(recentVectors);
    if (recent == null) return seed;
    if (seed == null) return recent;
    if (seed.length != recent.length) return seed;
    return _normalize([
      for (var index = 0; index < seed.length; index++)
        seed[index] * (1 - recentWeight) + recent[index] * recentWeight,
    ]);
  }

  static double? cosine(List<double>? profile, List<double> candidate) {
    if (profile == null || profile.length != candidate.length) return null;
    try {
      return VectorSimilarity.cosine(profile, candidate);
    } on ArgumentError {
      return null;
    }
  }

  static double normalizeCosine(double cosine) {
    if (!cosine.isFinite) return 0;
    return ((cosine.clamp(-1, 1) + 1) / 2).toDouble();
  }

  static double? meanTemporal(
    Iterable<List<TemporalAnalysisSegment>> profiles,
    List<TemporalAnalysisSegment> candidate,
  ) {
    final scores = <double>[];
    const dtw = TemporalDtwSimilarity();
    for (final profile in profiles) {
      try {
        scores.add(dtw.compare(profile, candidate).rankingScore);
      } on ArgumentError {
        // A malformed/incompatible trajectory is an unavailable signal.
      }
    }
    if (scores.isEmpty) return null;
    return scores.fold<double>(0, (sum, value) => sum + value) / scores.length;
  }

  static double? blendedTemporal({
    required Iterable<List<TemporalAnalysisSegment>> seedProfiles,
    required Iterable<List<TemporalAnalysisSegment>> recentProfiles,
    required List<TemporalAnalysisSegment> candidate,
    required double recentWeight,
  }) {
    final seed = meanTemporal(seedProfiles, candidate);
    final recent = meanTemporal(recentProfiles, candidate);
    if (recent == null) return seed;
    if (seed == null) return recent;
    return seed * (1 - recentWeight) + recent * recentWeight;
  }

  static ({double score, double availableWeight}) weightedScore({
    required double? globalSimilarity,
    required double? temporalSimilarity,
    required double globalWeight,
    required double temporalWeight,
  }) {
    if (globalWeight < 0 || temporalWeight < 0) {
      throw ArgumentError('Audio Wave weights must not be negative');
    }
    var weighted = 0.0;
    var available = 0.0;
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

  static List<double>? _normalize(List<double> vector) {
    if (vector.isEmpty || vector.any((value) => !value.isFinite)) return null;
    final norm = math.sqrt(
      vector.fold<double>(0, (sum, value) => sum + value * value),
    );
    if (!norm.isFinite || norm == 0) return null;
    return [for (final value in vector) value / norm];
  }
}

bool isPlayableWaveTrack(Track track) =>
    track.isReadyToPlay && track.source.isAvailable;
