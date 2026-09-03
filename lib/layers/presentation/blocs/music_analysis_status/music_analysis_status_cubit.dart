import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../domain/repositories/music_analysis_task_repository.dart';

class MusicAnalysisStatusState {
  const MusicAnalysisStatusState({this.pendingCount = 0});

  final int pendingCount;

  MusicAnalysisStatusState copyWith({int? pendingCount}) =>
      MusicAnalysisStatusState(pendingCount: pendingCount ?? this.pendingCount);
}

class MusicAnalysisStatusCubit extends Cubit<MusicAnalysisStatusState> {
  MusicAnalysisStatusCubit({required MusicAnalysisTaskRepository tasks})
    : _tasks = tasks,
      super(const MusicAnalysisStatusState());

  final MusicAnalysisTaskRepository _tasks;
  StreamSubscription<int>? _pendingSubscription;

  void initialize() {
    _pendingSubscription ??= _tasks.watchPendingCount().listen(
      (count) => emit(state.copyWith(pendingCount: count)),
    );
  }

  @override
  Future<void> close() async {
    await _pendingSubscription?.cancel();
    return super.close();
  }
}
