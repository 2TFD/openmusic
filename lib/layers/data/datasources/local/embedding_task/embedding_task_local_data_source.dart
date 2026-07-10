import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

abstract class EmbeddingTaskLocalDataSource {
  Future<List<EmbeddingTaskDto>> getAll();
  Future<EmbeddingTaskDto> getById(String id);
  Future<EmbeddingTaskDto> getByTrackId(String id);
  Future<void> save(EmbeddingTaskDto record);
  Future<void> update(EmbeddingTaskDto record);
  Future<void> updateStatus(String trackId, EmbeddingStatus status);
  Future<void> deleteById(String id);
  Future<void> clear();
  Stream<dynamic> watch();
  Stream<List<EmbeddingTaskDto>> watchAll();
}
