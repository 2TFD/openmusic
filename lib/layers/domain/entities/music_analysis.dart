import 'package:equatable/equatable.dart';

enum MusicAnalysisRepresentation {
  audioGlobal('audio.global'),
  audioTemporal('audio.temporal'),
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
    required this.dimension,
    required this.dtype,
    required this.normalized,
  }) {
    if (modelId.trim().isEmpty) throw ArgumentError.value(modelId, 'modelId');
    if (modelVersion.trim().isEmpty) {
      throw ArgumentError.value(modelVersion, 'modelVersion');
    }
    if (preprocessingVersion.trim().isEmpty) {
      throw ArgumentError.value(preprocessingVersion, 'preprocessingVersion');
    }
    if (dimension <= 0) throw ArgumentError.value(dimension, 'dimension');
    if (dtype != 'float32') throw ArgumentError.value(dtype, 'dtype');
  }

  final MusicAnalysisRepresentation representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final int dimension;
  final String dtype;
  final bool normalized;

  @override
  List<Object> get props => [
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
    this.lyricsGlobal,
  });

  final String schemaVersion;
  final String? trackId;
  final String? contentIdentity;
  final GlobalAnalysisRepresentation? audioGlobal;
  final TemporalAnalysisRepresentation? audioTemporal;
  final GlobalAnalysisRepresentation? lyricsGlobal;

  @override
  List<Object?> get props => [
    schemaVersion,
    trackId,
    contentIdentity,
    audioGlobal,
    audioTemporal,
    lyricsGlobal,
  ];
}
