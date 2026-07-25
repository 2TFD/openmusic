import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/clear_history_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_history_use_case.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase _getHistoryUseCase;
  final ClearHistoryUseCase _clearHistoryUseCase;

  HistoryBloc({
    required GetHistoryUseCase getHistoryUseCase,
    required ClearHistoryUseCase clearHistoryUseCase,
  }) : _getHistoryUseCase = getHistoryUseCase,
       _clearHistoryUseCase = clearHistoryUseCase,
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
      emit(HistoryError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final limit = state is HistoryLoaded
        ? (state as HistoryLoaded).count
        : 20;
    emit(const HistoryLoading());
    try {

      final historyTracks = await _getHistoryUseCase.execute(limit: limit);

      emit(
        HistoryLoaded(
          tracks: historyTracks,
          totalRecords: historyTracks.length,
        ),
      );
    } catch (e) {
      emit(HistoryError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _clearHistoryUseCase();
      emit(const HistoryLoaded(tracks: [], totalRecords: 0));
    } catch (e) {
      emit(HistoryError(failureFromException(e).toLocaleKey()));
    }
  }
}
