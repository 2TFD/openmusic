import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis_task.dart';
import 'package:owlsonic/layers/domain/repositories/music_analysis_task_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_emotion_repository.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';

void main() {
  test('emits active tasks and analyzed tracks', () async {
    final tasksRepo = _FakeMusicAnalysisTaskRepository();
    final emotionsRepo = _FakeTrackEmotionRepository();

    final cubit = MusicAnalysisStatusCubit(
      tasks: tasksRepo,
      emotions: emotionsRepo,
    );

    // Initial state
    expect(cubit.state.activeTasks, isEmpty);
    expect(cubit.state.analyzedTracks, isEmpty);

    cubit.initialize();

    // After microtask, it should load the initial analyzed tracks
    await Future.delayed(Duration.zero);
    expect(cubit.state.analyzedTracks, {'ready-track'});

    // Push new tasks
    tasksRepo.controller.add([
      MusicAnalysisTask(
        id: '1',
        trackId: 'analyzing-track',
        requestedRepresentations: const {},
        audioRevision: 1,
        status: MusicAnalysisTaskStatus.running,
        attemptCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);

    await Future.delayed(Duration.zero);
    expect(cubit.state.activeTasks.keys, {'analyzing-track'});
    expect(cubit.state.pendingCount, 1);

    // Push emotion changes
    emotionsRepo.controller.add(null);
    await Future.delayed(Duration.zero);
    expect(cubit.state.analyzedTracks, {'ready-track', 'new-ready'});

    await cubit.close();
  });
}

class _FakeMusicAnalysisTaskRepository implements MusicAnalysisTaskRepository {
  final controller = StreamController<List<MusicAnalysisTask>>.broadcast();

  @override
  Stream<List<MusicAnalysisTask>> watchAll() => controller.stream;

  @override
  Stream<int> watchPendingCount() =>
      controller.stream.map((list) => list.length);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTrackEmotionRepository implements TrackEmotionRepository {
  final controller = StreamController<void>.broadcast();
  int _callCount = 0;

  @override
  Stream<void> watchChanges() => controller.stream;

  @override
  Future<Set<String>> getAnalyzedTrackIds() async {
    _callCount++;
    if (_callCount == 1) return {'ready-track'};
    return {'ready-track', 'new-ready'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
