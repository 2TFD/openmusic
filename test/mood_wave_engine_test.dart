import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/recommendation/mood_wave_config.dart';
import 'package:openmusic/core/services/recommendation/mood_wave_engine.dart';
import 'package:openmusic/layers/domain/entities/mood_map.dart';
import 'package:openmusic/layers/domain/entities/mood_wave.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/repositories/mood_map_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_client.dart';
import 'package:openmusic/layers/domain/repositories/track_embedding_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_temporal_embedding_repository.dart';

void main() {
  group('normalization and scoring', () {
    test('mood distance and proximity have explicit [0, 1] normalization', () {
      final distance = MoodWaveEngine.moodDistance(
        trackValence: 1,
        trackArousal: 1,
        targetValence: -1,
        targetArousal: -1,
      );

      expect(distance, closeTo(2.8284271247461903, 1e-12));
      expect(MoodWaveEngine.normalizeMoodProximity(0), 1);
      expect(
        MoodWaveEngine.normalizeMoodProximity(distance),
        closeTo(0, 1e-12),
      );
      expect(MoodWaveEngine.normalizeCosine(-1), 0);
      expect(MoodWaveEngine.normalizeCosine(0), 0.5);
      expect(MoodWaveEngine.normalizeCosine(1), 1);
    });

    test('missing signals renormalize only the available weights', () {
      final moodOnly = MoodWaveEngine.weightedScore(
        moodProximity: 0.4,
        globalSimilarity: null,
        temporalSimilarity: null,
      );
      final withoutTemporal = MoodWaveEngine.weightedScore(
        moodProximity: 0.4,
        globalSimilarity: 1,
        temporalSimilarity: null,
      );
      final all = MoodWaveEngine.weightedScore(
        moodProximity: 0.4,
        globalSimilarity: 1,
        temporalSimilarity: 0.5,
      );

      expect(moodOnly.availableWeight, 0.5);
      expect(moodOnly.score, 0.4);
      expect(withoutTemporal.availableWeight, closeTo(0.8, 1e-12));
      expect(withoutTemporal.score, closeTo((0.5 * 0.4 + 0.3) / 0.8, 1e-12));
      expect(all.availableWeight, 1);
      expect(all.score, closeTo(0.5 * 0.4 + 0.3 + 0.2 * 0.5, 1e-12));
    });
  });

  group('effective target', () {
    final session = MoodWaveSession.start(
      targetValence: 0.2,
      targetArousal: 0.2,
      radius: 0.2,
      mode: MoodWaveMode.stay,
      startedAt: DateTime.utc(2026),
    );
    final recent = MoodPoint(valence: 0.8, arousal: -0.8);
    const config = MoodWaveConfig();

    test('Stay uses 85 percent user target and 15 percent recent mood', () {
      final target = MoodWaveEngine.effectiveTargetFor(
        session: session,
        recentMood: recent,
        config: config,
      );

      expect(target.valence, closeTo(0.29, 1e-12));
      expect(target.arousal, closeTo(0.05, 1e-12));
      expect(
        MoodWaveEngine.effectiveTargetFor(
          session: session,
          recentMood: null,
          config: config,
        ),
        session.userTarget,
      );
    });

    test('Explore follows recent mood more than Stay', () {
      final explore = MoodWaveEngine.effectiveTargetFor(
        session: session.copyWith(mode: MoodWaveMode.explore),
        recentMood: recent,
        config: config,
      );
      final stay = MoodWaveEngine.effectiveTargetFor(
        session: session,
        recentMood: recent,
        config: config,
      );

      expect(explore.valence, closeTo(0.41, 1e-12));
      expect(explore.arousal, closeTo(-0.15, 1e-12));
      expect(
        (explore.valence - recent.valence).abs(),
        lessThan((stay.valence - recent.valence).abs()),
      );
    });

    test('Lift advances incrementally and clamps both coordinates', () {
      final lift = session.copyWith(mode: MoodWaveMode.lift);
      final first = MoodWaveEngine.effectiveTargetFor(
        session: lift,
        recentMood: recent,
        config: config,
      );
      final nextSession = lift.withGeneratedTracks(const [
        'generated',
      ], effectiveTarget: first);
      final second = MoodWaveEngine.effectiveTargetFor(
        session: nextSession,
        recentMood: recent,
        config: config,
      );

      expect(first.valence, closeTo(0.37, 1e-12));
      expect(first.arousal, closeTo(0.08, 1e-12));
      expect(second.valence, closeTo(0.45, 1e-12));
      expect(second.arousal, closeTo(0.11, 1e-12));

      final edge = MoodWaveSession.start(
        targetValence: 0.99,
        targetArousal: 0.99,
        radius: 0.2,
        mode: MoodWaveMode.lift,
      );
      final clamped = MoodWaveEngine.effectiveTargetFor(
        session: edge,
        recentMood: null,
        config: config,
      );
      expect(clamped, MoodPoint(valence: 1, arousal: 1));
    });

    test('Calm lowers arousal incrementally while preserving valence', () {
      final calm = session.copyWith(mode: MoodWaveMode.calm);
      final first = MoodWaveEngine.effectiveTargetFor(
        session: calm,
        recentMood: recent,
        config: config,
      );
      final second = MoodWaveEngine.effectiveTargetFor(
        session: calm.withGeneratedTracks(const [
          'generated',
        ], effectiveTarget: first),
        recentMood: recent,
        config: config,
      );

      expect(first.valence, closeTo(0.29, 1e-12));
      expect(first.arousal, closeTo(-0.03, 1e-12));
      expect(second.valence, closeTo(0.29, 1e-12));
      expect(second.arousal, closeTo(-0.11, 1e-12));
    });
  });

  test(
    'session keeps actual recent plays and skips out of positive profile',
    () {
      var session = MoodWaveSession.start(
        targetValence: 0,
        targetArousal: 0,
        radius: 0.2,
        mode: MoodWaveMode.stay,
        seedTrackId: 'seed',
      );
      session = session.recordPlayed('one', contextSize: 2, cooldownSize: 4);
      session = session.recordPlayed(
        'two',
        skipped: true,
        contextSize: 2,
        cooldownSize: 4,
      );
      session = session.recordPlayed('three', contextSize: 2, cooldownSize: 4);

      expect(session.recentTrackIds, ['one', 'two', 'three']);
      expect(session.profileTrackIds, ['one', 'three']);
      expect(session.seedTrackId, 'seed');
    },
  );

  group('candidate pool', () {
    test(
      'radius filters and personal position has priority over model mood',
      () async {
        final personal = _mood(
          'personal',
          modelValence: 0.9,
          personalValence: 0.02,
        );
        final engine = _engine(
          moods: [
            personal,
            _mood('outside', modelValence: 0.2),
            _mood('unplayable', modelValence: 0.01, playable: false),
            _mood('unavailable', modelValence: 0.01, available: false),
          ],
          config: const MoodWaveConfig(batchSize: 5, maxRadiusExpansion: 0),
        );

        final batch = await engine.generate(session: _session(radius: 0.1));

        expect(batch.tracks.map((track) => track.id), ['personal']);
        expect(batch.candidates.single.position.valence, 0.02);
        expect(batch.candidates.single.withinRequestedRadius, isTrue);
        expect(batch.eligibleTrackCount, 1);
      },
    );

    test(
      'radius expands stepwise only until the batch can be filled',
      () async {
        final engine = _engine(
          moods: [
            _mood('inside', modelValence: 0.05),
            _mood('near', modelValence: 0.18),
            _mood('expanded', modelValence: 0.29),
            _mood('too-far', modelValence: 0.45),
          ],
          config: const MoodWaveConfig(
            batchSize: 3,
            radiusExpansionStep: 0.1,
            maxRadiusExpansion: 0.3,
          ),
        );

        final batch = await engine.generate(session: _session(radius: 0.1));

        expect(batch.tracks.map((track) => track.id), [
          'inside',
          'near',
          'expanded',
        ]);
        expect(batch.effectiveRadius, closeTo(0.3, 1e-12));
        expect(batch.eligibleTrackCount, 1);
      },
    );

    test('current, recent, queued and generated tracks are excluded', () async {
      final moods = [for (var i = 0; i < 6; i++) _mood('t$i')];
      final base = _session(radius: 0.5).recordPlayed('t1').withGeneratedTracks(
        const ['t2'],
        effectiveTarget: MoodPoint(valence: 0, arousal: 0),
      );
      final batch =
          await _engine(
            moods: moods,
            config: const MoodWaveConfig(batchSize: 10, maxRadiusExpansion: 0),
          ).generate(
            session: base,
            currentTrackId: 't0',
            queuedTrackIds: const {'t3'},
          );

      expect(batch.tracks.map((track) => track.id).toSet(), {'t4', 't5'});
    });

    test('successive batches are unique inside the current cycle', () async {
      final engine = _engine(
        moods: [for (var i = 0; i < 5; i++) _mood('t$i')],
        config: const MoodWaveConfig(batchSize: 2, maxRadiusExpansion: 0),
      );
      final first = await engine.generate(session: _session(radius: 0.5));
      final second = await engine.generate(session: first.session);

      expect(first.tracks, hasLength(2));
      expect(second.tracks, hasLength(2));
      expect(
        first.tracks
            .map((track) => track.id)
            .toSet()
            .intersection(second.tracks.map((track) => track.id).toSet()),
        isEmpty,
      );
      expect(second.session.cycleTrackIds, hasLength(4));
      expect(second.session.beginNewCycle().cycleTrackIds, isEmpty);
    });

    test(
      'zero candidates returns an empty stable batch instead of failing',
      () async {
        final session = _session(radius: 0.1);
        final batch = await _engine(
          moods: [_mood('outside', modelValence: 1)],
          config: const MoodWaveConfig(maxRadiusExpansion: 0),
        ).generate(session: session);

        expect(batch.isEmpty, isTrue);
        expect(batch.session.generationCount, 0);
        expect(batch.session.cycleTrackIds, isEmpty);
      },
    );
  });

  group('audio profile and fallback', () {
    test(
      'seed global cosine and DTW both contribute using normalized spaces',
      () async {
        final engine = _engine(
          // The playing seed can lack emotion analysis; only candidates require
          // a valid mood position.
          moods: [_mood('same'), _mood('opposite')],
          globals: [
            _global('seed', const [1, 0]),
            _global('same', const [1, 0]),
            _global('opposite', const [-1, 0]),
          ],
          temporals: [
            _temporal('seed', const [1, 0]),
            _temporal('same', const [1, 0]),
            _temporal('opposite', const [-1, 0]),
          ],
          config: const MoodWaveConfig(batchSize: 2, maxRadiusExpansion: 0),
        );
        final batch = await engine.generate(
          session: _session(
            radius: 0.5,
            seedTrackId: 'seed',
            seedAudioRevision: 1,
          ),
          currentTrackId: 'seed',
        );

        expect(batch.tracks.map((track) => track.id), ['same', 'opposite']);
        expect(
          batch.candidates.first.globalCosineSimilarity,
          closeTo(1, 1e-12),
        );
        expect(batch.candidates.first.globalSimilarity, 1);
        expect(batch.candidates.first.temporalSimilarity, 1);
        expect(batch.candidates.last.globalSimilarity, 0);
        expect(batch.candidates.last.temporalSimilarity, closeTo(1 / 3, 1e-12));
      },
    );

    test(
      'recent positive plays replace the initial seed audio profile',
      () async {
        final engine = _engine(
          moods: [_mood('seed'), _mood('played'), _mood('a'), _mood('b')],
          globals: [
            _global('seed', const [1, 0]),
            _global('played', const [0, 1]),
            _global('a', const [1, 0]),
            _global('b', const [0, 1]),
          ],
          config: const MoodWaveConfig(batchSize: 2, maxRadiusExpansion: 0),
        );
        final session = _session(
          radius: 0.5,
          seedTrackId: 'seed',
        ).recordPlayed('played');
        final batch = await engine.generate(session: session);

        expect(batch.tracks.map((track) => track.id), ['b', 'a']);
      },
    );

    test(
      'missing global and temporal models falls back to mood only',
      () async {
        final batch = await _engine(
          moods: [_mood('candidate', modelValence: 0.1)],
          models: const _ModelsClient(global: false, temporal: false),
        ).generate(session: _session(radius: 0.2));

        final candidate = batch.candidates.single;
        expect(candidate.globalSimilarity, isNull);
        expect(candidate.temporalSimilarity, isNull);
        expect(candidate.availableWeight, 0.5);
        expect(candidate.finalScore, candidate.moodProximity);
      },
    );

    test(
      'candidate with missing audio signals is renormalized independently',
      () async {
        final batch = await _engine(
          moods: [_mood('seed'), _mood('with-global'), _mood('mood-only')],
          globals: [
            _global('seed', const [1, 0]),
            _global('with-global', const [1, 0]),
          ],
          config: const MoodWaveConfig(batchSize: 2, maxRadiusExpansion: 0),
        ).generate(session: _session(radius: 0.5, seedTrackId: 'seed'));

        final byId = {
          for (final candidate in batch.candidates)
            candidate.track.id: candidate,
        };
        expect(byId['with-global']!.availableWeight, 0.8);
        expect(byId['mood-only']!.availableWeight, 0.5);
        expect(byId['mood-only']!.finalScore, byId['mood-only']!.moodProximity);
      },
    );
  });
}

