import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/data/datasources/local/embeding_task/embedding_task_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/embedding_task_mapper.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';

class EmbeddingTaskRepositoryImpl implements EmbeddingTaskRepository {
  final EmbeddingTaskLocalDataSource localDataSource;
  EmbeddingTaskRepositoryImpl({required this.localDataSource});
  @override
  Future<EmbeddingTask?> getNextQueued() async {
    final EmbeddingTaskDto? dto = (await localDataSource.getAll())
        .where(
          (task) =>
              task.status == EmbeddingStatus.queued ||
              task.status == EmbeddingStatus.failed ||
              (task.status == EmbeddingStatus.processing &&
                  DateTime.now().difference(task.createdAt).inMinutes > 3),
        )
        .firstOrNull;
    if (dto == null) return null;
    return EmbeddingTaskMapper.toEntity(dto);
  }

  @override
  Future<void> markFailed(String trackId) async {
    final task = await localDataSource.getByTrackId(trackId);
    final updatedTask = task.copyWith(status: EmbeddingStatus.failed);
    return localDataSource.update(updatedTask);
  }

  @override
  Future<void> markProcessing(String trackId) async {
    final task = await localDataSource.getByTrackId(trackId);
    final updatedTask = task.copyWith(status: EmbeddingStatus.processing);
    return localDataSource.update(updatedTask);
  }

  @override
  Future<void> saveResult(String trackId, List<double> vector) async {
    final task = await localDataSource.getByTrackId(trackId);
    final updatedTask = task.copyWith(
      status: EmbeddingStatus.done,
      filePath: vector.toString(),
    );
    return localDataSource.update(updatedTask);
  }

  @override
  Stream<dynamic> watchQueued() {
    return localDataSource.watch();
  }

  @override
  Future<void> createTask(EmbeddingTask task) async {
    final dto = EmbeddingTaskMapper.toDto(task);
    return await localDataSource.save(dto);
  }
}
