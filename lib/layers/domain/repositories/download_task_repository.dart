import 'package:openmusic/layers/domain/entities/download_track_task.dart';

abstract class DownloadTaskRepository {
  Future<void> enqueue(String trackId, String originalUrl);
  Future<DownloadTrackTask?> getNextQueued();
  Future<void> markDownloading(String trackId);
  Future<void> markDone(String trackId);
  Future<void> markFailed(String trackId);
}
