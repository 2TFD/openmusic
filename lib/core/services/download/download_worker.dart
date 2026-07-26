import 'dart:async';

import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/services/task_lease.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:uuid/uuid.dart';

class DownloadWorker {
  final DownloadTaskRepository downloadRepository;
  final TrackSourceResolver trackResolver;
  final CompleteTrackDownloadUseCase completeDownload;
  final String _ownerId;

  bool _isRunning = false;
  Future<void>? _processing;
  OperationCancellation? _inFlightCancellation;

  DownloadWorker({
    required this.downloadRepository,
    required this.trackResolver,
    required this.completeDownload,
    String? ownerId,
  }) : _ownerId = ownerId ?? const Uuid().v4();

  Future<void> startProcessing() {
    final active = _processing;
    if (active != null) return active;
    _isRunning = true;
    final processing = _processQueue();
    _processing = processing;
    return processing.whenComplete(() {
      if (identical(_processing, processing)) _processing = null;
      _isRunning = false;
    });
  }

  Future<void> stop() async {
    _isRunning = false;
    _inFlightCancellation?.cancel();
    await _processing;
  }

  Future<void> _processQueue() async {
    while (_isRunning) {
      DownloadTrackTask? task;
      OperationCancellation? cancellation;
      try {
        // Claiming includes the status transition. There is deliberately no
        // separate get-then-mark sequence (TOCTOU race).
        task = await downloadRepository.claimNext(ownerId: _ownerId);
        if (task == null) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        cancellation = OperationCancellation();
        _inFlightCancellation = cancellation;
        final source = trackResolver.resolveByUrl(task.originalUrl);
        final heartbeat = LeaseHeartbeat(
          interval: TaskLeasePolicy.heartbeatInterval,
          renew: () => downloadRepository.renewLease(
            trackId: task!.trackId,
            ownerId: _ownerId,
          ),
        );
        final filePath = await heartbeat.run(task.trackId, () async {
          final resolved = await source.resolve(task!.originalUrl);
          final preview = resolved.tracks.firstWhere(
            (preview) => preview.id == task!.trackId,
            orElse: () => resolved.firstTrack,
          );
          cancellation!.throwIfCancelled();
          return source.download(preview, cancellation: cancellation);
        });
        cancellation.throwIfCancelled();
        final completed = await completeDownload.completeClaimed(
          trackId: task.trackId,
          filePath: filePath,
          ownerId: _ownerId,
        );
        if (!completed) throw TaskLeaseLostException(task.trackId);
      } catch (e, st) {
        AppLogger.log(
          '[DownloadWorker] Error processing ${task?.trackId}: $e\n$st',
        );
        if (task != null) {
          final trackId = task.trackId;
          final terminalUpdate = cancellation?.isCancelled == true
              ? downloadRepository.releaseLease(
                  trackId: trackId,
                  ownerId: _ownerId,
                )
              : downloadRepository.markFailed(
                  trackId: trackId,
                  ownerId: _ownerId,
                );
          await terminalUpdate.catchError((e2) {
            AppLogger.log(
              '[DownloadWorker] terminal update failed for $trackId: $e2',
            );
            return false;
          });
        }
        if (_isRunning && cancellation?.isCancelled != true) {
          await Future.delayed(const Duration(seconds: 5));
        }
      } finally {
        if (identical(_inFlightCancellation, cancellation)) {
          _inFlightCancellation = null;
        }
      }
    }
  }
}
