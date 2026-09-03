import '../../../layers/domain/repositories/track_repository.dart';
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
  }) : _tracks = tracks,
       _queueAnalysis = queueAnalysis,
       _registry = registry,
       _config = config;

  final TrackRepository _tracks;
  final QueueMusicAnalysisUseCase _queueAnalysis;
  final MusicAnalysisModelRegistry _registry;
  final MusicAnalysisQueueConfig _config;
  DateTime? _lastRegistryRefresh;
  bool _running = false;

  @override
  Future<int> enqueueNextBatch() async {
    if (_running) return 0;
    _running = true;
    try {
      final now = DateTime.now();
      if (_lastRegistryRefresh == null ||
          now.difference(_lastRegistryRefresh!) >=
              _config.modelRegistryRefreshInterval) {
        await _registry.getModels(refresh: true);
        _lastRegistryRefresh = now;
      }
      var queued = 0;
      for (final track in await _tracks.getTracks()) {
        if (track.filePath == null) continue;
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
