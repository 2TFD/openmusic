import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/services/temporal_aligned_similarity.dart';
import 'package:openmusic/layers/domain/services/temporal_dtw_similarity.dart';
import 'package:openmusic/layers/domain/services/vector_similarity.dart';

void main() {
  test('cosine identifies identical and orthogonal vectors', () {
    expect(VectorSimilarity.cosine([1, 0], [1, 0]), closeTo(1, 1e-12));
    expect(VectorSimilarity.cosine([1, 0], [0, 1]), closeTo(0, 1e-12));
  });

  test('aligned similarity matches the same trajectory', () {
    final score = const TemporalAlignedSimilarity().compare(
      _trajectory([
        [1, 0],
        [0, 1],
      ]),
      _trajectory([
        [1, 0],
        [0, 1],
      ]),
    );
    expect(score.rawDistance, closeTo(0, 1e-12));
    expect(score.rankingScore, closeTo(1, 1e-12));
  });

  test('aligned similarity compares different trajectory lengths', () {
    final score = const TemporalAlignedSimilarity().compare(
      _trajectory([
        [1, 0],
        [0, 1],
      ]),
      _trajectory([
        [1, 0],
        [0.7, 0.7],
        [0, 1],
      ]),
    );
    expect(score.rankingScore, greaterThan(0.95));
  });

  test('DTW identical and stretched trajectories rank highly', () {
    const dtw = TemporalDtwSimilarity();
    const originalVectors = <List<double>>[
      [1, 0],
      [0, 1],
    ];
    final original = _trajectory(originalVectors);
    final identical = dtw.compare(original, original);
    final stretched = dtw.compare(
      original,
      _trajectory([
        [1, 0],
        [1, 0],
        [0, 1],
      ]),
    );
    expect(identical.rawDistance, closeTo(0, 1e-12));
    expect(identical.rankingScore, closeTo(1, 1e-12));
    expect(stretched.rankingScore, closeTo(1, 1e-12));
  });

  test('temporal algorithms reject empty trajectories', () {
    expect(
      () => const TemporalAlignedSimilarity().compare(
        [],
        _trajectory([
          [1, 0],
        ]),
      ),
      throwsArgumentError,
    );
    expect(
      () => const TemporalDtwSimilarity().compare(
        [],
        _trajectory([
          [1, 0],
        ]),
      ),
      throwsArgumentError,
    );
  });
}

List<TemporalAnalysisSegment> _trajectory(List<List<double>> vectors) => [
  for (var index = 0; index < vectors.length; index++)
    TemporalAnalysisSegment(
      index: index,
      startMs: index * 10000,
      endMs: (index + 1) * 10000,
      dimensions: vectors[index].length,
      vector: vectors[index],
    ),
];
