import 'package:equatable/equatable.dart';

import 'music_analysis.dart';
import 'track_embedding.dart';

class TrackTemporalEmbedding extends Equatable {
  TrackTemporalEmbedding({
    required this.id,
    required this.trackId,
    required this.representation,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.provider,
    required this.audioRevision,
    required this.dimension,
    required this.dtype,
    required this.normalized,
    required this.createdAt,
    required this.summary,
    required List<TemporalAnalysisSegment> segments,
  }) : segments = List.unmodifiable(segments) {
    if (id.isEmpty || trackId.isEmpty || representation.isEmpty) {
      throw ArgumentError('Temporal embedding identity must not be empty');
    }
    if (modelId.isEmpty ||
        modelVersion.isEmpty ||
        preprocessingVersion.isEmpty) {
      throw ArgumentError('Temporal model identity must not be empty');
    }
    if (audioRevision < 0 || dimension <= 0 || dtype != 'float32') {
      throw ArgumentError('Invalid temporal embedding metadata');
    }
    if (segments.isEmpty || segments.length != summary.numberOfSegments) {
      throw ArgumentError.value(segments, 'segments');
    }
  }

  final String id;
  final String trackId;
  final String representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final TrackEmbeddingProvider provider;
  final int audioRevision;
  final int dimension;
  final String dtype;
  final bool normalized;
  final DateTime createdAt;
  final TemporalAnalysisSummary summary;
  final List<TemporalAnalysisSegment> segments;

  @override
  List<Object> get props => [
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
    audioRevision,
    dimension,
    dtype,
    normalized,
    createdAt,
    summary,
    segments,
  ];
}
