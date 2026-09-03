import 'dart:async';

import '../../../layers/domain/entities/music_analysis_failure.dart';
import '../../../layers/domain/repositories/music_analysis_repository.dart';
import '../../../layers/domain/repositories/music_analysis_task_repository.dart';
import '../../utils/app_logger.dart';
import 'music_analysis_backfill_service.dart';

class MusicAnalysisWorker {
  MusicAnalysisWorker({
    required MusicAnalysisTaskRepository tasks,
    required MusicAnalysisRepository analysis,
    required MusicAnalysisBackfill backfill,
  }) : _tasks = tasks,
       _analysis = analysis,
       _backfill = backfill;

  final MusicAnalysisTaskRepository _tasks;
  final MusicAnalysisRepository _analysis;
  final MusicAnalysisBackfill _backfill;
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
        await AppLogger.log(
          '[MusicAnalysisWorker] queue loop error: $error; '
          'stackTrace=$stackTrace',
        );
      }
      if (_running) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<bool> processNext() async {
    final task = await _tasks.claimNext();
    if (task == null) {
      return await _backfill.enqueueNextBatch() > 0;
    }
    try {
      await _analysis.analyzeTrack(
        trackId: task.trackId,
        audioRevision: task.audioRevision,
        representations: task.requestedRepresentations,
      );
      await _tasks.complete(task.id);
    } on MusicAnalysisFailure catch (failure, stackTrace) {
      await AppLogger.log(
        '[MusicAnalysisWorker] ${failure.kind}: ${failure.details}; '
        'stackTrace=$stackTrace',
      );
      await _tasks.fail(
        task.id,
        failure,
        requeue: failure.retryable && task.attemptCount < 3,
      );
      if (failure.retryable && task.attemptCount < 3 && _running) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[MusicAnalysisWorker] unknown: $error; stackTrace=$stackTrace',
      );
      await _tasks.fail(
        task.id,
        const MusicAnalysisFailure(MusicAnalysisFailureKind.unknown),
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
