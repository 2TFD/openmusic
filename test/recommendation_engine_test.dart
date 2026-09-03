import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/recommendation/recommendation_config.dart';
import 'package:openmusic/core/services/recommendation/recommendation_engine.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/recommendation.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_lyrics.dart';
import 'package:openmusic/layers/domain/entities/lyrics_resolution_state.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_lyrics_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_temporal_embedding_repository.dart';

void main() {
  test(
    'global retrieval excludes seed, stale revision and incompatible space',
    () async {
      final tracks = [
        _track('seed'),
        _track('same'),
        _track('stale'),
        _track('other'),
      ];
      final engine = _engine(
        tracks: tracks,
        globals: [
          _global('seed', const [1, 0]),
          _global('same', const [1, 0]),
          _global('stale', const [1, 0], revision: 0),
          _global('other', const [1, 0], modelId: 'other-global'),
        ],
        config: const RecommendationConfig(globalCandidatePoolSize: 1),
      );

      final result = await engine.recommend(
        WaveConfig(seeds: const [], tracks: [tracks.first], queueSize: 10),
      );

      expect(result.readiness, RecommendationReadiness.ready);
      expect(result.tracks.map((track) => track.id), ['same']);
      expect(result.diagnostics.candidatePoolSize, 1);
    },
  );

  test(
    'hybrid uses exact weights and temporal DTW reranks the global pool',
    () async {
      final tracks = [
        _track('seed'),
        _track('global-best'),
        _track('temporal-best'),
      ];
      final result =
          await _engine(
            tracks: tracks,
            globals: [
              _global('seed', const [1, 0]),
              _global('global-best', const [1, 0]),
              _global('temporal-best', const [0.8, 0.6]),
            ],
            temporals: [
              _temporal('seed', const [1, 0]),
              _temporal('global-best', const [-1, 0]),
              _temporal('temporal-best', const [1, 0]),
            ],
          ).recommend(
            WaveConfig(seeds: const [], tracks: [tracks.first], queueSize: 10),
          );

      expect(result.tracks.map((track) => track.id), [
        'temporal-best',
        'global-best',
      ]);
      final temporalBest = result.candidates.first;
      expect(temporalBest.globalSimilarity, closeTo(0.8, 1e-9));
      expect(temporalBest.temporalSimilarity, closeTo(1, 1e-9));
      expect(temporalBest.finalScore, closeTo(0.65 * 0.8 + 0.35, 1e-9));
      expect(temporalBest.algorithmVersion, 'audio_temporal_lyrics_hybrid_v1');
    },
  );

  test(
    'candidate without temporal data is scored with global weight 1.0',
    () async {
      final tracks = [_track('seed'), _track('candidate')];
      final result =
          await _engine(
            tracks: tracks,
            globals: [
              _global('seed', const [1, 0]),
              _global('candidate', const [0.6, 0.8]),
            ],
            temporals: [
              _temporal('seed', const [1, 0]),
            ],
          ).recommend(
            WaveConfig(seeds: const [], tracks: [tracks.first], queueSize: 10),
          );

      expect(result.candidates.single.temporalSimilarity, isNull);
      expect(result.candidates.single.globalSimilarity, closeTo(0.6, 1e-9));
      expect(result.candidates.single.finalScore, closeTo(0.6, 1e-9));
    },
  );

  test(
    'multiple seeds use a normalized global mean and per-seed DTW mean',
    () async {
      final tracks = [_track('seed-a'), _track('seed-b'), _track('candidate')];
      final result =
          await _engine(
            tracks: tracks,
            globals: [
              _global('seed-a', const [1, 0]),
              _global('seed-b', const [0, 1]),
              _global('candidate', const [0.7071067812, 0.7071067812]),
            ],
            temporals: [
              _temporal('seed-a', const [1, 0]),
              _temporal('seed-b', const [0, 1]),
              _temporal('candidate', const [1, 0]),
            ],
          ).recommend(
            WaveConfig(
              seeds: const [],
              tracks: tracks.take(2).toList(),
              queueSize: 10,
            ),
          );

      final candidate = result.candidates.single;
      expect(candidate.globalSimilarity, closeTo(1, 1e-9));
      expect(candidate.temporalSimilarity, closeTo(0.75, 1e-9));
      expect(candidate.finalScore, closeTo(0.65 + 0.35 * 0.75, 1e-9));
    },
  );

  test(
    'typed readiness distinguishes missing seed and partial library',
    () async {
      final seed = _track('seed');
      final candidate = _track('candidate');
      final missing = await _engine(
        tracks: [seed, candidate],
      ).recommend(WaveConfig(seeds: const [], tracks: [seed]));
      expect(missing.readiness, RecommendationReadiness.analysisRequired);
      expect(missing.missingSeedTrackIds, ['seed']);

      final partial = await _engine(
        tracks: [seed, candidate, _track('not-analyzed')],
        globals: [
          _global('seed', const [1, 0]),
          _global('candidate', const [0, 1]),
        ],
      ).recommend(WaveConfig(seeds: const [], tracks: [seed]));
      expect(partial.readiness, RecommendationReadiness.ready);
      expect(partial.tracks, [candidate]);

      final noCandidates = await _engine(
        tracks: [seed, candidate],
        globals: [
          _global('seed', const [1, 0]),
        ],
      ).recommend(WaveConfig(seeds: const [], tracks: [seed]));
      expect(
        noCandidates.readiness,
        RecommendationReadiness.insufficientLibrary,
      );
    },
  );

  test(
    'lyrics.global contributes only for current matching lyrics hashes',
    () async {
      final tracks = [
        _track('seed'),
        _track('lyrics-best'),
        _track('audio-best'),
      ];
      const hash =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final result =
          await _engine(
            tracks: tracks,
            globals: [
              _global('seed', const [1, 0]),
              _global('lyrics-best', const [0.9, 0.435889894]),
              _global('audio-best', const [0.8, 0.6]),
              _lyricsEmbedding('seed', const [1, 0], hash),
              _lyricsEmbedding('lyrics-best', const [1, 0], hash),
              _lyricsEmbedding(
                'audio-best',
                const [0, 1],
                'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
              ),
            ],
            lyrics: _Lyrics({
              'seed': _lyrics('seed', hash),
              'lyrics-best': _lyrics('lyrics-best', hash),
              'audio-best': _lyrics('audio-best', hash),
            }),
          ).recommend(
            WaveConfig(seeds: const [], tracks: [tracks.first], queueSize: 10),
          );

      expect(result.candidates.first.track.id, 'lyrics-best');
      expect(result.candidates.first.lyricsSimilarity, closeTo(1, 1e-9));
      expect(result.diagnostics.lyricsCandidateCount, 1);
    },
  );
}

