/// Plain-language names for positions on the mood map, so the UI never has to
/// show raw valence/arousal coordinates.
abstract final class MoodDescription {
  static const _edge = 0.33;

  // Rows run from high to low energy, columns from dark to bright.
  static const _names = [
    ['intenseDark', 'energetic', 'upbeat'],
    ['dark', 'balanced', 'bright'],
    ['calmDark', 'calm', 'soft'],
  ];

  /// Locale key under `moodMap.descriptions` for the given position.
  static String keyFor({required double valence, required double arousal}) {
    final column = valence > _edge
        ? 2
        : valence < -_edge
        ? 0
        : 1;
    final row = arousal > _edge
        ? 0
        : arousal < -_edge
        ? 2
        : 1;
    return 'moodMap.descriptions.${_names[row][column]}';
  }
}
