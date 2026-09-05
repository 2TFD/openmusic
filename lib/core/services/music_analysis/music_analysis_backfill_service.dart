import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/entities/music_analysis_task.dart';
import '../../../layers/domain/entities/music_analysis.dart';
import '../../../layers/domain/repositories/music_analysis_task_repository.dart';
import '../../../layers/domain/usecases/queue_music_analysis_use_case.dart';
import 'music_analysis_config.dart';
import 'music_analysis_model_registry.dart';

abstract interface class MusicAnalysisBackfill {
  Future<int> enqueueNextBatch();
}

class MusicAnalysisBackfillService implements MusicAnalysisBackfill {
  MusicAnalysisBackfillService({
    required TrackRepository tracks,
    required QueueMusicAnalysisUseCase queueAnalysis,
    required MusicAnalysisModelRegistry registry,
    required MusicAnalysisQueueConfig config,
    MusicAnalysisTaskRepository? tasks,
  }) : _tracks = tracks,
       _queueAnalysis = queueAnalysis,
       _registry = registry,
       _config = config,
       _tasks = tasks;

  final TrackRepository _tracks;
  final QueueMusicAnalysisUseCase _queueAnalysis;
  final MusicAnalysisModelRegistry _registry;
  final MusicAnalysisQueueConfig _config;
  final MusicAnalysisTaskRepository? _tasks;
  DateTime? _lastRegistryRefresh;
  bool _running = false;
  String? _cursorTrackId;

  @override
  Future<int> enqueueNextBatch() async {
    if (_running) return 0;
    _running = true;
    try {
      final now = DateTime.now();
      MusicAnalysisModels? models;
      if (_lastRegistryRefresh == null ||
          now.difference(_lastRegistryRefresh!) >=
              _config.modelRegistryRefreshInterval) {
        models = await _registry.getModels(refresh: true);
        _lastRegistryRefresh = now;
      }
      models ??= await _registry.getModels();
      final supportsEmotion =
          models.find(MusicAnalysisRepresentation.audioEmotionGlobal) != null;
      var queued = 0;
      final tracks = await _tracks.getTracks();
      final existingTasks = await _tasks?.getAll() ?? const [];
      final cursorIndex = _cursorTrackId == null
          ? -1
          : tracks.indexWhere((track) => track.id == _cursorTrackId);
      final ordered = cursorIndex < 0
          ? tracks
          : [...tracks.skip(cursorIndex + 1), ...tracks.take(cursorIndex + 1)];
      for (final track in ordered) {
        _cursorTrackId = track.id;
        if (track.filePath == null) continue;
        final related = existingTasks.where(
          (task) =>
              task.trackId == track.id &&
              task.audioRevision == track.audioRevision,
        );
        if (related.any(
          (task) =>
              task.status == MusicAnalysisTaskStatus.queued ||
              task.status == MusicAnalysisTaskStatus.running,
        )) {
          continue;
        }
        if (related.any(
          (task) =>
              task.status == MusicAnalysisTaskStatus.failed &&
              now.difference(task.updatedAt) <
                  _config.analysisFailureBackfillCooldown,
        )) {
          continue;
        }
        if (supportsEmotion) {
          final missingEmotion = await _queueAnalysis.missingRepresentations(
            track,
            representations: QueueMusicAnalysisUseCase.emotionRepresentations,
          );
          if (missingEmotion.isEmpty) continue;
        }
        final disposition = await _queueAnalysis(track);
        if (disposition == QueueMusicAnalysisDisposition.queued) queued++;
        if (queued >= _config.analysisBackfillBatchSize) break;
      }
      return queued;
    } finally {
      _running = false;
    }
  }
}
