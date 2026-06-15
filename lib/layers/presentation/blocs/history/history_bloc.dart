import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/get_history_use_case.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase _getHistoryUseCase;

  HistoryBloc({required GetHistoryUseCase getHistoryUseCase})
    : _getHistoryUseCase = getHistoryUseCase,
      super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<RefreshHistoryEvent>(_onRefreshHistory);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final historyTracks = await _getHistoryUseCase.execute(
        limit: event.limit,
      );

      emit(
        HistoryLoaded(
          tracks: historyTracks,
          totalRecords: historyTracks.length,
        ),
      );
    } catch (e) {
      emit(HistoryError('Failed to load history: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final limit = state is HistoryLoaded
          ? (state as HistoryLoaded).count
          : 20;

      final historyTracks = await _getHistoryUseCase.execute(limit: limit);

      emit(
        HistoryLoaded(
          tracks: historyTracks,
          totalRecords: historyTracks.length,
        ),
      );
    } catch (e) {
      emit(HistoryError('Failed to refresh history: ${e.toString()}'));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoaded(tracks: [], totalRecords: 0));
  }
}
