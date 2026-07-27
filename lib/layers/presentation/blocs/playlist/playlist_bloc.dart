import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/usecases/create_playlist_use_case.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final CreatePlaylistUseCase createPlaylistUseCase;

  StreamSubscription<List<PlaylistSummary>>? _changesSubscription;
  PlaylistBloc({
    required this.createPlaylistUseCase,
    required Stream<List<PlaylistSummary>> playlistChangesStream,
  }) : super(PlaylistLoading()) {
    on<PlaylistEvent>(_onEvent, transformer: _sequential());

    _changesSubscription = playlistChangesStream.listen(
      (playlists) => add(_PlaylistSnapshotReceived(playlists)),
      onError: (error, stackTrace) {
        log(
          'Stream error: $error, stackTrace: $stackTrace',
          name: 'PlaylistBloc',
        );
        add(_PlaylistStreamErrored(error));
      },
    );
  }

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onEvent(
    PlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    switch (event) {
      case _PlaylistSnapshotReceived():
        emit(PlaylistLoaded(event.playlists));
        return;
      case CreatePlaylistEvent():
        await _onCreate(event, emit);
        return;
      case _PlaylistStreamErrored():
        _emitFailure(event.error, emit);
        return;
    }
  }

  Future<void> _onCreate(
    CreatePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    final playlists = _currentPlaylists;
    emit(PlaylistLoaded(playlists, isMutating: true));
    try {
      await createPlaylistUseCase(event.playlist);
      emit(PlaylistLoaded(playlists, completedOperationId: event.playlist.id));
    } catch (e) {
      _emitOperationFailure(e, event.playlist.id, playlists, emit);
    }
  }

  List<PlaylistSummary> get _currentPlaylists => switch (state) {
    PlaylistLoaded(:final playlists) => playlists,
    _ => const [],
  };

  void _emitOperationFailure(
    Object error,
    String operationId,
    List<PlaylistSummary> playlists,
    Emitter<PlaylistState> emit,
  ) {
    emit(
      PlaylistLoaded(
        playlists,
        failedOperationId: operationId,
        errorKey: failureFromException(error).toLocaleKey(),
      ),
    );
  }

  void _emitFailure(Object error, Emitter<PlaylistState> emit) {
    final key = failureFromException(error).toLocaleKey();
    final playlists = _currentPlaylists;
    if (state is PlaylistLoaded) {
      emit(PlaylistLoaded(playlists, errorKey: key));
    } else {
      emit(PlaylistError(key));
    }
  }
}

EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
