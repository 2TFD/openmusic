import 'package:equatable/equatable.dart';

enum MusicAnalysisRepresentation {
  audioGlobal('audio.global'),
  audioTemporal('audio.temporal'),
  audioEmotionGlobal('audio.emotion.global'),
  audioEmotionTemporal('audio.emotion.temporal'),
  lyricsGlobal('lyrics.global');

  const MusicAnalysisRepresentation(this.apiName);
  final String apiName;

  static MusicAnalysisRepresentation parse(String value) => values.firstWhere(
    (entry) => entry.apiName == value,
    orElse: () => throw ArgumentError.value(value, 'representation'),
  );
}

class MusicAnalysisModel extends Equatable {
  MusicAnalysisModel({
    required this.representation,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    this.dimension = 0,
    this.dtype = 'float32',
    this.normalized = false,
  }) {
    if (modelId.trim().isEmpty) throw ArgumentError.value(modelId, 'modelId');
    if (modelVersion.trim().isEmpty) {
      throw ArgumentError.value(modelVersion, 'modelVersion');
    }
    if (preprocessingVersion.trim().isEmpty) {
      throw ArgumentError.value(preprocessingVersion, 'preprocessingVersion');
    }
    if (representation.isEmbedding && dimension <= 0) {
      throw ArgumentError.value(dimension, 'dimension');
    }
    if (representation.isEmbedding && dtype != 'float32') {
      throw ArgumentError.value(dtype, 'dtype');
    }
  }

  final MusicAnalysisRepresentation representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final int dimension;
  final String dtype;
  final bool normalized;

  @override
  List<Object?> get props => [
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    dimension,
    dtype,
    normalized,
  ];
}

class MusicAnalysisModels extends Equatable {
  const MusicAnalysisModels({
    required this.schemaVersion,
    required this.models,
  });

  final String schemaVersion;
  final List<MusicAnalysisModel> models;

  MusicAnalysisModel require(MusicAnalysisRepresentation representation) =>
      models.firstWhere((model) => model.representation == representation);

  MusicAnalysisModel? find(MusicAnalysisRepresentation representation) {
    for (final model in models) {
      if (model.representation == representation) return model;
    }
    return null;
  }

  @override
  List<Object> get props => [schemaVersion, models];
}

class GlobalAnalysisRepresentation extends Equatable {
  GlobalAnalysisRepresentation({
    required this.metadata,
    required List<double> vector,
  }) : vector = List.unmodifiable(vector) {
    if (vector.length != metadata.dimension ||
        vector.isEmpty ||
        vector.any((value) => !value.isFinite)) {
      throw ArgumentError.value(vector, 'vector');
    }
  }

  final MusicAnalysisModel metadata;
  final List<double> vector;

  @override
  List<Object> get props => [metadata, vector];
}

class TemporalAnalysisSegment extends Equatable {
  TemporalAnalysisSegment({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.dimensions,
    required List<double> vector,
  }) : vector = List.unmodifiable(vector) {
    if (index < 0 || startMs < 0 || endMs <= startMs) {
      throw ArgumentError('Invalid temporal segment bounds');
    }
    if (dimensions <= 0 ||
        vector.length != dimensions ||
        vector.any((value) => !value.isFinite)) {
      throw ArgumentError.value(vector, 'vector');
    }
  }

  final int index;
  final int startMs;
  final int endMs;
  final int dimensions;
  final List<double> vector;

  @override
  List<Object> get props => [index, startMs, endMs, dimensions, vector];
}

class TemporalAnalysisSummary extends Equatable {
  const TemporalAnalysisSummary({
    required this.numberOfSegments,
    required this.meanAdjacentDistance,
    required this.maxAdjacentDistance,
    required this.trajectoryVariance,
    this.largestTransitionIndex,
  });

  final int numberOfSegments;
  final double meanAdjacentDistance;
  final double maxAdjacentDistance;
  final double trajectoryVariance;
  final int? largestTransitionIndex;

  @override
  List<Object?> get props => [
    numberOfSegments,
    meanAdjacentDistance,
    maxAdjacentDistance,
    trajectoryVariance,
    largestTransitionIndex,
  ];
}

