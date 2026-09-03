import 'package:openmusic/layers/domain/repositories/track_download_completion_repository.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/queue_music_analysis_use_case.dart';
import 'package:openmusic/layers/domain/usecases/queue_lyrics_resolution_use_case.dart';

class CompleteTrackDownloadUseCase {
  final TrackDownloadCompletionRepository repository;

  CompleteTrackDownloadUseCase(
    this.repository, {
    TrackRepository? tracks,
    QueueMusicAnalysisUseCase? queueAnalysis,
    QueueLyricsResolutionUseCase? queueLyrics,
  }) : _tracks = tracks,
       _queueAnalysis = queueAnalysis,
       _queueLyrics = queueLyrics;

  final TrackRepository? _tracks;
  final QueueMusicAnalysisUseCase? _queueAnalysis;
  final QueueLyricsResolutionUseCase? _queueLyrics;

  Future<void> completeLocal({
    required String trackId,
    required String filePath,
  }) async {
    await repository.completeLocal(trackId: trackId, filePath: filePath);
    await _queue(trackId);
  }

  Future<bool> completeClaimed({
    required String trackId,
    required String filePath,
    required String ownerId,
  }) async {
    final completed = await repository.completeClaimed(
      trackId: trackId,
      filePath: filePath,
      ownerId: ownerId,
    );
    if (completed) await _queue(trackId);
    return completed;
  }

  Future<void> _queue(String trackId) async {
    final tracks = _tracks;
    if (tracks == null) return;
    final track = await tracks.getTrackById(trackId);
    if (track == null) return;
    try {
      await _queueAnalysis?.call(track);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[CompleteTrackDownloadUseCase] Analysis queue failed for $trackId: '
        '$error, stackTrace: $stackTrace',
      );
    }
    try {
      await _queueLyrics?.call(track);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[CompleteTrackDownloadUseCase] Lyrics queue failed for $trackId: '
        '$error, stackTrace: $stackTrace',
      );
    }
  }
}
