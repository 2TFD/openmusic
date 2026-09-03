import '../entities/music_analysis.dart';
import '../entities/music_analysis_failure.dart';
import '../entities/music_analysis_task.dart';

abstract interface class MusicAnalysisTaskRepository {
  Stream<List<MusicAnalysisTask>> watchAll();
  Stream<int> watchPendingCount();
  Future<List<MusicAnalysisTask>> getAll();
  Future<void> enqueue({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  });
  Future<MusicAnalysisTask?> claimNext();
  Future<void> complete(String id);
  Future<void> fail(
    String id,
    MusicAnalysisFailure failure, {
    required bool requeue,
  });
  Future<void> retryFailed();
  Future<void> resetRunning();
}
