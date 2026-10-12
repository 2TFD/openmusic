import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis_task.dart';
import 'package:owlsonic/layers/domain/repositories/music_analysis_task_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_emotion_repository.dart';

class MusicAnalysisStatusState {
  const MusicAnalysisStatusState({
    this.pendingCount = 0,
    this.activeTasks = const {},
    this.analyzedTracks = const {},
    this.cloudStatuses = const {},
  });

  final int pendingCount;
  final Map<String, MusicAnalysisTask> activeTasks;
  final Set<String> analyzedTracks;

  /// Backend `analysis_status` of OwlSonic cloud tracks. Authoritative for
  /// those tracks: legacy local analysis never marks them ready.
  final Map<String, String> cloudStatuses;

  bool isCloudAnalyzing(String trackId) => cloudStatuses[trackId] == 'pending';
  bool isCloudFailed(String trackId) => cloudStatuses[trackId] == 'failed';
  bool isAnalyzed(String trackId) => switch (cloudStatuses[trackId]) {
    null => analyzedTracks.contains(trackId),
    final status => status == 'ready',
  };

  MusicAnalysisStatusState copyWith({
    int? pendingCount,
    Map<String, MusicAnalysisTask>? activeTasks,
    Set<String>? analyzedTracks,
    Map<String, String>? cloudStatuses,
  }) => MusicAnalysisStatusState(
    pendingCount: pendingCount ?? this.pendingCount,
    activeTasks: activeTasks ?? this.activeTasks,
    analyzedTracks: analyzedTracks ?? this.analyzedTracks,
    cloudStatuses: cloudStatuses ?? this.cloudStatuses,
  );
}

class MusicAnalysisStatusCubit extends Cubit<MusicAnalysisStatusState> {
  MusicAnalysisStatusCubit({
    required MusicAnalysisTaskRepository tasks,
    required TrackEmotionRepository emotions,
    Stream<Map<String, String>>? cloudStatuses,
  }) : _tasks = tasks,
       _emotions = emotions,
       _cloudStatusChanges = cloudStatuses,
       super(const MusicAnalysisStatusState());

  final MusicAnalysisTaskRepository _tasks;
  final TrackEmotionRepository _emotions;
  StreamSubscription<List<MusicAnalysisTask>>? _tasksSubscription;
  StreamSubscription<void>? _emotionsSubscription;
  final Stream<Map<String, String>>? _cloudStatusChanges;
  StreamSubscription<Map<String, String>>? _cloudSubscription;

  void initialize() {
    _cloudSubscription ??= _cloudStatusChanges?.listen((statuses) {
      if (!isClosed) emit(state.copyWith(cloudStatuses: statuses));
    });
    _loadAnalyzed();
    _emotionsSubscription ??= _emotions.watchChanges().listen(
      (_) => _loadAnalyzed(),
    );
    _tasksSubscription ??= _tasks.watchAll().listen((items) {
      emit(
        state.copyWith(
          activeTasks: {for (final task in items) task.trackId: task},
          pendingCount: items.length,
        ),
      );
    });
  }

  Future<void> _loadAnalyzed() async {
    final ids = await _emotions.getAnalyzedTrackIds();
    if (isClosed) return;
    emit(state.copyWith(analyzedTracks: ids));
  }

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    await _emotionsSubscription?.cancel();
    await _cloudSubscription?.cancel();
    return super.close();
  }
}
