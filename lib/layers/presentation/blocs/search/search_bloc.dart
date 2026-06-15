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

  static const int _pageSize = 30;
  List<Track> _localCache = [];
  String _localCacheQuery = '';

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

    if (event.offset == 0 || event.query != _localCacheQuery) {
      emit(SearchLoading());
      try {
        _localCache = await searchUseCase.searchLocal(event.query);
        _localCacheQuery = event.query;
      } catch (e) {
        emit(SearchError(failureFromException(e).toLocaleKey()));
        return;
      }
    }

    final page = _localCache.skip(event.offset).take(_pageSize).toList();
    final existing = (event.offset > 0 && state is SearchLoaded)
        ? (state as SearchLoaded).tracks
        : <Track>[];

    emit(
      SearchLoaded(
        tracks: [...existing, ...page],
        isLocal: true,
        hasMore: event.offset + _pageSize < _localCache.length,
        currentOffset: event.offset,
      ),
    );
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
