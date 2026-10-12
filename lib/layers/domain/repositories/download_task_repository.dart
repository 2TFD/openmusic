import 'package:owlsonic/layers/domain/entities/download_track_task.dart';

abstract class DownloadTaskRepository {
  Future<void> enqueue(String trackId, String originalUrl);
  Stream<List<DownloadTrackTask>> watchAll();

  /// Atomically claims the next task for this worker.
  /// Returns null when no task could be claimed (or another worker won).
  Future<DownloadTrackTask?> claimNext({required String ownerId});
  Future<bool> renewLease({required String trackId, required String ownerId});
  Future<bool> releaseLease({required String trackId, required String ownerId});
  Future<bool> markFailed({
    required String trackId,
    required String ownerId,
    required DownloadFailureInfo failure,
  });

  /// Re-queues tasks that failed with a temporary cause ([codes]) before
  /// [failedBefore]. Returns how many were re-queued.
  Future<int> requeueFailed({
    required Set<String> codes,
    required DateTime failedBefore,
  });
}
