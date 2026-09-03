import '../entities/music_analysis.dart';
import '../entities/track.dart';
import '../repositories/music_analysis_repository.dart';
import '../repositories/music_analysis_task_repository.dart';

enum QueueLyricsAnalysisDisposition { needsDownload, cached, queued }

class QueueLyricsAnalysisUseCase {
  const QueueLyricsAnalysisUseCase({
    required MusicAnalysisRepository analysis,
    required MusicAnalysisTaskRepository tasks,
  }) : _analysis = analysis,
       _tasks = tasks;

  final MusicAnalysisRepository _analysis;
  final MusicAnalysisTaskRepository _tasks;

  Future<QueueLyricsAnalysisDisposition> call(Track track) async {
    if (track.filePath == null) {
      return QueueLyricsAnalysisDisposition.needsDownload;
    }
    const requested = {MusicAnalysisRepresentation.lyricsGlobal};
    final missing = await _analysis.missingRepresentations(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: requested,
    );
    if (missing.isEmpty) return QueueLyricsAnalysisDisposition.cached;
    await _tasks.enqueue(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: missing,
    );
    return QueueLyricsAnalysisDisposition.queued;
  }
}
