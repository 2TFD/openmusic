import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/usecases/create_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_playlists_use_case.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final GetPlaylistsUseCase getPlaylistsUseCase;
  final AddTrackToPlaylistUseCase addTrackToPlaylistUseCase;
  final CreatePlaylistUseCase createPlaylistUseCase;

  StreamSubscription<List<Playlist>>? _changesSubscription;
  PlaylistBloc({
    required this.getPlaylistsUseCase,
    required this.addTrackToPlaylistUseCase,
    required this.createPlaylistUseCase,
    required Stream<List<Playlist>> playlistChangesStream,
  }) : super(PlaylistInitial()) {
    _changesSubscription = playlistChangesStream.listen(
      (e) {
        add(LoadPlaylistEvent());
      },
      onError: (error, stackTrace) {
        log(
          'Stream error: $error, stackTrace: $stackTrace',
          name: "PlaylistBloc",
        );
        add(_PlaylistStreamErrored(error));
      },
    );
    on<LoadPlaylistEvent>(_onLoad);
    on<AddTrackPlaylistEvent>(_onAdd);
    on<CreatePlaylistEvent>(_onCreate);
    on<_PlaylistStreamErrored>(
      (e, emit) =>
          emit(PlaylistError(failureFromException(e.error).toLocaleKey())),
    );
  }
  @override
  Future<void> close() {
    _changesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      final playlists = await getPlaylistsUseCase.call();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onAdd(
    AddTrackPlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      await addTrackToPlaylistUseCase(
        playlistId: event.playlistId,
        trackId: event.trackId,
      );
      add(LoadPlaylistEvent());
    } catch (e) {
      emit(PlaylistError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onCreate(
    CreatePlaylistEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      await createPlaylistUseCase(event.playlist);
      add(LoadPlaylistEvent());
    } catch (e) {
      emit(PlaylistError(failureFromException(e).toLocaleKey()));
    }
  }
}
