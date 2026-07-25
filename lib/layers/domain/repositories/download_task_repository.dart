import 'package:openmusic/layers/domain/entities/download_track_task.dart';

abstract class DownloadTaskRepository {
  Future<void> enqueue(String trackId, String originalUrl);

  /// Atomically claims the next task for this worker.
  /// Returns null when no task could be claimed (or another worker won).
  Future<DownloadTrackTask?> claimNext({required String ownerId});
  Future<bool> renewLease({required String trackId, required String ownerId});
  Future<bool> releaseLease({required String trackId, required String ownerId});
  Future<bool> markFailed({required String trackId, required String ownerId});
}
