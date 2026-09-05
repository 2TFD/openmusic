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
    MusicAnalysisRepresentation.audioEmotionGlobal,
    MusicAnalysisRepresentation.audioEmotionTemporal,
  };
  static const emotionRepresentations = {
    MusicAnalysisRepresentation.audioEmotionGlobal,
    MusicAnalysisRepresentation.audioEmotionTemporal,
  };

  final MusicAnalysisRepository _analysis;
  final MusicAnalysisTaskRepository _tasks;

  /// Durable, DB-only scheduling for import/download completion paths. Cache
  /// and backend capability checks happen in the background worker.
  Future<QueueMusicAnalysisDisposition> schedule(Track track) async {
    if (track.filePath == null) {
      return QueueMusicAnalysisDisposition.needsDownload;
    }
    await _tasks.enqueue(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: requiredRepresentations,
    );
    return QueueMusicAnalysisDisposition.queued;
  }

  Future<QueueMusicAnalysisDisposition> call(
    Track track, {
    Set<MusicAnalysisRepresentation> representations = requiredRepresentations,
  }) async {
    if (track.filePath == null) {
      return QueueMusicAnalysisDisposition.needsDownload;
    }
    final missing = await missingRepresentations(
      track,
      representations: representations,
    );
    if (missing.isEmpty) return QueueMusicAnalysisDisposition.cached;
    await _tasks.enqueue(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: missing,
    );
    return QueueMusicAnalysisDisposition.queued;
  }

  Future<Set<MusicAnalysisRepresentation>> missingRepresentations(
    Track track, {
    Set<MusicAnalysisRepresentation> representations = requiredRepresentations,
  }) {
    if (track.filePath == null) return Future.value(const {});
    return _analysis.missingRepresentations(
      trackId: track.id,
      audioRevision: track.audioRevision,
      representations: representations,
    );
  }
}
