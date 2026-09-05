import 'package:equatable/equatable.dart';

import 'track.dart';
import 'track_emotion_analysis.dart';

class MoodMapTrack extends Equatable {
  const MoodMapTrack({
    required this.track,
    required this.modelAnalysis,
    this.personalAdjustment,
  });

  final Track track;
  final TrackEmotionAnalysis modelAnalysis;
  final PersonalMoodAdjustment? personalAdjustment;

  double get valence => personalAdjustment?.valence ?? modelAnalysis.valence;
  double get arousal => personalAdjustment?.arousal ?? modelAnalysis.arousal;
  bool get hasPersonalPosition => personalAdjustment != null;

  MoodMapTrack copyWith({PersonalMoodAdjustment? personalAdjustment}) =>
      MoodMapTrack(
        track: track,
        modelAnalysis: modelAnalysis,
        personalAdjustment: personalAdjustment,
      );

  @override
  List<Object?> get props => [track, modelAnalysis, personalAdjustment];
}

class MoodRadiusSelection extends Equatable {
  const MoodRadiusSelection({
    required this.targetValence,
    required this.targetArousal,
    required this.radius,
  });

  final double targetValence;
  final double targetArousal;
  final double radius;

  bool contains(double valence, double arousal) {
    final dx = valence - targetValence;
    final dy = arousal - targetArousal;
    return dx * dx + dy * dy <= radius * radius;
  }

  @override
  List<Object> get props => [targetValence, targetArousal, radius];
}
