import 'track.dart';

enum RecommendationReadiness { ready, analysisRequired, insufficientLibrary }

class RecommendationCandidate {
  const RecommendationCandidate({
    required this.track,
    required this.finalScore,
    required this.globalSimilarity,
    this.temporalSimilarity,
    this.lyricsSimilarity,
    required this.algorithmVersion,
    required this.modelId,
    required this.modelVersion,
    required this.preprocessingVersion,
  });

  final Track track;
  final double finalScore;
  final double globalSimilarity;
  final double? temporalSimilarity;
  final double? lyricsSimilarity;
  final String algorithmVersion;
  final String modelId;
  final String modelVersion;
  final String preprocessingVersion;
}

class RecommendationDiagnostics {
  const RecommendationDiagnostics({
    required this.analyzedTrackCount,
    required this.libraryTrackCount,
    required this.candidatePoolSize,
    required this.temporalCandidateCount,
    this.lyricsCandidateCount = 0,
    required this.rankingDuration,
    required this.algorithmVersion,
    required this.modelVersion,
    required this.preprocessingVersion,
  });

  final int analyzedTrackCount;
  final int libraryTrackCount;
  final int candidatePoolSize;
  final int temporalCandidateCount;
  final int lyricsCandidateCount;
  final Duration rankingDuration;
  final String algorithmVersion;
  final String modelVersion;
  final String preprocessingVersion;
}

class RecommendationResult {
  const RecommendationResult({
    required this.readiness,
    this.candidates = const [],
    this.missingSeedTrackIds = const [],
    required this.diagnostics,
  });

  final RecommendationReadiness readiness;
  final List<RecommendationCandidate> candidates;
  final List<String> missingSeedTrackIds;
  final RecommendationDiagnostics diagnostics;

  List<Track> get tracks =>
      candidates.map((candidate) => candidate.track).toList(growable: false);
}
