import 'package:openmusic/layers/domain/entities/embedding_task.dart';

abstract class EmbeddingTaskRepository {
  /// Atomically moves the next queued task to processing and returns it.
  Future<EmbeddingTask?> claimNext({required String ownerId});
  Future<bool> renewLease({required String trackId, required String ownerId});
  Future<bool> releaseLease({required String trackId, required String ownerId});
  Future<bool> saveResult({
    required String trackId,
    required String ownerId,
    required List<double> vector,
  });
  Future<bool> markFailed({required String trackId, required String ownerId});
  Future<void> createTask(EmbeddingTask task);
  Stream<List<EmbeddingTask>> watchQueued();

  /// Стрим количества задач в состоянии queued или processing.
  /// Используется UI для отображения счётчика без прямого доступа к data-слою.
  Stream<int> watchPendingCount();
}
