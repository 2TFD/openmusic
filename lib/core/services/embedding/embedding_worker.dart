import 'dart:developer';

import 'package:openmusic/core/services/embedding/embedding_engine.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/repositories/embedding_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class EmbeddingWorker {
  final EmbeddingTaskRepository repo;
  final EmbeddingEngine engine;
  final TrackRepository trackRepository;

  bool _running = false;

  EmbeddingWorker({
    required this.repo,
    required this.engine,
    required this.trackRepository,
  });

  Future<void> start() async {
    _running = true;
    while (_running) {
      final task = await repo.getNextQueued();
      if (task == null) {
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }
      log(task.trackId, name: "EmbeddingWorker");
      await repo.markProcessing(task.trackId);

      try {
        final vector = await engine.compute(task.filePath);
        await trackRepository.updateTrackEmbeddingById(
          id: task.trackId,
          vector: vector,
        );
        await repo.saveResult(task.trackId, vector);
      } catch (e, st) {
        await repo.markFailed(task.trackId);
        AppLogger.log('Embedding error for track ${task.trackId}, $e, \n$st');
      }
    }
  }

  void stop() => _running = false;
}
