import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/usecases/clear_history_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/get_history_use_case.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase _getHistoryUseCase;
  final ClearHistoryUseCase _clearHistoryUseCase;

  HistoryBloc({
    required GetHistoryUseCase getHistoryUseCase,
    required ClearHistoryUseCase clearHistoryUseCase,
    Stream<void>? historyChanges,
  }) : _getHistoryUseCase = getHistoryUseCase,
       _clearHistoryUseCase = clearHistoryUseCase,
       super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<RefreshHistoryEvent>(_onRefreshHistory);
    on<ClearHistoryEvent>(_onClearHistory);
    // Plays arriving through sync (`history.append`) update Recently played.
    _changes = historyChanges
        ?.skip(1)
        .listen((_) => add(const RefreshHistoryEvent(quiet: true)));
  }

  StreamSubscription<void>? _changes;

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
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
    } catch (e, stackTrace) {
      emit(
        HistoryError(
          UiError.fromException(e, stackTrace, operation: 'history.load'),
        ),
      );
    }
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final limit = state is HistoryLoaded ? (state as HistoryLoaded).count : 20;
    if (!event.quiet) emit(const HistoryLoading());
    try {
      final historyTracks = await _getHistoryUseCase.execute(limit: limit);

      emit(
        HistoryLoaded(
          tracks: historyTracks,
          totalRecords: historyTracks.length,
        ),
      );
    } catch (e, stackTrace) {
      emit(
        HistoryError(
          UiError.fromException(e, stackTrace, operation: 'history.refresh'),
        ),
      );
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _clearHistoryUseCase();
      emit(const HistoryLoaded(tracks: [], totalRecords: 0));
    } catch (e, stackTrace) {
      emit(
        HistoryError(
          UiError.fromException(e, stackTrace, operation: 'history.clear'),
        ),
      );
    }
  }
}
