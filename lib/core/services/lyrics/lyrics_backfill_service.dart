import '../../../layers/domain/entities/lyrics_resolution_state.dart';
import '../../../layers/domain/repositories/lyrics_resolution_task_repository.dart';
import '../../../layers/domain/repositories/track_lyrics_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import 'lyrics_config.dart';

abstract interface class LyricsBackfill {
  Future<int> enqueueNextBatch();
}

class LyricsBackfillService implements LyricsBackfill {
  LyricsBackfillService({
    required TrackRepository tracks,
    required TrackLyricsRepository lyrics,
    required LyricsResolutionTaskRepository tasks,
    required LyricsConfig config,
  }) : _tracks = tracks,
       _lyrics = lyrics,
       _tasks = tasks,
       _config = config;

  final TrackRepository _tracks;
  final TrackLyricsRepository _lyrics;
  final LyricsResolutionTaskRepository _tasks;
  final LyricsConfig _config;
  bool _running = false;

  @override
  Future<int> enqueueNextBatch() async {
    if (_running) return 0;
    _running = true;
    try {
      var queued = 0;
      for (final track in await _tracks.getTracks()) {
        if (track.filePath == null) continue;
        final state = await _lyrics.getResolutionState(track.id);
        if (state != null &&
            state.status != LyricsResolutionStatus.unknown &&
            state.metadataRevision == track.metadataRevision) {
          continue;
        }
        await _tasks.enqueue(track.id);
        queued++;
        if (queued >= _config.backfillBatchSize) break;
      }
      return queued;
    } finally {
      _running = false;
    }
  }
}
