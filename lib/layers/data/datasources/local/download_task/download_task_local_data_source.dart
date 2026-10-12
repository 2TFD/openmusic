import 'package:owlsonic/layers/data/models/download_task_dto.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';

abstract class DownloadTaskLocalDataSource {
  Future<List<DownloadTaskDto>> getAll();
  Stream<List<DownloadTaskDto>> watchAll();
  Future<bool> enqueue({
    required String trackId,
    required String originalUrl,
    required DateTime createdAt,
  });
  Future<DownloadTaskDto?> claimNext({
    required String ownerId,
    required DateTime leaseUntil,
  });
  Future<bool> renewLease({
    required String trackId,
    required String ownerId,
    required DateTime leaseUntil,
  });
  Future<bool> releaseLease({required String trackId, required String ownerId});
  Future<bool> markFailedIfOwned({
    required String trackId,
    required String ownerId,
    required DownloadFailureInfo failure,
  });
  Future<DownloadTaskDto?> getByTrackId(String trackId);

  /// Puts failed tasks with one of [codes] that failed before [failedBefore]
  /// back into the queue. Returns how many were re-queued.
  Future<int> requeueFailed({
    required Set<String> codes,
    required DateTime failedBefore,
  });
}
