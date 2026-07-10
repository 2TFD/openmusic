import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

abstract class DownloadTaskLocalDataSource {
  Future<List<DownloadTaskDto>> getAll();
  Future<DownloadTaskDto?> getByTrackId(String trackId);
  Future<void> save(DownloadTaskDto task);
  Future<void> update(DownloadTaskDto task);
  Future<void> updateStatus(String trackId, DownloadStatus status);
  Future<void> deleteByTrackId(String trackId);
}
