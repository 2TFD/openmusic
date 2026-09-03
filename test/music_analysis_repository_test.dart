import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/music_analysis_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_temporal_embedding_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_failure.dart';
import 'package:openmusic/layers/domain/entities/lyrics_resolution_state.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_lyrics.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_lyrics_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

void main() {
  late AppDatabase database;
  late TrackEmbeddingRepositoryImpl globals;
  late TrackTemporalEmbeddingRepositoryImpl temporals;
  late _TrackRepository tracks;
  late _LyricsRepository lyrics;
  late _Client client;
  late MusicAnalysisModelRegistry registry;
  late MusicAnalysisRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    globals = TrackEmbeddingRepositoryImpl(database);
    temporals = TrackTemporalEmbeddingRepositoryImpl(database);
    tracks = _TrackRepository(_track(revision: 2));
    lyrics = _LyricsRepository(_lyrics(_lyricsHashA, 'First lyrics'));
    client = _Client();
    registry = MusicAnalysisModelRegistry(client);
    repository = MusicAnalysisRepositoryImpl(
      tracks: tracks,
      globalEmbeddings: globals,
      temporalEmbeddings: temporals,
      lyrics: lyrics,
      client: client,
      registry: registry,
    );
    await database.customStatement('''
INSERT INTO track_table (
  id, title, path_to_file, source_type, source_uri, audio_revision
) VALUES ('track-1', 'Track', 'track.mp3', 'soundcloud', 'https://sc/1', 2)
''');
  });

  tearDown(() => database.close());

  test('cache hit for current model and audioRevision skips server', () async {
    await globals.save(_global(revision: 2));
    await temporals.save(_temporal(revision: 2));

    final disposition = await repository.analyzeTrack(
      trackId: 'track-1',
      audioRevision: 2,
      representations: const {
        MusicAnalysisRepresentation.audioGlobal,
        MusicAnalysisRepresentation.audioTemporal,
      },
    );

    expect(disposition, MusicAnalysisDisposition.cached);
    expect(client.analyzeCalls, 0);
  });

  test(
    'stale audioRevision triggers analysis and saves requested data',
    () async {
      await globals.save(_global(revision: 1));
      await temporals.save(_temporal(revision: 1));

      final disposition = await repository.analyzeTrack(
        trackId: 'track-1',
        audioRevision: 2,
        representations: const {
          MusicAnalysisRepresentation.audioGlobal,
          MusicAnalysisRepresentation.audioTemporal,
        },
      );

      expect(disposition, MusicAnalysisDisposition.analyzed);
      expect(client.analyzeCalls, 1);
      expect(
        client.lastRequested,
        containsAll([
          MusicAnalysisRepresentation.audioGlobal,
          MusicAnalysisRepresentation.audioTemporal,
        ]),
      );
      final global = await globals.get(
        trackId: 'track-1',
        modality: TrackEmbeddingModality.audio,
        modelId: 'clap',
        modelVersion: 'checkpoint',
        preprocessingVersion: 'global-pre',
        provider: TrackEmbeddingProvider.server,
      );
      final temporal = await temporals.get(
        trackId: 'track-1',
        representation: 'audio.temporal',
        modelId: 'clap',
        modelVersion: 'checkpoint',
        preprocessingVersion: 'temporal-pre',
        provider: TrackEmbeddingProvider.server,
        audioRevision: 2,
      );
      expect(global?.audioRevision, 2);
      expect(global?.preprocessingVersion, 'global-pre');
      expect(temporal?.segments, hasLength(2));
    },
  );

  test(
    'lyrics.global is sent and saved with lyrics content revision',
    () async {
      final disposition = await repository.analyzeTrack(
        trackId: 'track-1',
        audioRevision: 2,
        representations: const {MusicAnalysisRepresentation.lyricsGlobal},
      );

      expect(disposition, MusicAnalysisDisposition.analyzed);
      expect(client.lastLyrics, 'First lyrics');
      expect(client.lastRequested, {MusicAnalysisRepresentation.lyricsGlobal});
      final stored = await globals.get(
        trackId: 'track-1',
        modality: TrackEmbeddingModality.lyrics,
        modelId: _lyricsModel.modelId,
        modelVersion: _lyricsModel.modelVersion,
        preprocessingVersion: _lyricsModel.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
        contentRevision: _lyricsHashA,
      );
      expect(stored?.audioRevision, isNull);
      expect(stored?.contentRevision, _lyricsHashA);
      expect(stored?.vector, [0, 1]);
    },
  );

  test('same lyrics hash is cached across audio revision changes', () async {
    await repository.analyzeTrack(
      trackId: 'track-1',
      audioRevision: 2,
      representations: const {MusicAnalysisRepresentation.lyricsGlobal},
    );
    tracks.track = _track(revision: 3);

    final disposition = await repository.analyzeTrack(
      trackId: 'track-1',
      audioRevision: 2,
      representations: const {MusicAnalysisRepresentation.lyricsGlobal},
    );

    expect(disposition, MusicAnalysisDisposition.cached);
    expect(client.analyzeCalls, 1);
  });

  test('lyrics hash and backend model changes regenerate embedding', () async {
    await repository.analyzeTrack(
      trackId: 'track-1',
      audioRevision: 2,
      representations: const {MusicAnalysisRepresentation.lyricsGlobal},
    );
    lyrics.value = _lyrics(_lyricsHashB, 'Second lyrics');
    await repository.analyzeTrack(
      trackId: 'track-1',
      audioRevision: 2,
      representations: const {MusicAnalysisRepresentation.lyricsGlobal},
    );
    expect(client.analyzeCalls, 2);

    client.lyricsModel = _lyricsModelV2;
    await registry.getModels(refresh: true);
    await repository.analyzeTrack(
      trackId: 'track-1',
      audioRevision: 2,
      representations: const {MusicAnalysisRepresentation.lyricsGlobal},
    );
    expect(client.analyzeCalls, 3);
    expect(
      await globals.get(
        trackId: 'track-1',
        modality: TrackEmbeddingModality.lyrics,
        modelId: _lyricsModelV2.modelId,
        modelVersion: _lyricsModelV2.modelVersion,
        preprocessingVersion: _lyricsModelV2.preprocessingVersion,
        provider: TrackEmbeddingProvider.server,
        contentRevision: _lyricsHashB,
      ),
      isNotNull,
    );
  });

  test('lyrics changed during request rejects stale response', () async {
    client.beforeResponse = () async {
      lyrics.value = _lyrics(_lyricsHashB, 'Second lyrics');
    };

    await expectLater(
      repository.analyzeTrack(
        trackId: 'track-1',
        audioRevision: 2,
        representations: const {MusicAnalysisRepresentation.lyricsGlobal},
      ),
      throwsA(
        isA<MusicAnalysisFailure>().having(
          (failure) => failure.kind,
          'kind',
          MusicAnalysisFailureKind.staleContent,
        ),
      ),
    );
    expect(await globals.getForTrack('track-1'), isEmpty);
  });
}

