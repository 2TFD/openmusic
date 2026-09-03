import '../entities/music_analysis.dart';
import '../entities/track.dart';
import '../repositories/music_analysis_repository.dart';
import '../repositories/music_analysis_task_repository.dart';

enum QueueMusicAnalysisDisposition { needsDownload, cached, queued }

class QueueMusicAnalysisUseCase {
  const QueueMusicAnalysisUseCase({
    required MusicAnalysisRepository analysis,
    required MusicAnalysisTaskRepository tasks,
  }) : _analysis = analysis,
       _tasks = tasks;

  static const requiredRepresentations = {
    MusicAnalysisRepresentation.audioGlobal,
    MusicAnalysisRepresentation.audioTemporal,
  };

  final MusicAnalysisRepository _analysis;
  final MusicAnalysisTaskRepository _tasks;

  Future<QueueMusicAnalysisDisposition> call(Track track) async {
    if (track.filePath == null) {
      return QueueMusicAnalysisDisposition.needsDownload;
    }
    final missing = await _analysis.missingRepresentations(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: requiredRepresentations,
    );
    if (missing.isEmpty) return QueueMusicAnalysisDisposition.cached;
    await _tasks.enqueue(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: missing,
    );
    return QueueMusicAnalysisDisposition.queued;
  }
}
