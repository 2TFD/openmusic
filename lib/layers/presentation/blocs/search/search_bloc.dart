import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/usecases/search_use_case.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase searchUseCase;

  SearchBloc({required this.searchUseCase}) : super(SearchInitial()) {
    on<SearchLocalEvent>(_onSearchLocal);
    on<SearchExternalEvent>(_onSearchExternal);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchLocal(
    SearchLocalEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    if (event.offset == 0) {
      emit(SearchLoading());
    }

    try {
      final result = await searchUseCase.searchLocal(
        event.query,
        offset: event.offset,
      );

      final existing = (event.offset > 0 && state is SearchLoaded)
          ? (state as SearchLoaded).tracks
          : <Track>[];

      emit(
        SearchLoaded(
          tracks: [...existing, ...result.tracks],
          isLocal: true,
          hasMore: result.hasMore,
          currentOffset: result.offset,
        ),
      );
    } catch (e) {
      emit(SearchError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onSearchExternal(
    SearchExternalEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    if (event.offset == 0) {
      emit(SearchLoading());
    }

    try {
      final newResults = await searchUseCase.searchExternal(
        event.query,
        offset: event.offset,
      );

      final currentState = state;
      final allResults = event.offset == 0
          ? newResults
          : <TrackPreview>[
              ...(currentState is SearchLoaded
                  ? currentState.trackPreviews
                  : []),
              ...newResults,
            ];

      emit(
        SearchLoaded(
          trackPreviews: allResults,
          isLocal: false,
          hasMore: newResults.length >= 30,
          currentOffset: event.offset,
        ),
      );
    } catch (e) {
      emit(SearchError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }
}
