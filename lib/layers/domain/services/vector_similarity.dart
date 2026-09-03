import 'dart:math' as math;

class VectorSimilarity {
  const VectorSimilarity._();

  static double cosine(List<double> a, List<double> b) {
    if (a.isEmpty || a.length != b.length) {
      throw ArgumentError('Vectors must be non-empty and equal-dimensional');
    }
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var index = 0; index < a.length; index++) {
      final av = a[index];
      final bv = b[index];
      if (!av.isFinite || !bv.isFinite) {
        throw ArgumentError('Vectors must contain finite values');
      }
      dot += av * bv;
      normA += av * av;
      normB += bv * bv;
    }
    if (normA == 0 || normB == 0) {
      throw ArgumentError('Cosine is undefined for a zero vector');
    }
    return (dot / (math.sqrt(normA) * math.sqrt(normB))).clamp(-1.0, 1.0);
  }
}
