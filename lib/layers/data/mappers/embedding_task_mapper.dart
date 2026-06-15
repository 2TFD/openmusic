import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

class EmbeddingTaskMapper {
  static EmbeddingTaskDto toDto(EmbeddingTask entity) {
    return EmbeddingTaskDto(
      id: entity.id,
      trackId: entity.trackId,
      status: entity.status,
      createdAt: entity.createdAt,
      filePath: entity.filePath,
    );
  }

  static EmbeddingTask toEntity(EmbeddingTaskDto dto) {
    return EmbeddingTask(
      id: dto.id,
      trackId: dto.trackId,
      status: dto.status,
      createdAt: dto.createdAt,
      filePath: dto.filePath,
    );
  }
}
