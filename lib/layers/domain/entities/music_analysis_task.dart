import 'music_analysis.dart';

enum MusicAnalysisTaskStatus { queued, running, completed, failed }

class MusicAnalysisTask {
  const MusicAnalysisTask({
    required this.id,
    required this.trackId,
    required this.requestedRepresentations,
    required this.audioRevision,
    required this.status,
    required this.attemptCount,
    this.lastErrorCode,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String trackId;
  final Set<MusicAnalysisRepresentation> requestedRepresentations;
  final int audioRevision;
  final MusicAnalysisTaskStatus status;
  final int attemptCount;
  final String? lastErrorCode;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
}
