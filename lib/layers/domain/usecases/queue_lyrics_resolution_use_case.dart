import '../entities/track.dart';
import '../repositories/lyrics_resolution_task_repository.dart';

enum QueueLyricsResolutionDisposition { needsDownload, queued }

class QueueLyricsResolutionUseCase {
  const QueueLyricsResolutionUseCase(this._tasks);

  final LyricsResolutionTaskRepository _tasks;

  Future<QueueLyricsResolutionDisposition> call(Track track) async {
    if (track.filePath == null) {
      return QueueLyricsResolutionDisposition.needsDownload;
    }
    await _tasks.enqueue(track.id);
    return QueueLyricsResolutionDisposition.queued;
  }
}
