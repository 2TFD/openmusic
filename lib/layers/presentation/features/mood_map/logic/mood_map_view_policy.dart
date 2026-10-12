import 'dart:ui';

abstract final class MoodMapViewPolicy {
  static const double maxScale = 8;
  static const double artworkRevealScale = 3.25;
  static const double artworkFullScale = 3.75;
  static const double artworkMarkerScreenSize = 40;
  static const int maxArtworkMarkers = 120;

  static double artworkOpacity(double scale) =>
      ((scale - artworkRevealScale) / (artworkFullScale - artworkRevealScale))
          .clamp(0.0, 1.0);

  static List<T> selectVisible<T>({
    required Iterable<T> entries,
    required Rect viewport,
    required Offset Function(T entry) positionOf,
    required bool Function(T entry) isPrioritized,
    int limit = maxArtworkMarkers,
  }) {
    if (limit <= 0) return const [];

    final visible = entries
        .where((entry) => viewport.contains(positionOf(entry)))
        .toList(growable: false);
    final center = viewport.center;
    visible.sort((a, b) {
      final priority = (isPrioritized(b) ? 1 : 0) - (isPrioritized(a) ? 1 : 0);
      if (priority != 0) return priority;
      return (positionOf(a) - center).distanceSquared.compareTo(
        (positionOf(b) - center).distanceSquared,
      );
    });
    return visible.take(limit).toList(growable: false);
  }
}
