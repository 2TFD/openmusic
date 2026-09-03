import 'package:equatable/equatable.dart';

enum TrackEmbeddingModality { audio, lyrics, collaborative }

enum TrackEmbeddingProvider { local, server }

class TrackEmbedding extends Equatable {
  static const legacyPreprocessingVersion = 'legacy-unknown';

  factory TrackEmbedding({
    required String trackId,
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    String preprocessingVersion = legacyPreprocessingVersion,
    required TrackEmbeddingProvider provider,
    int? audioRevision,
    String? contentRevision,
    String dtype = 'float32',
    bool? normalized,
    required int dimensions,
    required List<double> vector,
    required DateTime createdAt,
  }) {
    if (trackId.isEmpty) throw ArgumentError.value(trackId, 'trackId');
    if (modelId.trim().isEmpty) throw ArgumentError.value(modelId, 'modelId');
    if (modelVersion.trim().isEmpty) {
      throw ArgumentError.value(modelVersion, 'modelVersion');
    }
    if (preprocessingVersion.trim().isEmpty) {
      throw ArgumentError.value(preprocessingVersion, 'preprocessingVersion');
    }
    if (dtype.trim().isEmpty) throw ArgumentError.value(dtype, 'dtype');
    if (dimensions <= 0) {
      throw ArgumentError.value(dimensions, 'dimensions', 'must be positive');
    }
    if (vector.isEmpty || vector.length != dimensions) {
      throw ArgumentError.value(
        vector.length,
        'vector',
        'must contain exactly $dimensions values',
      );
    }
    if (vector.any((value) => !value.isFinite)) {
      throw ArgumentError.value(vector, 'vector', 'values must be finite');
    }
    if (audioRevision != null && audioRevision < 0) {
      throw ArgumentError.value(
        audioRevision,
        'audioRevision',
        'must not be negative',
      );
    }
    final canonicalAudioRevision = audioRevision == null
        ? null
        : 'audio:$audioRevision';
    final resolvedContentRevision = switch (modality) {
      TrackEmbeddingModality.audio => contentRevision ?? canonicalAudioRevision,
      _ => contentRevision,
    };
    if (modality == TrackEmbeddingModality.audio &&
        audioRevision != null &&
        resolvedContentRevision != canonicalAudioRevision) {
      throw ArgumentError.value(
        contentRevision,
        'contentRevision',
        'audio embeddings use audio:<audioRevision>',
      );
    }
    if (modality == TrackEmbeddingModality.lyrics) {
      if (audioRevision != null) {
        throw ArgumentError.value(
          audioRevision,
          'audioRevision',
          'lyrics embeddings must not use audioRevision',
        );
      }
      if (resolvedContentRevision == null ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(resolvedContentRevision)) {
        throw ArgumentError.value(
          contentRevision,
          'contentRevision',
          'lyrics embeddings require a lowercase SHA-256 content hash',
        );
      }
    }
    if (resolvedContentRevision?.trim().isEmpty ?? false) {
      throw ArgumentError.value(contentRevision, 'contentRevision');
    }
    return TrackEmbedding._(
      trackId: trackId,
      modality: modality,
      modelId: modelId,
      modelVersion: modelVersion,
      preprocessingVersion: preprocessingVersion,
      provider: provider,
      audioRevision: audioRevision,
      contentRevision: resolvedContentRevision,
      dtype: dtype,
      normalized: normalized,
      dimensions: dimensions,
      vector: List<double>.unmodifiable(vector),
      createdAt: createdAt,
    );
  }

  const TrackEmbedding._({
    required this.trackId,
    required this.modality,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.provider,
    this.audioRevision,
    this.contentRevision,
    required this.dtype,
    this.normalized,
    required this.dimensions,
    required this.vector,
    required this.createdAt,
  });

  final String trackId;
  final TrackEmbeddingModality modality;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final TrackEmbeddingProvider provider;
  final int? audioRevision;
  final String? contentRevision;
  final String dtype;
  final bool? normalized;
  final int dimensions;
  final List<double> vector;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    trackId,
    modality,
    modelId,
    modelVersion,
    preprocessingVersion,
    provider,
    audioRevision,
    contentRevision,
    dtype,
    normalized,
    dimensions,
    vector,
    createdAt,
  ];
}
