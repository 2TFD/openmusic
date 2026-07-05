import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';

abstract class EmbeddingTaskLocalDataSource {
  Future<List<EmbeddingTaskDto>> getAll();
  Future<EmbeddingTaskDto> getById(String id);
  Future<EmbeddingTaskDto> getByTrackId(String id);
  Future<void> save(EmbeddingTaskDto record);
  Future<void> update(EmbeddingTaskDto record);
  Future<void> deleteById(String id);
  Future<void> clear();
  Stream<dynamic> watch();
}
