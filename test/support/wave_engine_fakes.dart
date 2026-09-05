import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_temporal_embedding_repository.dart';

Track waveTrack(
  String id, {
  String artistId = 'other',
  String? album,
  bool playable = true,
  bool available = true,
  int audioRevision = 1,
}) => Track(
  id: id,
  title: id,
  artists: [Artist(id: artistId, name: artistId)],
  duration: const Duration(minutes: 3),
  source: Source(
    type: SourceType.localFile,
    originalUrl: '/$id.mp3',
    isAvailable: available,
  ),
  addedAt: DateTime.utc(2026),
  filePath: playable ? '/$id.mp3' : null,
  album: album,
  audioRevision: audioRevision,
);

TrackEmbedding waveGlobal(
  String id,
  List<double> vector, {
  String modelId = 'global-model',
  String modelVersion = '1',
  String preprocessingVersion = 'prep',
  int audioRevision = 1,
}) => TrackEmbedding(
  trackId: id,
  modality: TrackEmbeddingModality.audio,
  modelId: modelId,
  modelVersion: modelVersion,
  preprocessingVersion: preprocessingVersion,
  provider: TrackEmbeddingProvider.server,
  audioRevision: audioRevision,
  normalized: true,
  dimensions: vector.length,
  vector: vector,
  createdAt: DateTime.utc(2026),
);

TrackTemporalEmbedding waveTemporal(
  String id,
  List<double> vector, {
  String modelId = 'temporal-model',
  String modelVersion = '1',
  String preprocessingVersion = 'prep',
  int audioRevision = 1,
}) => TrackTemporalEmbedding(
  id: 'temporal-$id-$modelId',
  trackId: id,
  representation: MusicAnalysisRepresentation.audioTemporal.apiName,
  modelId: modelId,
  modelVersion: modelVersion,
  preprocessingVersion: preprocessingVersion,
  provider: TrackEmbeddingProvider.server,
  audioRevision: audioRevision,
  dimension: vector.length,
  dtype: 'float32',
  normalized: true,
  createdAt: DateTime.utc(2026),
  summary: const TemporalAnalysisSummary(
    numberOfSegments: 1,
    meanAdjacentDistance: 0,
    maxAdjacentDistance: 0,
    trajectoryVariance: 0,
  ),
  segments: [
    TemporalAnalysisSegment(
      index: 0,
      startMs: 0,
      endMs: 1000,
      dimensions: vector.length,
      vector: vector,
    ),
  ],
);

class WaveTracks implements TrackRepository {
  const WaveTracks(this.values);
  final List<Track> values;

  @override
  Future<List<Track>> getTracks() async => values;

  @override
  Future<Track?> getTrackById(String id) async {
    for (final track in values) {
      if (track.id == id) return track;
    }
    return null;
  }

  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async =>
      values.where((track) => ids.contains(track.id)).toList(growable: false);

  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async => const [];

  @override
  Future<void> updateMetadata(Track track) async {}

  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class WaveGlobals implements TrackEmbeddingRepository {
  const WaveGlobals(this.values);
  final List<TrackEmbedding> values;

  @override
  Future<List<TrackEmbedding>> getBySpace({
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async => values;

  @override
  Future<TrackEmbedding?> get({
    required String trackId,
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required TrackEmbeddingProvider provider,
    String preprocessingVersion = TrackEmbedding.legacyPreprocessingVersion,
    String? contentRevision,
  }) async => null;

  @override
  Future<List<TrackEmbedding>> getForTrack(String trackId) async => const [];

  @override
  Future<void> deleteForTrack(String trackId) async {}

  @override
  Future<void> save(TrackEmbedding embedding) async {}
}

class WaveTemporals implements TrackTemporalEmbeddingRepository {
  const WaveTemporals(this.values);
  final List<TrackTemporalEmbedding> values;

  @override
  Future<List<TrackTemporalEmbedding>> getBySpace({
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async => values;

  @override
  Future<TrackTemporalEmbedding?> get({
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
    required int audioRevision,
  }) async => null;

  @override
  Future<bool> save(TrackTemporalEmbedding embedding) async => true;
}

class WaveModels implements MusicAnalysisClient {
  const WaveModels({this.global = true, this.temporal = true});
  final bool global;
  final bool temporal;

  @override
  String get baseUrl => 'https://analysis.example';

  @override
  Future<MusicAnalysisModels> getModels() async => MusicAnalysisModels(
    schemaVersion: '1',
    models: [
      if (global)
        MusicAnalysisModel(
          representation: MusicAnalysisRepresentation.audioGlobal,
          modelId: 'global-model',
          modelVersion: '1',
          preprocessingVersion: 'prep',
          dimension: 2,
          normalized: true,
        ),
      if (temporal)
        MusicAnalysisModel(
          representation: MusicAnalysisRepresentation.audioTemporal,
          modelId: 'temporal-model',
          modelVersion: '1',
          preprocessingVersion: 'prep',
          dimension: 2,
          normalized: true,
        ),
    ],
  );

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) => throw UnimplementedError();
}