class TemporalAnalysisRepresentation extends Equatable {
  TemporalAnalysisRepresentation({
    required this.metadata,
    required List<TemporalAnalysisSegment> segments,
    required this.summary,
  }) : segments = List.unmodifiable(segments) {
    if (segments.isEmpty || segments.length != summary.numberOfSegments) {
      throw ArgumentError.value(segments, 'segments');
    }
    if (segments.any((segment) => segment.dimensions != metadata.dimension)) {
      throw ArgumentError('Temporal dimensions differ from model metadata');
    }
  }

  final MusicAnalysisModel metadata;
  final List<TemporalAnalysisSegment> segments;
  final TemporalAnalysisSummary summary;

  @override
  List<Object> get props => [metadata, segments, summary];
}

class MusicAnalysisResponse extends Equatable {
  const MusicAnalysisResponse({
    required this.schemaVersion,
    this.trackId,
    this.contentIdentity,
    this.audioGlobal,
    this.audioTemporal,
    this.audioEmotionGlobal,
    this.audioEmotionTemporal,
    this.lyricsGlobal,
  });

  final String schemaVersion;
  final String? trackId;
  final String? contentIdentity;
  final GlobalAnalysisRepresentation? audioGlobal;
  final TemporalAnalysisRepresentation? audioTemporal;
  final AudioEmotionGlobalResult? audioEmotionGlobal;
  final AudioEmotionTemporalResult? audioEmotionTemporal;
  final GlobalAnalysisRepresentation? lyricsGlobal;

  @override
  List<Object?> get props => [
    schemaVersion,
    trackId,
    contentIdentity,
    audioGlobal,
    audioTemporal,
    audioEmotionGlobal,
    audioEmotionTemporal,
    lyricsGlobal,
  ];
}

extension MusicAnalysisRepresentationKind on MusicAnalysisRepresentation {
  bool get isEmbedding => switch (this) {
    MusicAnalysisRepresentation.audioGlobal ||
    MusicAnalysisRepresentation.audioTemporal ||
    MusicAnalysisRepresentation.lyricsGlobal => true,
    MusicAnalysisRepresentation.audioEmotionGlobal ||
    MusicAnalysisRepresentation.audioEmotionTemporal => false,
  };

  bool get isEmotion => !isEmbedding;

  bool get isAudio => this != MusicAnalysisRepresentation.lyricsGlobal;
}

class MoodDistribution extends Equatable {
  MoodDistribution(
    Map<String, double> scores, {
    this.kind,
    this.vocabularyVersion,
  }) : scores = Map.unmodifiable(Map<String, double>.from(scores)) {
    if (scores.isEmpty ||
        scores.entries.any(
          (entry) =>
              entry.key.trim().isEmpty ||
              !entry.value.isFinite ||
              entry.value < 0 ||
              entry.value > 1,
        )) {
      throw ArgumentError.value(scores, 'scores');
    }
  }

  final Map<String, double> scores;
  final String? kind;
  final String? vocabularyVersion;

  List<MapEntry<String, double>> top({int limit = 5}) {
    if (limit <= 0) return const [];
    final entries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList(growable: false);
  }

  @override
  List<Object?> get props => [scores, kind, vocabularyVersion];
}

class AudioEmotionGlobalResult extends Equatable {
  AudioEmotionGlobalResult({
    required this.metadata,
    required this.valence,
    required this.arousal,
    this.rawValence,
    this.rawArousal,
    required this.moodDistribution,
  }) {
    _validatePosition(valence, arousal);
    if (rawValence != null && !rawValence!.isFinite) {
      throw ArgumentError.value(rawValence, 'rawValence');
    }
    if (rawArousal != null && !rawArousal!.isFinite) {
      throw ArgumentError.value(rawArousal, 'rawArousal');
    }
    if (metadata.representation !=
        MusicAnalysisRepresentation.audioEmotionGlobal) {
      throw ArgumentError('Expected audio.emotion.global metadata');
    }
  }

  final MusicAnalysisModel metadata;
  final double valence;
  final double arousal;
  final double? rawValence;
  final double? rawArousal;
  final MoodDistribution moodDistribution;

  @override
  List<Object?> get props => [
    metadata,
    valence,
    arousal,
    rawValence,
    rawArousal,
    moodDistribution,
  ];
}

