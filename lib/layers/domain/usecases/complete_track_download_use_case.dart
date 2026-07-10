import 'package:openmusic/layers/domain/entities/embedding_task.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class CompleteTrackDownloadUseCase {
  final TrackRepository trackRepository;
  final EmbeddingTaskRepository embeddingRepository;

  CompleteTrackDownloadUseCase(this.trackRepository, this.embeddingRepository);

  Future<void> call({required String trackId, required String filePath}) async {
    await trackRepository.updateTrackPathById(id: trackId, path: filePath);
    await embeddingRepository.createTask(
      EmbeddingTask(
        id: trackId,
        trackId: trackId,
        filePath: filePath,
        status: EmbeddingStatus.queued,
        createdAt: DateTime.now(),
      ),
    );
  }
}
