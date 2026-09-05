import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/presentation/mood_map/mood_map_view_policy.dart';

void main() {
  test('artwork fades in only at close zoom levels', () {
    expect(MoodMapViewPolicy.artworkOpacity(3), 0);
    expect(MoodMapViewPolicy.artworkOpacity(3.5), closeTo(0.5, 0.001));
    expect(MoodMapViewPolicy.artworkOpacity(4), 1);
  });

  test('artwork selection uses the viewport instead of the first tracks', () {
    final entries = List<int>.generate(200, (index) => index);

    final selected = MoodMapViewPolicy.selectVisible(
      entries: entries,
      viewport: const Rect.fromLTWH(0, 0, 100, 100),
      positionOf: (entry) => entry < 150
          ? const Offset(-100, -100)
          : Offset((entry - 150).toDouble(), 50),
      isPrioritized: (entry) => entry == 175,
      limit: 5,
    );

    expect(selected, hasLength(5));
    expect(selected.first, 175);
    expect(selected, everyElement(greaterThanOrEqualTo(150)));
  });

  test('artwork selection respects its rendering cap', () {
    final selected = MoodMapViewPolicy.selectVisible(
      entries: List<int>.generate(500, (index) => index),
      viewport: const Rect.fromLTWH(0, 0, 100, 100),
      positionOf: (_) => const Offset(50, 50),
      isPrioritized: (_) => false,
    );

    expect(selected, hasLength(MoodMapViewPolicy.maxArtworkMarkers));
  });
}
