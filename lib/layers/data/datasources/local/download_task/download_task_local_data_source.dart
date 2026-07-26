import 'package:openmusic/layers/data/models/download_task_dto.dart';

abstract class DownloadTaskLocalDataSource {
  Future<List<DownloadTaskDto>> getAll();
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
  });
  Future<DownloadTaskDto?> getByTrackId(String trackId);
}
