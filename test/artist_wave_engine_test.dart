import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:openmusic/core/services/recommendation/artist_wave_config.dart';
import 'package:openmusic/core/services/recommendation/artist_wave_engine.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_embedding.dart';
import 'package:openmusic/layers/domain/entities/track_temporal_embedding.dart';
import 'package:openmusic/layers/domain/entities/wave_session.dart';

import 'support/wave_engine_fakes.dart';

void main() {
  test('global profile is the normalized centroid of artist tracks', () async {
    final batch = await _engine(
      tracks: [
        waveTrack('seed-a', artistId: 'artist', album: 'A'),
        waveTrack('seed-b', artistId: 'artist', album: 'B'),
        waveTrack('balanced'),
        waveTrack('one-sided'),
      ],
      globals: [
        waveGlobal('seed-a', const [1, 0]),
        waveGlobal('seed-b', const [0, 1]),
        waveGlobal('balanced', const [0.7, 0.7]),
        waveGlobal('one-sided', const [1, 0]),
      ],
    ).generate(session: _session());

    expect(batch.tracks.first.id, 'balanced');
    expect(batch.candidates.first.globalSimilarity, closeTo(1, 1e-12));
  });

  test('incompatible current-model embeddings are ignored', () async {
    final batch = await _engine(
      tracks: [
        waveTrack('wrong', artistId: 'artist'),
        waveTrack('valid', artistId: 'artist'),
        waveTrack('candidate'),
      ],
      globals: [
        waveGlobal('wrong', const [1, 0], modelVersion: 'legacy'),
        waveGlobal('valid', const [1, 0]),
        waveGlobal('candidate', const [1, 0]),
      ],
    ).generate(session: _session());

    final source = batch.session.source as ArtistWaveSource;
    expect(source.representativeTrackIds, ['valid']);
    expect(batch.tracks.single.id, 'candidate');
  });

  test('representative limit is deterministic and covers releases first', () {
    final tracks = [
      waveTrack('a2', artistId: 'artist', album: 'A'),
      waveTrack('c1', artistId: 'artist', album: 'C'),
      waveTrack('a1', artistId: 'artist', album: 'A'),
      waveTrack('b1', artistId: 'artist', album: 'B'),
    ];

    final ids = ArtistWaveEngine.selectRepresentativeTrackIds(
      artistTracks: tracks,
      compatibleTrackIds: tracks.map((track) => track.id).toSet(),
      limit: 3,
    );

    expect(ids, ['a1', 'b1', 'c1']);
  });

  test(
    'temporal similarity aggregates each representative DTW score',
    () async {
      final batch = await _engine(
        tracks: [
          waveTrack('seed-a', artistId: 'artist', album: 'A'),
          waveTrack('seed-b', artistId: 'artist', album: 'B'),
          waveTrack('match-one'),
          waveTrack('orthogonal'),
        ],
        globals: [
          waveGlobal('seed-a', const [1, 0]),
          waveGlobal('seed-b', const [1, 0]),
          waveGlobal('match-one', const [1, 0]),
          waveGlobal('orthogonal', const [1, 0]),
        ],
        temporals: [
          waveTemporal('seed-a', const [1, 0]),
          waveTemporal('seed-b', const [-1, 0]),
          waveTemporal('match-one', const [1, 0]),
          waveTemporal('orthogonal', const [0, 1]),
        ],
      ).generate(session: _session());

      expect(batch.tracks.map((track) => track.id), [
        'match-one',
        'orthogonal',
      ]);
      expect(
        batch.candidates.first.temporalSimilarity,
        closeTo((1 + 1 / 3) / 2, 1e-12),
      );
      expect(batch.candidates.last.temporalSimilarity, closeTo(0.5, 1e-12));
    },
  );

  test('same-artist exclusion policy controls first recommendations', () async {
    final tracks = [
      waveTrack('seed', artistId: 'artist', album: 'A'),
      waveTrack('same-artist', artistId: 'artist', album: 'B'),
      waveTrack('external'),
    ];
    final globals = [
      waveGlobal('seed', const [1, 0]),
      waveGlobal('same-artist', const [1, 0]),
      waveGlobal('external', const [0, 1]),
    ];
    final excluded = await _engine(
      tracks: tracks,
      globals: globals,
      config: const ArtistWaveConfig(
        representativeTrackLimit: 1,
        excludeSameArtistTracks: true,
      ),
    ).generate(session: _session());
    final allowed = await _engine(
      tracks: tracks,
      globals: globals,
      config: const ArtistWaveConfig(
        representativeTrackLimit: 1,
        excludeSameArtistTracks: false,
      ),
    ).generate(session: _session());

    expect(excluded.tracks.map((track) => track.id), ['external']);
    expect(allowed.tracks.first.id, 'same-artist');
  });

  test('one analyzed artist track is a valid fallback profile', () async {
    final batch = await _engine(
      tracks: [
        waveTrack('seed', artistId: 'artist'),
        waveTrack('unanalyzed', artistId: 'artist'),
        waveTrack('candidate'),
      ],
      globals: [
        waveGlobal('seed', const [1, 0]),
        waveGlobal('candidate', const [1, 0]),
      ],
      models: const WaveModels(temporal: false),
    ).generate(session: _session());

    expect((batch.session.source as ArtistWaveSource).representativeTrackIds, [
      'seed',
    ]);
    expect(batch.tracks.single.id, 'candidate');
    expect(batch.candidates.single.temporalSimilarity, isNull);
    expect(batch.candidates.single.finalScore, 1);
  });

  test('no analyzed artist seed fails gracefully', () async {
    final batch = await _engine(
      tracks: [
        waveTrack('seed', artistId: 'artist'),
        waveTrack('candidate'),
      ],
      globals: [
        waveGlobal('candidate', const [1, 0]),
      ],
    ).generate(session: _session());

    expect(batch.isEmpty, isTrue);
    expect(batch.session.generationCount, 0);
  });
}

ArtistWaveEngine _engine({
  required List<Track> tracks,
  required List<TrackEmbedding> globals,
  List<TrackTemporalEmbedding> temporals = const [],
  WaveModels models = const WaveModels(),
  ArtistWaveConfig config = const ArtistWaveConfig(),
}) => ArtistWaveEngine(
  tracks: WaveTracks(tracks),
  globalEmbeddings: WaveGlobals(globals),
  temporalEmbeddings: WaveTemporals(temporals),
  registry: MusicAnalysisModelRegistry(models),
  config: config,
);

WaveSession _session() => WaveSession.startArtist(
  artistId: 'artist',
  artistName: 'Artist',
  startedAt: DateTime.utc(2026),
);