class AudioEmotionSegment extends Equatable {
  AudioEmotionSegment({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.valence,
    required this.arousal,
    this.rawValence,
    this.rawArousal,
    required this.moodDistribution,
  }) {
    if (index < 0 || startMs < 0 || endMs <= startMs) {
      throw ArgumentError('Invalid emotion segment bounds');
    }
    _validatePosition(valence, arousal);
    if (rawValence != null && !rawValence!.isFinite) {
      throw ArgumentError.value(rawValence, 'rawValence');
    }
    if (rawArousal != null && !rawArousal!.isFinite) {
      throw ArgumentError.value(rawArousal, 'rawArousal');
    }
  }

  final int index;
  final int startMs;
  final int endMs;
  final double valence;
  final double arousal;
  final double? rawValence;
  final double? rawArousal;
  final MoodDistribution moodDistribution;

  @override
  List<Object?> get props => [
    index,
    startMs,
    endMs,
    valence,
    arousal,
    rawValence,
    rawArousal,
    moodDistribution,
  ];
}

class AudioEmotionTemporalSummary extends Equatable {
  AudioEmotionTemporalSummary({
    required this.numberOfSegments,
    this.valenceMean,
    this.valenceStd,
    this.minValence,
    this.maxValence,
    this.arousalMean,
    this.arousalStd,
    this.minArousal,
    this.maxArousal,
    this.emotionPathLength,
    this.largestEmotionChangeIndex,
    this.startEndEmotionDistance,
  }) {
    if (numberOfSegments <= 0) {
      throw ArgumentError.value(numberOfSegments, 'numberOfSegments');
    }
    for (final value in [
      valenceMean,
      minValence,
      maxValence,
      arousalMean,
      minArousal,
      maxArousal,
    ]) {
      if (value != null && (!value.isFinite || value < -1 || value > 1)) {
        throw ArgumentError.value(value, 'summary value');
      }
    }
    for (final value in [
      valenceStd,
      arousalStd,
      emotionPathLength,
      startEndEmotionDistance,
    ]) {
      if (value != null && (!value.isFinite || value < 0)) {
        throw ArgumentError.value(value, 'non-negative summary value');
      }
    }
    if (largestEmotionChangeIndex != null &&
        (largestEmotionChangeIndex! < 0 ||
            largestEmotionChangeIndex! >= numberOfSegments - 1)) {
      throw ArgumentError.value(
        largestEmotionChangeIndex,
        'largestEmotionChangeIndex',
      );
    }
  }

  final int numberOfSegments;
  final double? valenceMean;
  final double? valenceStd;
  final double? minValence;
  final double? maxValence;
  final double? arousalMean;
  final double? arousalStd;
  final double? minArousal;
  final double? maxArousal;
  final double? emotionPathLength;
  final int? largestEmotionChangeIndex;
  final double? startEndEmotionDistance;

  @override
  List<Object?> get props => [
    numberOfSegments,
    valenceMean,
    valenceStd,
    minValence,
    maxValence,
    arousalMean,
    arousalStd,
    minArousal,
    maxArousal,
    emotionPathLength,
    largestEmotionChangeIndex,
    startEndEmotionDistance,
  ];
}

class AudioEmotionTemporalResult extends Equatable {
  AudioEmotionTemporalResult({
    required this.metadata,
    required List<AudioEmotionSegment> segments,
    required this.summary,
  }) : segments = List.unmodifiable(segments) {
    if (metadata.representation !=
        MusicAnalysisRepresentation.audioEmotionTemporal) {
      throw ArgumentError('Expected audio.emotion.temporal metadata');
    }
    if (segments.isEmpty || segments.length != summary.numberOfSegments) {
      throw ArgumentError.value(segments, 'segments');
    }
  }

  final MusicAnalysisModel metadata;
  final List<AudioEmotionSegment> segments;
  final AudioEmotionTemporalSummary summary;

  @override
  List<Object> get props => [metadata, segments, summary];
}

void _validatePosition(double valence, double arousal) {
  if (!valence.isFinite || valence < -1 || valence > 1) {
    throw ArgumentError.value(valence, 'valence');
  }
  if (!arousal.isFinite || arousal < -1 || arousal > 1) {
    throw ArgumentError.value(arousal, 'arousal');
  }
}
