import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/embedding/embedding_engine.dart';
import 'package:openmusic/core/services/embedding/embedding_worker.dart';
import 'package:openmusic/layers/domain/entities/embedding_task.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';

void main() {
  test(
    'stop cancels in-flight work, releases its lease, and joins the loop',
    () async {
      final repository = _FakeEmbeddingTaskRepository();
      final engine = _BlockingEmbeddingEngine();
      final worker = EmbeddingWorker(
        repo: repository,
        engine: engine,
        ownerId: 'worker-a',
      );

      final processing = worker.start();
      await engine.started.future;
      worker.start();

      await worker.stop().timeout(const Duration(seconds: 1));
      await processing;

      expect(repository.claimCount, 1);
      expect(repository.released, isTrue);
      expect(repository.failed, isFalse);
    },
  );
}

class _BlockingEmbeddingEngine extends EmbeddingEngine {
  final started = Completer<void>();

  @override
  Future<List<double>> compute(
    String filePath, {
    OperationCancellation? cancellation,
  }) async {
    if (!started.isCompleted) started.complete();
    await cancellation!.whenCancelled;
    cancellation.throwIfCancelled();
    return const [];
  }
}

class _FakeEmbeddingTaskRepository implements EmbeddingTaskRepository {
  int claimCount = 0;
  bool released = false;
  bool failed = false;

  @override
  Future<EmbeddingTask?> claimNext({required String ownerId}) async {
    claimCount++;
    if (claimCount != 1) return null;
    return EmbeddingTask(
      id: 'embedding-1',
      trackId: 'track-1',
      status: EmbeddingStatus.processing,
      filePath: 'track-1.mp3',
      createdAt: DateTime.now(),
      audioRevision: 0,
    );
  }

  @override
  Future<bool> releaseLease({
    required String trackId,
    required String ownerId,
  }) async {
    released = true;
    return true;
  }

  @override
  Future<bool> markFailed({
    required String trackId,
    required String ownerId,
  }) async {
    failed = true;
    return true;
  }

  @override
  Future<bool> renewLease({
    required String trackId,
    required String ownerId,
  }) async => true;

  @override
  Future<bool> saveResult({
    required String trackId,
    required String ownerId,
    required int audioRevision,
    required List<double> vector,
  }) async => true;

  @override
  Stream<int> watchPendingCount() => const Stream.empty();
}