final _globalModel = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioGlobal,
  modelId: 'clap',
  modelVersion: 'checkpoint',
  preprocessingVersion: 'global-pre',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);

final _temporalModel = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.audioTemporal,
  modelId: 'clap',
  modelVersion: 'checkpoint',
  preprocessingVersion: 'temporal-pre',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);

final _lyricsModel = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.lyricsGlobal,
  modelId: 'lyrics-model',
  modelVersion: 'lyrics-checkpoint',
  preprocessingVersion: 'lyrics-pre',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);

final _lyricsModelV2 = MusicAnalysisModel(
  representation: MusicAnalysisRepresentation.lyricsGlobal,
  modelId: 'lyrics-model',
  modelVersion: 'lyrics-checkpoint-v2',
  preprocessingVersion: 'lyrics-pre-v2',
  dimension: 2,
  dtype: 'float32',
  normalized: true,
);

TrackEmbedding _global({required int revision}) => TrackEmbedding(
  trackId: 'track-1',
  modality: TrackEmbeddingModality.audio,
  modelId: _globalModel.modelId,
  modelVersion: _globalModel.modelVersion,
  preprocessingVersion: _globalModel.preprocessingVersion,
  provider: TrackEmbeddingProvider.server,
  audioRevision: revision,
  dtype: 'float32',
  normalized: true,
  dimensions: 2,
  vector: const [1, 0],
  createdAt: DateTime.utc(2026),
);