MoodWaveSession _session({
  double radius = 0.2,
  String? seedTrackId,
  int? seedAudioRevision,
}) => MoodWaveSession.start(
  targetValence: 0,
  targetArousal: 0,
  radius: radius,
  mode: MoodWaveMode.stay,
  seedTrackId: seedTrackId,
  seedAudioRevision: seedAudioRevision,
  startedAt: DateTime.utc(2026),
);

MoodWaveEngine _engine({
  required List<MoodMapTrack> moods,
  List<TrackEmbedding> globals = const [],
  List<TrackTemporalEmbedding> temporals = const [],
  MusicAnalysisClient models = const _ModelsClient(),
  MoodWaveConfig config = const MoodWaveConfig(),
}) => MoodWaveEngine(
  moods: _Moods(moods),
  globalEmbeddings: _Globals(globals),
  temporalEmbeddings: _Temporals(temporals),
  registry: MusicAnalysisModelRegistry(models),
  config: config,
);

MoodMapTrack _mood(
  String id, {
  double modelValence = 0,
  double modelArousal = 0,
  double? personalValence,
  double? personalArousal,
  bool playable = true,
  bool available = true,
}) {
  final track = Track(
    id: id,
    title: id,
    artists: const [],
    duration: const Duration(minutes: 3),
    source: Source(
      type: SourceType.localFile,
      originalUrl: '/$id.mp3',
      isAvailable: available,
    ),
    addedAt: DateTime.utc(2026),
    filePath: playable ? '/$id.mp3' : null,
    audioRevision: 1,
  );
  return MoodMapTrack(
    track: track,
    modelAnalysis: TrackEmotionAnalysis(
      id: 'emotion-$id',
      trackId: id,
      representation: MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
      modelId: 'emotion-model',
      modelVersion: '1',
      preprocessingVersion: 'prep',
      contentRevision: 'audio:1',
      audioRevision: 1,
      valence: modelValence,
      arousal: modelArousal,
      moodDistribution: MoodDistribution(const {'neutral': 1}),
      analyzedAt: DateTime.utc(2026),
    ),
    personalAdjustment: personalValence == null
        ? null
        : PersonalMoodAdjustment(
            trackId: id,
            valence: personalValence,
            arousal: personalArousal ?? modelArousal,
            updatedAt: DateTime.utc(2026),
          ),
  );
}

