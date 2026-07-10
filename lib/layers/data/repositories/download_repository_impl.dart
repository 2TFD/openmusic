import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/download_task_mapper.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';

class DownloadTaskRepositoryImpl implements DownloadTaskRepository {
  final DownloadTaskLocalDataSource localDataSource;

  DownloadTaskRepositoryImpl({required this.localDataSource});

  @override
  Future<void> enqueue(String trackId, String originalUrl) async {
    final existing = await localDataSource.getByTrackId(trackId);
    if (existing != null &&
        existing.status != DownloadStatus.completed &&
        existing.status != DownloadStatus.failed) {
      return;
    }
    await localDataSource.save(
      DownloadTaskDto(
        trackId: trackId,
        originalUrl: originalUrl,
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<DownloadTrackTask?> getNextQueued() async {
    final all = await localDataSource.getAll();
    final dto = all
        .where((t) =>
            t.status == DownloadStatus.queued ||
            // сбрасываем зависшие downloading при перезапуске
            (t.status == DownloadStatus.downloading &&
                DateTime.now().difference(t.createdAt).inMinutes > 5))
        .firstOrNull;
    return dto == null ? null : DownloadTaskMapper.toEntity(dto);
  }

  @override
  Future<void> markDownloading(String trackId) =>
      localDataSource.updateStatus(trackId, DownloadStatus.downloading);

  @override
  Future<void> markDone(String trackId) =>
      localDataSource.deleteByTrackId(trackId);

  @override
  Future<void> markFailed(String trackId) =>
      localDataSource.updateStatus(trackId, DownloadStatus.failed);
}
