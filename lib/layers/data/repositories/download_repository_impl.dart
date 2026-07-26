import 'package:openmusic/core/services/task_lease.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/download_task_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/download_task_mapper.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';

class DownloadTaskRepositoryImpl implements DownloadTaskRepository {
  final DownloadTaskLocalDataSource localDataSource;

  DownloadTaskRepositoryImpl({required this.localDataSource});

  @override
  Future<void> enqueue(String trackId, String originalUrl) async {
    await localDataSource.enqueue(
      trackId: trackId,
      originalUrl: originalUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<DownloadTrackTask?> claimNext({required String ownerId}) async {
    final dto = await localDataSource.claimNext(
      ownerId: ownerId,
      leaseUntil: DateTime.now().add(TaskLeasePolicy.duration),
    );
    return dto == null ? null : DownloadTaskMapper.toEntity(dto);
  }

  @override
  Future<bool> renewLease({required String trackId, required String ownerId}) =>
      localDataSource.renewLease(
        trackId: trackId,
        ownerId: ownerId,
        leaseUntil: DateTime.now().add(TaskLeasePolicy.duration),
      );

  @override
  Future<bool> releaseLease({
    required String trackId,
    required String ownerId,
  }) => localDataSource.releaseLease(trackId: trackId, ownerId: ownerId);

  @override
  Future<bool> markFailed({required String trackId, required String ownerId}) =>
      localDataSource.markFailedIfOwned(trackId: trackId, ownerId: ownerId);
}
