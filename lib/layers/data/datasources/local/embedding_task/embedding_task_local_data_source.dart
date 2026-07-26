import 'package:openmusic/layers/data/models/embedding_task_dto.dart';

abstract class EmbeddingTaskLocalDataSource {
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
  Future<bool> markFailedIfOwned({
    required String trackId,
    required String ownerId,
  });
  Future<bool> completeIfOwned({
    required String trackId,
    required String ownerId,
    required int audioRevision,
    required List<double> vector,
  });
  Stream<List<EmbeddingTaskDto>> watchAll();
}