TrackTemporalEmbedding _temporal({required int revision}) =>
    TrackTemporalEmbedding(
      id: 'temporal-$revision',
      trackId: 'track-1',
      representation: 'audio.temporal',
      modelId: _temporalModel.modelId,
      modelVersion: _temporalModel.modelVersion,
      preprocessingVersion: _temporalModel.preprocessingVersion,
      provider: TrackEmbeddingProvider.server,
      audioRevision: revision,
      dimension: 2,
      dtype: 'float32',
      normalized: true,
      createdAt: DateTime.utc(2026),
      summary: const TemporalAnalysisSummary(
        numberOfSegments: 2,
        meanAdjacentDistance: 0.5,
        maxAdjacentDistance: 0.5,
        trajectoryVariance: 0.25,
        largestTransitionIndex: 0,
      ),
      segments: [
        TemporalAnalysisSegment(
          index: 0,
          startMs: 0,
          endMs: 1000,
          dimensions: 2,
          vector: const [1, 0],
        ),
        TemporalAnalysisSegment(
          index: 1,
          startMs: 1000,
          endMs: 2000,
          dimensions: 2,
          vector: const [0, 1],
        ),
      ],
    );

Track _track({required int revision}) => Track(
  id: 'track-1',
  contentIdentity: 'soundcloud:1',
  title: 'Track',
  artists: const [],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.soundcloud,
    originalUrl: 'https://sc/1',
  ),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
  audioRevision: revision,
);

class _Client implements MusicAnalysisClient {
  int analyzeCalls = 0;
  Set<MusicAnalysisRepresentation> lastRequested = const {};
  String? lastLyrics;
  MusicAnalysisModel lyricsModel = _lyricsModel;
  Future<void> Function()? beforeResponse;

  @override
  String get baseUrl => 'https://analysis.test';

  @override
  Future<MusicAnalysisModels> getModels() async => MusicAnalysisModels(
    schemaVersion: '1',
    models: [_globalModel, _temporalModel, lyricsModel],
  );

  @override
  Future<MusicAnalysisResponse> analyze({
    required String trackId,
    required String filePath,
    String? contentIdentity,
    String? lyrics,
    required Set<MusicAnalysisRepresentation> requestedRepresentations,
  }) async {
    analyzeCalls++;
    lastRequested = requestedRepresentations;
    lastLyrics = lyrics;
    await beforeResponse?.call();
    return MusicAnalysisResponse(
      schemaVersion: '1',
      trackId: trackId,
      contentIdentity: contentIdentity,
      audioGlobal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.audioGlobal,
          )
          ? GlobalAnalysisRepresentation(
              metadata: _globalModel,
              vector: const [1, 0],
            )
          : null,
      audioTemporal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.audioTemporal,
          )
          ? TemporalAnalysisRepresentation(
              metadata: _temporalModel,
              segments: _temporal(revision: 2).segments,
              summary: _temporal(revision: 2).summary,
            )
          : null,
      lyricsGlobal:
          requestedRepresentations.contains(
            MusicAnalysisRepresentation.lyricsGlobal,
          )
          ? GlobalAnalysisRepresentation(
              metadata: lyricsModel,
              vector: const [0, 1],
            )
          : null,
    );
  }
}

class _TrackRepository implements TrackRepository {
  _TrackRepository(this.track);
  Track track;

  @override
  Future<Track?> getTrackById(String id) async => id == track.id ? track : null;
  @override
  Future<List<Track>> getTracks() async => [track];
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async =>
      ids.contains(track.id) ? [track] : [];
  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async => [track];
  @override
  Future<void> updateMetadata(Track track) async {}
  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _LyricsRepository implements TrackLyricsRepository {
  _LyricsRepository(this.value);

  TrackLyrics? value;

  @override
  Future<TrackLyrics?> getForTrack(String trackId) async =>
      value?.trackId == trackId ? value : null;

  @override
  Future<void> save(TrackLyrics lyrics) async => value = lyrics;

  @override
  Future<void> deleteForTrack(String trackId) async {
    if (value?.trackId == trackId) value = null;
  }

  @override
  Future<LyricsResolutionState?> getResolutionState(String trackId) async =>
      null;

  @override
  Future<void> saveResolutionState(LyricsResolutionState state) async {}
}

TrackLyrics _lyrics(String hash, String text) => TrackLyrics(
  trackId: 'track-1',
  source: LyricsSource.embedded,
  plainText: text,
  contentHash: hash,
  fetchedAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

const _lyricsHashA =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _lyricsHashB =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
