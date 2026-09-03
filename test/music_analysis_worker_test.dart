import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_backfill_service.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_worker.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_failure.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_task.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_task_repository.dart';

void main() {
  test(
    'successful analysis task completes through MusicAnalysisRepository',
    () async {
      final tasks = _Tasks(_task());
      final analysis = _Analysis();
      final worker = MusicAnalysisWorker(
        tasks: tasks,
        analysis: analysis,
        backfill: _Backfill(),
      );

      expect(await worker.processNext(), isTrue);
      expect(analysis.calls, 1);
      expect(tasks.completed, ['task']);
      expect(tasks.failures, isEmpty);
    },
  );

  test(
    'retryable network failure requeues but invalid data does not',
    () async {
      final retryTasks = _Tasks(_task());
      final retryWorker = MusicAnalysisWorker(
        tasks: retryTasks,
        analysis: _Analysis(
          failure: const MusicAnalysisFailure(
            MusicAnalysisFailureKind.network,
            retryable: true,
          ),
        ),
        backfill: _Backfill(),
      );
      await retryWorker.processNext();
      expect(retryTasks.failures.single.requeue, isTrue);

      final terminalTasks = _Tasks(_task());
      final terminalWorker = MusicAnalysisWorker(
        tasks: terminalTasks,
        analysis: _Analysis(
          failure: const MusicAnalysisFailure(
            MusicAnalysisFailureKind.invalidRepresentation,
          ),
        ),
        backfill: _Backfill(),
      );
      await terminalWorker.processNext();
      expect(terminalTasks.failures.single.requeue, isFalse);
    },
  );
}

MusicAnalysisTask _task() => MusicAnalysisTask(
  id: 'task',
  trackId: 'track',
  requestedRepresentations: QueueMusicAnalysisRepresentations.values,
  audioRevision: 1,
  status: MusicAnalysisTaskStatus.running,
  attemptCount: 1,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

abstract final class QueueMusicAnalysisRepresentations {
  static const values = {
    MusicAnalysisRepresentation.audioGlobal,
    MusicAnalysisRepresentation.audioTemporal,
  };
}

class _Analysis implements MusicAnalysisRepository {
  _Analysis({this.failure});
  final MusicAnalysisFailure? failure;
  int calls = 0;

  @override
  Future<MusicAnalysisDisposition> analyzeTrack({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async {
    calls++;
    if (failure case final value?) throw value;
    return MusicAnalysisDisposition.analyzed;
  }

  @override
  Future<Set<MusicAnalysisRepresentation>> missingRepresentations({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async => representations;
}

class _Backfill implements MusicAnalysisBackfill {
  @override
  Future<int> enqueueNextBatch() async => 0;
}

class _Tasks implements MusicAnalysisTaskRepository {
  _Tasks(this.next);
  MusicAnalysisTask? next;
  int claims = 0;
  final List<String> completed = [];
  final List<({String id, MusicAnalysisFailure failure, bool requeue})>
  failures = [];

  @override
  Future<MusicAnalysisTask?> claimNext() async {
    claims++;
    final claimed = next;
    next = null;
    return claimed;
  }

  @override
  Future<void> complete(String id) async => completed.add(id);
  @override
  Future<void> fail(
    String id,
    MusicAnalysisFailure failure, {
    required bool requeue,
  }) async => failures.add((id: id, failure: failure, requeue: requeue));
  @override
  Future<List<MusicAnalysisTask>> getAll() async => const [];
  @override
  Future<void> enqueue({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async {}
  @override
  Future<void> resetRunning() async {}
  @override
  Future<void> retryFailed() async {}
  @override
  Stream<List<MusicAnalysisTask>> watchAll() => const Stream.empty();
  @override
  Stream<int> watchPendingCount() => const Stream.empty();
}
