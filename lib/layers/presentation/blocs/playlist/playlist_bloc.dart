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

  StreamSubscription<dynamic>? _changesSubscription;
  PlaylistBloc({
    required this.getPlaylistsUseCase,
    required this.addTrackToPlaylistUseCase,
    required this.createPlaylistUseCase,
    required Stream<dynamic> playlistChangesStream,
  }) : super(PlaylistInitial()) {
    _changesSubscription = playlistChangesStream.listen(
      (e) {
        add(LoadPlaylisyEvent());
      },
      onError: (error, stackTrace) {
        log(
          'Stream error: $error, stackTrace: $stackTrace',
          name: "PlaylistBloc",
        );
        add(const PlaylistErrorEvent('Stream error occurred'));
      },
    );
    on<LoadPlaylisyEvent>(_onLoad);
    on<AddTrackPlaylisyEvent>(_onAdd);
    on<CreatePlaylisyEvent>(_onCreate);
    on<PlaylistErrorEvent>(_onPlaylistError);
  }
  @override
  Future<void> close() {
    _changesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadPlaylisyEvent event,
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
    AddTrackPlaylisyEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      addTrackToPlaylistUseCase(
        playlistId: event.playlistId,
        trackId: event.trackId,
      );
      add(LoadPlaylisyEvent());
    } catch (e) {
      emit(PlaylistError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onCreate(
    CreatePlaylisyEvent event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      await createPlaylistUseCase(event.playlist);
      add(LoadPlaylisyEvent());
    } catch (e) {
      emit(PlaylistError(failureFromException(e).toLocaleKey()));
    }
  }

  void _onPlaylistError(PlaylistErrorEvent event, Emitter<PlaylistState> emit) {
    emit(PlaylistError(event.message));
  }
}
