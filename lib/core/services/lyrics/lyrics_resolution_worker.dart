import 'dart:async';

import '../../../layers/domain/entities/lyrics_resolution_state.dart';
import '../../../layers/domain/repositories/lyrics_resolution_task_repository.dart';
import '../../utils/app_logger.dart';
import 'lyrics_backfill_service.dart';
import 'lyrics_config.dart';
import 'lyrics_resolver.dart';

class LyricsResolutionWorker {
  LyricsResolutionWorker({
    required LyricsResolutionTaskRepository tasks,
    required LyricsResolver resolver,
    required LyricsBackfill backfill,
    required LyricsConfig config,
  }) : _tasks = tasks,
       _resolver = resolver,
       _backfill = backfill,
       _config = config;

  final LyricsResolutionTaskRepository _tasks;
  final LyricsResolver _resolver;
  final LyricsBackfill _backfill;
  final LyricsConfig _config;
  bool _running = false;
  Future<void>? _loop;

  Future<void> start() async {
    if (_loop != null) return;
    await _tasks.resetRunning();
    _running = true;
    final loop = _run();
    _loop = loop;
    unawaited(
      loop.whenComplete(() {
        if (identical(_loop, loop)) _loop = null;
      }),
    );
  }

  Future<void> _run() async {
    while (_running) {
      try {
        if (await processNext()) continue;
      } catch (error, stackTrace) {
        await AppLogger.captureException(
          error,
          stackTrace,
          operation: 'lyrics_resolution_worker.queue_loop',
          message: 'Lyrics resolution queue loop failed',
        );
      }
      if (_running) await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  Future<bool> processNext() async {
    final task = await _tasks.claimNext();
    if (task == null) return await _backfill.enqueueNextBatch() > 0;
    try {
      final state = await _resolver.resolve(task.trackId);
      if (state.status == LyricsResolutionStatus.failed) {
        final retryable =
            state.retryAt != null && task.attemptCount < _config.maxAttempts;
        await _tasks.fail(
          task.id,
          errorCode: state.failureCode ?? 'resolution_failed',
          errorMessage: null,
          requeue: retryable,
          retryAt: retryable ? state.retryAt : null,
        );
      } else {
        await _tasks.complete(task.id);
      }
    } catch (error, stackTrace) {
      await AppLogger.captureException(
        error,
        stackTrace,
        operation: 'lyrics_resolution_worker.resolve',
        message: 'Lyrics resolution failed unexpectedly',
      );
      await _tasks.fail(
        task.id,
        errorCode: 'unexpected',
        errorMessage: null,
        requeue: false,
      );
    }
    return true;
  }

  Future<void> stop() async {
    _running = false;
    await _loop;
  }
}
