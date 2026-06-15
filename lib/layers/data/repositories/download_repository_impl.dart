import 'dart:async';

import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/repositories/download_repository.dart';
import 'package:background_downloader/background_downloader.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  @override
  Future<void> enqueueTrackTask(DownloadTrackTask trackTask) async {
    try {
      final task = DownloadTask(
        taskId: trackTask.trackId,
        url: trackTask.urlFile,
        filename: '${trackTask.trackId}.mp3',
        updates: Updates.statusAndProgress,
      );
      await FileDownloader().enqueue(task);
    } catch (e, st) {
      await AppLogger.log(
        "[DownloadRepositoryImpl.enqueueTrackTask] Error enqueueing download task for track ${trackTask.trackId}: $e, stackTrace: \n$st",
      );
      rethrow;
    }
  }
}
