import 'package:openmusic/core/services/task_lease.dart';
import 'package:openmusic/layers/data/datasources/local/embedding_task/embedding_task_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/embedding_task_mapper.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';

class EmbeddingTaskRepositoryImpl implements EmbeddingTaskRepository {
  final EmbeddingTaskLocalDataSource localDataSource;
  EmbeddingTaskRepositoryImpl({required this.localDataSource});
  @override
  Future<EmbeddingTask?> claimNext({required String ownerId}) async {
    final dto = await localDataSource.claimNext(
      ownerId: ownerId,
      leaseUntil: DateTime.now().add(TaskLeasePolicy.duration),
    );
    return dto == null ? null : EmbeddingTaskMapper.toEntity(dto);
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
      localDataSource.updateStatusIfOwned(
        trackId: trackId,
        ownerId: ownerId,
        status: EmbeddingStatus.failed,
      );

  @override
  Future<bool> saveResult({
    required String trackId,
    required String ownerId,
    required List<double> vector,
  }) => localDataSource.completeIfOwned(
    trackId: trackId,
    ownerId: ownerId,
    vector: vector,
  );

  @override
  Stream<List<EmbeddingTask>> watchQueued() {
    return localDataSource.watch().map(
      (dtos) => dtos.map(EmbeddingTaskMapper.toEntity).toList(),
    );
  }

  @override
  Stream<int> watchPendingCount() {
    return localDataSource.watchAll().map(
      (dtos) => dtos
          .where(
            (dto) =>
                dto.status == EmbeddingStatus.queued ||
                dto.status == EmbeddingStatus.processing,
          )
          .length,
    );
  }

  @override
  Future<void> createTask(EmbeddingTask task) async {
    final dto = EmbeddingTaskMapper.toDto(task);
    return await localDataSource.save(dto);
  }
}
