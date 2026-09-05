import 'dart:math' as math;
import 'dart:ui';

abstract final class MoodMapGeometry {
  static Offset toCanvas({
    required double valence,
    required double arousal,
    required Size size,
  }) => Offset(
    ((valence.clamp(-1.0, 1.0) + 1) / 2) * size.width,
    (1 - (arousal.clamp(-1.0, 1.0) + 1) / 2) * size.height,
  );

  static ({double valence, double arousal}) fromCanvas({
    required Offset offset,
    required Size size,
  }) {
    final x = offset.dx.clamp(0.0, size.width);
    final y = offset.dy.clamp(0.0, size.height);
    return (
      valence: x / size.width * 2 - 1,
      arousal: (1 - y / size.height) * 2 - 1,
    );
  }

  static bool withinRadius({
    required double valence,
    required double arousal,
    required double targetValence,
    required double targetArousal,
    required double radius,
  }) =>
      math.sqrt(
        math.pow(valence - targetValence, 2) +
            math.pow(arousal - targetArousal, 2),
      ) <=
      radius;
}
