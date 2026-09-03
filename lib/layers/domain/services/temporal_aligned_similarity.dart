import '../entities/music_analysis.dart';
import 'vector_similarity.dart';

class TemporalSimilarityScore {
  const TemporalSimilarityScore({
    required this.rawDistance,
    required this.rankingScore,
  });

  final double rawDistance;
  final double rankingScore;
}

class TemporalAlignedSimilarity {
  const TemporalAlignedSimilarity();

  /// Resamples both trajectories onto a shared [0, 1] relative-time grid.
  /// rawDistance is mean(1 - cosine); rankingScore is the mean cosine.
  TemporalSimilarityScore compare(
    List<TemporalAnalysisSegment> a,
    List<TemporalAnalysisSegment> b,
  ) {
    _validate(a, b);
    final count = a.length > b.length ? a.length : b.length;
    final aPoints = _points(a);
    final bPoints = _points(b);
    var distance = 0.0;
    for (var index = 0; index < count; index++) {
      final position = count == 1 ? 0.0 : index / (count - 1);
      final similarity = VectorSimilarity.cosine(
        _interpolate(aPoints, position),
        _interpolate(bPoints, position),
      );
      distance += 1 - similarity;
    }
    final rawDistance = distance / count;
    return TemporalSimilarityScore(
      rawDistance: rawDistance,
      rankingScore: 1 - rawDistance,
    );
  }

  static void _validate(
    List<TemporalAnalysisSegment> a,
    List<TemporalAnalysisSegment> b,
  ) {
    if (a.isEmpty || b.isEmpty) throw ArgumentError('Empty trajectory');
    final dimensions = a.first.dimensions;
    if (dimensions <= 0 ||
        a.any((segment) => segment.dimensions != dimensions) ||
        b.any((segment) => segment.dimensions != dimensions)) {
      throw ArgumentError('Trajectory dimensions do not match');
    }
  }

  static List<({double position, List<double> vector})> _points(
    List<TemporalAnalysisSegment> segments,
  ) {
    final midpoints = segments
        .map((segment) => (segment.startMs + segment.endMs) / 2)
        .toList(growable: false);
    final first = midpoints.first;
    final span = midpoints.last - first;
    return [
      for (var index = 0; index < segments.length; index++)
        (
          position: span == 0 ? 0.0 : (midpoints[index] - first) / span,
          vector: segments[index].vector,
        ),
    ];
  }

  static List<double> _interpolate(
    List<({double position, List<double> vector})> points,
    double position,
  ) {
    if (points.length == 1 || position <= points.first.position) {
      return points.first.vector;
    }
    if (position >= points.last.position) return points.last.vector;
    for (var index = 1; index < points.length; index++) {
      final right = points[index];
      if (position > right.position) continue;
      final left = points[index - 1];
      final span = right.position - left.position;
      final weight = span == 0 ? 0.0 : (position - left.position) / span;
      return List<double>.generate(
        left.vector.length,
        (dimension) =>
            left.vector[dimension] * (1 - weight) +
            right.vector[dimension] * weight,
        growable: false,
      );
    }
    return points.last.vector;
  }
}
