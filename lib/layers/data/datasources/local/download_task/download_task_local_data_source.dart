import 'package:openmusic/layers/data/DTO/download_task_dto.dart';

abstract class DownloadTaskLocalDataSource {
  Future<List<DownloadTaskDto>> getAll();
  Future<DownloadTaskDto?> getByTrackId(String trackId);
  Future<void> save(DownloadTaskDto task);
  Future<void> update(DownloadTaskDto task);
  Future<void> deleteByTrackId(String trackId);
}
