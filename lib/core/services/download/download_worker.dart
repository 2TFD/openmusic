import 'dart:async';

import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';

class DownloadWorker {
  final DownloadTaskRepository downloadRepository;
  final TrackSourceResolver trackResolver;
  final CompleteTrackDownloadUseCase completeDownload;

  bool _isRunning = false;

  DownloadWorker({
    required this.downloadRepository,
    required this.trackResolver,
    required this.completeDownload,
  });

  void startProcessing() {
    _isRunning = true;
    _processQueue();
  }

  void stop() => _isRunning = false;

  Future<void> _processQueue() async {
    while (_isRunning) {
      final task = await downloadRepository.getNextQueued();
      if (task == null) {
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }

      await downloadRepository.markDownloading(task.trackId);
      final source = trackResolver.resolveByUrl(task.originalUrl);
      final preview = await source.fetchTrackPreview(task.originalUrl);
      final filePath = await source.download(preview);
      await completeDownload.call(trackId: task.trackId, filePath: filePath);
      await downloadRepository.markDone(task.trackId);
    }
  }
}
