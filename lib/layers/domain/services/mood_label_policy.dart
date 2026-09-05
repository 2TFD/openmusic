import '../entities/music_analysis.dart';

class MoodLabelPolicy {
  const MoodLabelPolicy({this.excludedLabels = defaultExcludedLabels});

  static const defaultExcludedLabels = {
    'advertising',
    'documentary',
    'game',
    'film',
    'trailer',
    'travel',
    'christmas',
    'holiday',
  };

  final Set<String> excludedLabels;

  List<MapEntry<String, double>> topLabels(
    MoodDistribution distribution, {
    int limit = 3,
  }) {
    final allowed =
        distribution.scores.entries
            .where((entry) => !excludedLabels.contains(entry.key.toLowerCase()))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return allowed.take(limit).toList(growable: false);
  }
}
