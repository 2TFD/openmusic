import 'dart:developer';

import 'package:openmusic/core/services/embedding/embedding_engine.dart';
import 'package:openmusic/core/services/task_lease.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';
import 'package:uuid/uuid.dart';

class EmbeddingWorker {
  final EmbeddingTaskRepository repo;
  final EmbeddingEngine engine;
  final String _ownerId;

  bool _isRunning = false;
  Future<void>? _processing;
  OperationCancellation? _inFlightCancellation;

  EmbeddingWorker({required this.repo, required this.engine, String? ownerId})
    : _ownerId = ownerId ?? const Uuid().v4();

  Future<void> start() {
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

  Future<void> _processQueue() async {
    while (_isRunning) {
      try {
        final task = await repo.claimNext(ownerId: _ownerId);
        if (task == null) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        log(task.trackId, name: "EmbeddingWorker");
        final cancellation = OperationCancellation();
        _inFlightCancellation = cancellation;
        try {
          final heartbeat = LeaseHeartbeat(
            interval: TaskLeasePolicy.heartbeatInterval,
            renew: () =>
                repo.renewLease(trackId: task.trackId, ownerId: _ownerId),
          );
          final vector = await heartbeat.run(
            task.trackId,
            () => engine.compute(task.filePath, cancellation: cancellation),
          );
          cancellation.throwIfCancelled();
          final saved = await repo.saveResult(
            trackId: task.trackId,
            ownerId: _ownerId,
            vector: vector,
          );
          if (!saved) throw TaskLeaseLostException(task.trackId);
        } catch (e, st) {
          AppLogger.log('Embedding error for track ${task.trackId}, $e, \n$st');
          try {
            if (cancellation.isCancelled) {
              await repo.releaseLease(trackId: task.trackId, ownerId: _ownerId);
            } else {
              await repo.markFailed(trackId: task.trackId, ownerId: _ownerId);
            }
          } catch (e2, st2) {
            AppLogger.log(
              '[EmbeddingWorker] markFailed failed for ${task.trackId}: $e2\n$st2',
            );
          }
        } finally {
          if (identical(_inFlightCancellation, cancellation)) {
            _inFlightCancellation = null;
          }
        }
      } catch (e, st) {
        AppLogger.log('[EmbeddingWorker] Unexpected error: $e\n$st');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    _inFlightCancellation?.cancel();
    await _processing;
  }
}
