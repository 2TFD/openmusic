import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/recommendation/track_wave_config.dart';
import 'package:openmusic/core/services/recommendation/track_wave_engine.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/entities/wave_session.dart';

import 'support/wave_engine_fakes.dart';

void main() {
  test('uses the selected track as the stable audio seed', () async {
    final batch = await _engine(
      tracks: [waveTrack('seed'), waveTrack('same'), waveTrack('far')],
      globals: [
        waveGlobal('seed', const [1, 0]),
        waveGlobal('same', const [1, 0]),
        waveGlobal('far', const [0, 1]),
      ],
    ).generate(session: _session());

    expect(batch.tracks.map((track) => track.id), ['same', 'far']);
    expect(batch.candidates.first.globalSimilarity, 1);
  });

  test('global retrieval is followed by temporal DTW reranking', () async {
    final batch = await _engine(
      tracks: [waveTrack('seed'), waveTrack('a'), waveTrack('b')],
      globals: [
        waveGlobal('seed', const [1, 0]),
        waveGlobal('a', const [1, 0]),
        waveGlobal('b', const [1, 0]),
      ],
      temporals: [
        waveTemporal('seed', const [1, 0]),
        waveTemporal('a', const [-1, 0]),
        waveTemporal('b', const [1, 0]),
      ],
    ).generate(session: _session());

    expect(batch.tracks.map((track) => track.id), ['b', 'a']);
    expect(batch.candidates.first.temporalSimilarity, 1);
    expect(batch.candidates.last.temporalSimilarity, closeTo(1 / 3, 1e-12));
  });

  test('missing temporal renormalizes to global only', () async {
    final batch = await _engine(
      tracks: [waveTrack('seed'), waveTrack('candidate')],
      globals: [
        waveGlobal('seed', const [1, 0]),
        waveGlobal('candidate', const [0, 1]),
      ],
      models: const WaveModels(temporal: false),
    ).generate(session: _session());

    final candidate = batch.candidates.single;
    expect(candidate.temporalSimilarity, isNull);
    expect(candidate.availableWeight, 0.65);
    expect(candidate.finalScore, candidate.globalSimilarity);
  });

  test(
    'recent context influences ranking without dropping the seed anchor',
    () async {
      final engine = _engine(
        tracks: [
          waveTrack('seed'),
          waveTrack('recent'),
          waveTrack('seed-like'),
          waveTrack('balanced'),
        ],
        globals: [
          waveGlobal('seed', const [1, 0]),
          waveGlobal('recent', const [0, 1]),
          waveGlobal('seed-like', const [1, 0]),
          waveGlobal('balanced', const [0.7, 0.7]),
        ],
        config: const TrackWaveConfig(batchSize: 2),
      );
      final before = await engine.generate(session: _session());
      final after = await engine.generate(
        session: _session().recordPlayed('recent'),
      );

      expect(before.tracks.first.id, 'seed-like');
      expect(after.tracks.first.id, 'balanced');
      expect(after.tracks.map((track) => track.id), isNot(contains('recent')));
    },
  );

  test(
    'recent/queued/current exclusions and successive batches stay unique',
    () async {
      final tracks = [for (var i = 0; i < 7; i++) waveTrack('t$i')];
      final globals = [
        waveGlobal('seed', const [1, 0]),
        for (var i = 0; i < 7; i++) waveGlobal('t$i', const [1, 0]),
      ];
      final engine = _engine(
        tracks: [waveTrack('seed'), ...tracks],
        globals: globals,
        config: const TrackWaveConfig(batchSize: 2),
      );
      final first = await engine.generate(
        session: _session().recordPlayed('t0'),
        currentTrackId: 't1',
        queuedTrackIds: const {'t2'},
      );
      final second = await engine.generate(session: first.session);

      expect(first.tracks.map((track) => track.id), ['t3', 't4']);
      expect(second.tracks.map((track) => track.id), ['t1', 't2']);
      expect(
        first.tracks
            .map((track) => track.id)
            .toSet()
            .intersection(second.tracks.map((track) => track.id).toSet()),
        isEmpty,
      );
    },
  );

  test('missing compatible seed produces a graceful empty batch', () async {
    final batch = await _engine(
      tracks: [waveTrack('seed'), waveTrack('candidate')],
      globals: [
        waveGlobal('candidate', const [1, 0]),
      ],
    ).generate(session: _session());

    expect(batch.isEmpty, isTrue);
    expect(batch.session.generationCount, 0);
  });
}

TrackWaveEngine _engine({
  required List<Track> tracks,
  required List<TrackEmbedding> globals,
  List<TrackTemporalEmbedding> temporals = const [],
  WaveModels models = const WaveModels(),
  TrackWaveConfig config = const TrackWaveConfig(),
}) => TrackWaveEngine(
  tracks: WaveTracks(tracks),
  globalEmbeddings: WaveGlobals(globals),
  temporalEmbeddings: WaveTemporals(temporals),
  registry: MusicAnalysisModelRegistry(models),
  config: config,
);

WaveSession _session() => WaveSession.startTrack(
  trackId: 'seed',
  trackTitle: 'Seed',
  seedAudioRevision: 1,
  startedAt: DateTime.utc(2026),
);
