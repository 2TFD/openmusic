import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/presentation/mood_map/mood_map_geometry.dart';

void main() {
  const size = Size(200, 200);

  test('maps V/A center and corners with inverted arousal axis', () {
    expect(
      MoodMapGeometry.toCanvas(valence: 0, arousal: 0, size: size),
      const Offset(100, 100),
    );
    expect(
      MoodMapGeometry.toCanvas(valence: -1, arousal: 1, size: size),
      Offset.zero,
    );
    expect(
      MoodMapGeometry.toCanvas(valence: 1, arousal: -1, size: size),
      const Offset(200, 200),
    );
  });

  test('inverse mapping clamps to valid model range', () {
    final value = MoodMapGeometry.fromCanvas(
      offset: const Offset(250, -10),
      size: size,
    );
    expect(value.valence, 1);
    expect(value.arousal, 1);
  });

  test('radius filtering uses Euclidean distance in V/A space', () {
    expect(
      MoodMapGeometry.withinRadius(
        valence: 0.3,
        arousal: 0.4,
        targetValence: 0,
        targetArousal: 0,
        radius: 0.5,
      ),
      isTrue,
    );
    expect(
      MoodMapGeometry.withinRadius(
        valence: 0.4,
        arousal: 0.4,
        targetValence: 0,
        targetArousal: 0,
        radius: 0.5,
      ),
      isFalse,
    );
  });
}
