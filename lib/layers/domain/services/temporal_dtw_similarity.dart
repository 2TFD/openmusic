import '../entities/music_analysis.dart';
import 'temporal_aligned_similarity.dart';
import 'vector_similarity.dart';

class TemporalDtwSimilarity {
  const TemporalDtwSimilarity();

  /// Uses local distance `1 - cosine`. The optimal accumulated DTW cost is
  /// divided by its path length. UI rankingScore is `1 / (1 + rawDistance)`;
  /// it is deliberately not presented as a cosine score.
  TemporalSimilarityScore compare(
    List<TemporalAnalysisSegment> a,
    List<TemporalAnalysisSegment> b,
  ) {
    if (a.isEmpty || b.isEmpty) throw ArgumentError('Empty trajectory');
    final dimensions = a.first.dimensions;
    if (a.any((segment) => segment.dimensions != dimensions) ||
        b.any((segment) => segment.dimensions != dimensions)) {
      throw ArgumentError('Trajectory dimensions do not match');
    }
    final costs = List.generate(
      a.length + 1,
      (_) => List<double>.filled(b.length + 1, double.infinity),
    );
    final steps = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );
    costs[0][0] = 0;
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final options = <({double cost, int steps})>[
          (cost: costs[i - 1][j], steps: steps[i - 1][j]),
          (cost: costs[i][j - 1], steps: steps[i][j - 1]),
          (cost: costs[i - 1][j - 1], steps: steps[i - 1][j - 1]),
        ]..sort((left, right) => left.cost.compareTo(right.cost));
        final previous = options.first;
        costs[i][j] =
            previous.cost +
            1 -
            VectorSimilarity.cosine(a[i - 1].vector, b[j - 1].vector);
        steps[i][j] = previous.steps + 1;
      }
    }
    final rawDistance = costs[a.length][b.length] / steps[a.length][b.length];
    return TemporalSimilarityScore(
      rawDistance: rawDistance,
      rankingScore: 1 / (1 + rawDistance),
    );
  }
}
