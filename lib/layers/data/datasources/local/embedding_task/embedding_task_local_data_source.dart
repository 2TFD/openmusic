import 'package:openmusic/layers/data/DTO/embedding_task_dto.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';

abstract class EmbeddingTaskLocalDataSource {
  Future<List<EmbeddingTaskDto>> getAll();
  Future<EmbeddingTaskDto?> claimNext({
    required String ownerId,
    required DateTime leaseUntil,
  });
  Future<bool> renewLease({
    required String trackId,
    required String ownerId,
    required DateTime leaseUntil,
  });
  Future<bool> releaseLease({required String trackId, required String ownerId});
  Future<bool> updateStatusIfOwned({
    required String trackId,
    required String ownerId,
    required EmbeddingStatus status,
  });
  Future<bool> completeIfOwned({
    required String trackId,
    required String ownerId,
    required List<double> vector,
  });
  Future<EmbeddingTaskDto> getById(String id);
  Future<EmbeddingTaskDto> getByTrackId(String id);
  Future<void> save(EmbeddingTaskDto record);
  Future<void> update(EmbeddingTaskDto record);
  Future<void> updateStatus(String trackId, EmbeddingStatus status);
  Future<void> deleteById(String id);
  Future<void> clear();
  Stream<List<EmbeddingTaskDto>> watch();
  Stream<List<EmbeddingTaskDto>> watchAll();
}
