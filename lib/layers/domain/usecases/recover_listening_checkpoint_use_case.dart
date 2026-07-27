import 'package:openmusic/layers/domain/repositories/listening_checkpoint_repository.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';

class RecoverListeningCheckpointUseCase {
  const RecoverListeningCheckpointUseCase({
    required this.checkpoints,
    required this.saveRecord,
  });

  final ListeningCheckpointRepository checkpoints;
  final SaveRecordPlayUseCase saveRecord;

  Future<void> call() async {
    final checkpoint = await checkpoints.load();
    if (checkpoint == null) return;
    await saveRecord.saveSnapshot(
      recordId: checkpoint.id,
      trackId: checkpoint.trackId,
      trackTitle: checkpoint.trackTitle,
      artistName: checkpoint.artistName,
      sourceType: checkpoint.sourceType,
      listenedDuration: checkpoint.listenedDuration,
      playedAt: checkpoint.updatedAt,
    );
    await checkpoints.clear(checkpoint.id);
  }
}
