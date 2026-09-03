import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/research/lyrics_semantic_research_service.dart';
import 'package:openmusic/layers/domain/entities/lyrics_resolution_state.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_lyrics.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_lyrics_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

void main() {
  test(
    'lyrics cosine excludes missing and stale candidates and reports coverage',
    () async {
      final service = LyricsSemanticResearchService(
        tracks: _Tracks([
          _track('seed'),
          _track('valid'),
          _track('stale'),
          _track('missing'),
        ]),
        lyrics: _Lyrics({
          'seed': _lyrics('seed', _hashA),
          'valid': _lyrics('valid', _hashB),
          'stale': _lyrics('stale', _hashC),
        }),
        embeddings: _Embeddings([
          _embedding('seed', _hashA, const [1, 0]),
          _embedding('valid', _hashB, const [0.8, 0.6]),
          _embedding('stale', _hashD, const [1, 0]),
        ]),
        registry: MusicAnalysisModelRegistry(_ModelsClient()),
      );

      final result = await service.compare(seedTrackId: 'seed');

      expect(result.seedAvailable, isTrue);
      expect(result.coverage.analyzed, 2);
      expect(result.coverage.total, 4);
      expect(result.candidates.map((entry) => entry.trackId), ['valid']);
      expect(result.candidates.single.similarity, closeTo(0.8, 1e-9));
    },
  );

  test('seed without current lyrics embedding is unavailable', () async {
    final service = LyricsSemanticResearchService(
      tracks: _Tracks([_track('seed')]),
      lyrics: _Lyrics({'seed': _lyrics('seed', _hashA)}),
      embeddings: _Embeddings([
        _embedding('seed', _hashB, const [1, 0]),
      ]),
      registry: MusicAnalysisModelRegistry(_ModelsClient()),
    );

    final result = await service.compare(seedTrackId: 'seed');

    expect(result.seedAvailable, isFalse);
    expect(result.coverage.analyzed, 0);
    expect(result.candidates, isEmpty);
  });
}

final _model = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.lyricsGlobal,
  modelId: 'lyrics-model',
  modelVersion: '1',
  preprocessingVersion: 'lyrics-pre',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);

Track _track(String id) => Track(
  id: id,
  title: id,
  artists: const [],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '/$id.mp3',
  audioRevision: 1,
);

TrackLyrics _lyrics(String trackId, String hash) => TrackLyrics(
  trackId: trackId,
  source: LyricsSource.embedded,
  plainText: 'Lyrics for $trackId',
  contentHash: hash,
  fetchedAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

TrackEmbedding _embedding(String trackId, String hash, List<double> vector) =>
    TrackEmbedding(
      trackId: trackId,
      modality: TrackEmbeddingModality.lyrics,
      modelId: _model.modelId,
      modelVersion: _model.modelVersion,
      preprocessingVersion: _model.preprocessingVersion,
      provider: TrackEmbeddingProvider.server,
      contentRevision: hash,
      normalized: true,
      dimensions: vector.length,
      vector: vector,
      createdAt: DateTime.utc(2026),
    );

class _ModelsClient implements MusicAnalysisClient {
  @override
  String get baseUrl => 'https://analysis.test';

  @override
  Future<MusicAnalysisModels> getModels() async =>
      MusicAnalysisModels(schemaVersion: '1', models: [_model]);

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) => throw UnimplementedError();
}

class _Tracks implements TrackRepository {
  const _Tracks(this.values);

  final List<Track> values;

  @override
  Future<List<Track>> getTracks() async => values;

  @override
  Future<Track?> getTrackById(String id) async =>
      values.where((track) => track.id == id).firstOrNull;

  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async =>
      values.where((track) => ids.contains(track.id)).toList();

  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async => values;

  @override
  Future<void> updateMetadata(Track track) async {}

  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _Lyrics implements TrackLyricsRepository {
  _Lyrics(this.values);

  final Map<String, TrackLyrics> values;

  @override
  Future<TrackLyrics?> getForTrack(String trackId) async => values[trackId];

  @override
  Future<void> save(TrackLyrics lyrics) async =>
      values[lyrics.trackId] = lyrics;

  @override
  Future<void> deleteForTrack(String trackId) async => values.remove(trackId);

  @override
  Future<LyricsResolutionState?> getResolutionState(String trackId) async =>
      null;

  @override
  Future<void> saveResolutionState(LyricsResolutionState state) async {}
}

class _Embeddings implements TrackEmbeddingRepository {
  const _Embeddings(this.values);

  final List<TrackEmbedding> values;

  @override
  Future<List<TrackEmbedding>> getBySpace({
    required TrackEmbeddingModality modality,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async => values
      .where(
        (embedding) =>
            embedding.modality == modality &&
            embedding.modelId == modelId &&
            embedding.modelVersion == modelVersion &&
            embedding.preprocessingVersion == preprocessingVersion &&
            embedding.provider == provider,
      )
      .toList();

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
  Future<List<TrackEmbedding>> getForTrack(String trackId) async =>
      values.where((embedding) => embedding.trackId == trackId).toList();

  @override
  Future<void> save(TrackEmbedding embedding) async {}

  @override
  Future<void> deleteForTrack(String trackId) async {}
}

const _hashA =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _hashB =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
const _hashC =
    'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
const _hashD =
    'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd';
