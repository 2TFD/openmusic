import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/wave/wave_engine.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';

void main() {
  test('artist seeds become targets and are excluded from candidates', () {
    final seedA = _track('seed-a', artist: 'Selected', vector: const [1, 0]);
    final seedB = _track('seed-b', artist: 'Selected', vector: const [1, 0]);
    final near = _track('near', artist: 'Other', vector: const [0.9, 0.1]);
    final far = _track('far', artist: 'Other', vector: const [0, 1]);

    final result = WaveEngine.generate(
      const WaveConfig(seeds: ['selected'], tracks: []),
      [seedA, seedB, far, near],
    );

    expect(result.map((track) => track.id), ['near', 'far']);
  });

  test(
    'explicit and artist targets are deduplicated and queueSize is applied',
    () {
      final seed = _track('seed', artist: 'Selected', vector: const [1, 0]);
      final first = _track('first', artist: 'Other', vector: const [0.9, 0.1]);
      final second = _track(
        'second',
        artist: 'Other',
        vector: const [0.8, 0.2],
      );

      final result = WaveEngine.generate(
        WaveConfig(seeds: const ['Selected'], tracks: [seed], queueSize: 1),
        [seed, second, first],
      );

      expect(result.map((track) => track.id), ['first']);
    },
  );
}

Track _track(
  String id, {
  required String artist,
  required List<double> vector,
}) => Track(
  id: id,
  title: id,
  artists: [Artist(id: 'artist-$artist', name: artist)],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/music/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '/music/$id.mp3',
  embedding: vector,
);
