import 'dart:async';

import 'package:owlsonic/layers/domain/repositories/track_download_completion_repository.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/usecases/queue_lyrics_resolution_use_case.dart';

class CompleteTrackDownloadUseCase {
  final TrackDownloadCompletionRepository repository;

  CompleteTrackDownloadUseCase(
    this.repository, {
    TrackRepository? tracks,
    QueueLyricsResolutionUseCase? queueLyrics,
    Future<void> Function(String trackId)? onDownloaded,
  }) : _tracks = tracks,
       _queueLyrics = queueLyrics,
       _onDownloaded = onDownloaded;

  final TrackRepository? _tracks;
  final QueueLyricsResolutionUseCase? _queueLyrics;

  /// Runs after a queued (link-imported) track finished downloading, e.g. to
  /// upload it to the signed-in cloud account. Never fails the download.
  final Future<void> Function(String trackId)? _onDownloaded;

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
    MediaLocator? media,
  }) async {
    final completed = await repository.completeClaimed(
      trackId: trackId,
      filePath: filePath,
      ownerId: ownerId,
      media: media,
    );
    if (completed) {
      await _queue(trackId);
      final onDownloaded = _onDownloaded;
      if (onDownloaded != null) unawaited(onDownloaded(trackId));
    }
    return completed;
  }

  Future<void> _queue(String trackId) async {
    final tracks = _tracks;
    if (tracks == null) return;
    final track = await tracks.getTrackById(trackId);
    if (track == null) return;
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
