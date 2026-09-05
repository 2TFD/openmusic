import 'package:equatable/equatable.dart';

import 'music_analysis.dart';
import 'track.dart';

String emotionContentRevisionFor(Track track) =>
    track.contentIdentity ?? 'audio:${track.audioRevision}';

class TrackEmotionAnalysis extends Equatable {
  const TrackEmotionAnalysis({
    required this.id,
    required this.trackId,
    required this.representation,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.contentRevision,
    required this.audioRevision,
    required this.valence,
    required this.arousal,
    this.rawValence,
    this.rawArousal,
    required this.moodDistribution,
    required this.analyzedAt,
  });

  final String id;
  final String trackId;
  final String representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final String contentRevision;
  final int audioRevision;
  final double valence;
  final double arousal;
  final double? rawValence;
  final double? rawArousal;
  final MoodDistribution moodDistribution;
  final DateTime analyzedAt;

  @override
  List<Object?> get props => [
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    contentRevision,
    audioRevision,
    valence,
    arousal,
    rawValence,
    rawArousal,
    moodDistribution,
    analyzedAt,
  ];
}

class TrackEmotionSegment extends Equatable {
  const TrackEmotionSegment({
    required this.analysisId,
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.valence,
    required this.arousal,
    required this.moodDistribution,
  });

  final String analysisId;
  final int index;
  final int startMs;
  final int endMs;
  final double valence;
  final double arousal;
  final MoodDistribution moodDistribution;

  @override
  List<Object> get props => [
    analysisId,
    index,
    startMs,
    endMs,
    valence,
    arousal,
    moodDistribution,
  ];
}

class TrackEmotionTemporalAnalysis extends Equatable {
  const TrackEmotionTemporalAnalysis({
    required this.id,
    required this.trackId,
    required this.representation,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
    required this.contentRevision,
    required this.audioRevision,
    required this.summary,
    required this.segments,
    required this.analyzedAt,
  });

  final String id;
  final String trackId;
  final String representation;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
  final String contentRevision;
  final int audioRevision;
  final AudioEmotionTemporalSummary summary;
  final List<TrackEmotionSegment> segments;
  final DateTime analyzedAt;

  @override
  List<Object> get props => [
    id,
    trackId,
    representation,
    modelId,
    modelVersion,
    preprocessingVersion,
    contentRevision,
    audioRevision,
    summary,
    segments,
    analyzedAt,
  ];
}

class PersonalMoodAdjustment extends Equatable {
  const PersonalMoodAdjustment({
    required this.trackId,
    required this.valence,
    required this.arousal,
    required this.updatedAt,
  });

  final String trackId;
  final double valence;
  final double arousal;
  final DateTime updatedAt;

  @override
  List<Object> get props => [trackId, valence, arousal, updatedAt];
}
