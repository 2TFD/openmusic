import 'package:openmusic/layers/domain/entities/embedding_task.dart';

abstract class EmbeddingTaskRepository {
  Future<EmbeddingTask?> getNextQueued();
  Future<void> markProcessing(String trackId);
  Future<void> saveResult(String trackId, List<double> vector);
  Future<void> markFailed(String trackId);
  Future<void> createTask(EmbeddingTask task);
  Stream<dynamic> watchQueued();
  /// Стрим количества задач в состоянии queued или processing.
  /// Используется UI для отображения счётчика без прямого доступа к data-слою.
  Stream<int> watchPendingCount();
}
