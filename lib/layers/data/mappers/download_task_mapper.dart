import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

class DownloadTaskMapper {
  static DownloadTaskDto toDto(DownloadTrackTask entity) {
    return DownloadTaskDto(
      trackId: entity.trackId,
      originalUrl: entity.originalUrl,
      status: entity.status,
      createdAt: DateTime.now(),
    );
  }

  static DownloadTrackTask toEntity(DownloadTaskDto dto) {
    return DownloadTrackTask(
      trackId: dto.trackId,
      originalUrl: dto.originalUrl,
      status: dto.status,
    );
  }
}
