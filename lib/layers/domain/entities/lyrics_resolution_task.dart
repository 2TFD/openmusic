enum LyricsResolutionTaskStatus { queued, running, completed, failed }

class LyricsResolutionTask {
  const LyricsResolutionTask({
    required this.id,
    required this.trackId,
    required this.status,
    required this.attemptCount,
    this.scheduledAt,
    this.lastErrorCode,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String trackId;
  final LyricsResolutionTaskStatus status;
  final int attemptCount;
  final DateTime? scheduledAt;
  final String? lastErrorCode;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
}