RecommendationEngine _engine({
  required List<Track> tracks,
  List<TrackEmbedding> globals = const [],
  List<TrackTemporalEmbedding> temporals = const [],
  TrackLyricsRepository? lyrics,
  RecommendationConfig config = const RecommendationConfig(),
}) {
  final client = _ModelsClient();
  return RecommendationEngine(
    tracks: _Tracks(tracks),
    globalEmbeddings: _Globals(globals),
    temporalEmbeddings: _Temporals(temporals),
    lyrics: lyrics,
    registry: MusicAnalysisModelRegistry(client),
    config: config,
  );
}

Track _track(String id) => Track(
  id: id,
  title: id,
  artists: const [Artist(id: 'artist', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '/$id.mp3',
  audioRevision: 1,
);

TrackEmbedding _global(
  String trackId,
  List<double> vector, {
  int revision = 1,
  String modelId = 'global-model',
}) => TrackEmbedding(
  trackId: trackId,
  modality: TrackEmbeddingModality.audio,
  modelId: modelId,
  modelVersion: '1',
  preprocessingVersion: 'prep-1',
  provider: TrackEmbeddingProvider.server,
  audioRevision: revision,
  normalized: true,
  dimensions: vector.length,
  vector: vector,
  createdAt: DateTime.utc(2026),
);

TrackEmbedding _lyricsEmbedding(
  String trackId,
  List<double> vector,
  String hash,
) => TrackEmbedding(
  trackId: trackId,
  modality: TrackEmbeddingModality.lyrics,
  modelId: 'lyrics-model',
  modelVersion: '1',
  preprocessingVersion: 'prep-1',
  provider: TrackEmbeddingProvider.server,
  contentRevision: hash,
  normalized: true,
  dimensions: vector.length,
  vector: vector,
  createdAt: DateTime.utc(2026),
);

TrackLyrics _lyrics(String trackId, String hash) => TrackLyrics(
  trackId: trackId,
  source: LyricsSource.lrclib,
  plainText: 'lyrics $trackId',
  contentHash: hash,
  fetchedAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

TrackTemporalEmbedding _temporal(String trackId, List<double> vector) =>
    TrackTemporalEmbedding(
      id: 'temporal-$trackId',
      trackId: trackId,
      representation: 'audio.temporal',
      modelId: 'temporal-model',
      modelVersion: '1',
      preprocessingVersion: 'prep-1',
      provider: TrackEmbeddingProvider.server,
      audioRevision: 1,
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

class _ModelsClient implements MusicAnalysisClient {
  @override
  String get baseUrl => 'https://analysis.example';

  @override
  Future<MusicAnalysisModels> getModels() async => MusicAnalysisModels(
    schemaVersion: '1',
    models: [
      MusicAnalysisModel(
        representation: MusicAnalysisRepresentation.audioGlobal,
        modelId: 'global-model',
        modelVersion: '1',
        preprocessingVersion: 'prep-1',
        dimension: 2,
        dtype: 'float32',
        normalized: true,
      ),
      MusicAnalysisModel(
        representation: MusicAnalysisRepresentation.lyricsGlobal,
        modelId: 'lyrics-model',
        modelVersion: '1',
        preprocessingVersion: 'prep-1',
        dimension: 2,
        dtype: 'float32',
        normalized: true,
      ),
      MusicAnalysisModel(
        representation: MusicAnalysisRepresentation.audioTemporal,
        modelId: 'temporal-model',
        modelVersion: '1',
        preprocessingVersion: 'prep-1',
        dimension: 2,
        dtype: 'float32',
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

class _Globals implements TrackEmbeddingRepository {
  const _Globals(this.values);
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
        (value) =>
            value.modality == modality &&
            value.modelId == modelId &&
            value.modelVersion == modelVersion &&
            value.preprocessingVersion == preprocessingVersion &&
            value.provider == provider,
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
  Future<List<TrackEmbedding>> getForTrack(String trackId) async => const [];
  @override
  Future<void> save(TrackEmbedding embedding) async {}
  @override
  Future<void> deleteForTrack(String trackId) async {}
}

class _Temporals implements TrackTemporalEmbeddingRepository {
  const _Temporals(this.values);
  final List<TrackTemporalEmbedding> values;

  @override
  Future<List<TrackTemporalEmbedding>> getBySpace({
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required TrackEmbeddingProvider provider,
  }) async => values
      .where(
        (value) =>
            value.representation == representation &&
            value.modelId == modelId &&
            value.modelVersion == modelVersion &&
            value.preprocessingVersion == preprocessingVersion &&
            value.provider == provider,
      )
      .toList();
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

class _Lyrics implements TrackLyricsRepository {
  const _Lyrics(this.values);
  final Map<String, TrackLyrics> values;

  @override
  Future<TrackLyrics?> getForTrack(String trackId) async => values[trackId];
  @override
  Future<void> save(TrackLyrics lyrics) async {}
  @override
  Future<void> deleteForTrack(String trackId) async {}
  @override
  Future<LyricsResolutionState?> getResolutionState(String trackId) async =>
      null;
  @override
  Future<void> saveResolutionState(LyricsResolutionState state) async {}
}