TrackEmbedding _global(String id, List<double> vector) => TrackEmbedding(
  trackId: id,
  modality: TrackEmbeddingModality.audio,
  modelId: 'global-model',
  modelVersion: '1',
  preprocessingVersion: 'prep',
  provider: TrackEmbeddingProvider.server,
  audioRevision: 1,
  normalized: true,
  dimensions: vector.length,
  vector: vector,
  createdAt: DateTime.utc(2026),
);

TrackTemporalEmbedding _temporal(String id, List<double> vector) =>
    TrackTemporalEmbedding(
      id: 'temporal-$id',
      trackId: id,
      representation: MusicAnalysisRepresentation.audioTemporal.apiName,
      modelId: 'temporal-model',
      modelVersion: '1',
      preprocessingVersion: 'prep',
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

class _Moods implements MoodMapRepository {
  const _Moods(this.values);
  final List<MoodMapTrack> values;

  @override
  Future<List<MoodMapTrack>> loadTracks() async => values;
  @override
  Future<void> resetPersonalPosition(String trackId) async {}
  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {}
  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _ModelsClient implements MusicAnalysisClient {
  const _ModelsClient({this.global = true, this.temporal = true});
  final bool global;
  final bool temporal;

  @override
  String get baseUrl => 'https://analysis.example';

  @override
  Future<MusicAnalysisModels> getModels() async => MusicAnalysisModels(
    schemaVersion: '1',
    models: [
      MusicAnalysisModel(
        representation: MusicAnalysisRepresentation.audioEmotionGlobal,
        modelId: 'emotion-model',
        modelVersion: '1',
        preprocessingVersion: 'prep',
      ),
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
