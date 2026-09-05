import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/services/mood_label_policy.dart';

void main() {
  test('display policy filters themes without mutating backend scores', () {
    final distribution = MoodDistribution(const {
      'film': 0.99,
      'travel': 0.95,
      'calm': 0.8,
      'joyful': 0.7,
    });

    final labels = const MoodLabelPolicy().topLabels(distribution);

    expect(labels.map((entry) => entry.key), ['calm', 'joyful']);
    expect(distribution.scores['film'], 0.99);
    expect(distribution.scores, hasLength(4));
  });
}
