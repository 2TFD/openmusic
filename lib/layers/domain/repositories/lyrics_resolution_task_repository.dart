import '../entities/lyrics_resolution_task.dart';

abstract interface class LyricsResolutionTaskRepository {
  Stream<int> watchPendingCount();

  Future<void> enqueue(String trackId);

  Future<LyricsResolutionTask?> claimNext();

  Future<void> complete(String id);

  Future<void> fail(
    String id, {
    required String errorCode,
    String? errorMessage,
    required bool requeue,
    DateTime? retryAt,
  });

  Future<void> resetRunning();
}
