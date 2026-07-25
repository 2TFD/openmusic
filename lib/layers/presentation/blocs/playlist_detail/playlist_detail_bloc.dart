import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/delete_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_playlist_with_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_playlist_use_case.dart';

part 'playlist_detail_event.dart';
part 'playlist_detail_state.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  final GetPlaylistWithTracksUseCase _getPlaylistWithTracks;
  final UpdatePlaylistUseCase _updatePlaylist;
  final DeletePlaylistUseCase _deletePlaylist;

  PlaylistDetailBloc({
    required GetPlaylistWithTracksUseCase getPlaylistWithTracks,
    required UpdatePlaylistUseCase updatePlaylist,
    required DeletePlaylistUseCase deletePlaylist,
  }) : _getPlaylistWithTracks = getPlaylistWithTracks,
       _updatePlaylist = updatePlaylist,
       _deletePlaylist = deletePlaylist,
       super(PlaylistDetailInitial()) {
    on<PlaylistDetailLoad>(_onLoad);
    on<PlaylistDetailRemoveTrack>(_onRemoveTrack);
    on<PlaylistDetailReorder>(_onReorder);
    on<PlaylistDetailRename>(_onRename);
    on<PlaylistDetailDelete>(_onDelete);
  }

  Future<void> _onLoad(
    PlaylistDetailLoad event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    emit(PlaylistDetailLoading());
    try {
      final result = await _getPlaylistWithTracks(event.playlistId);
      if (emit.isDone) return;
      emit(PlaylistDetailLoaded(
        playlist: result.playlist,
        tracks: result.tracks,
      ));
    } catch (e) {
      if (emit.isDone) return;
      emit(PlaylistDetailError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onRemoveTrack(
    PlaylistDetailRemoveTrack event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final updated = _updatePlaylist.removeTrack(current.playlist, event.trackId);
    final newTracks =
        current.tracks.where((t) => t.id != event.trackId).toList();
    emit(PlaylistDetailLoaded(playlist: updated, tracks: newTracks));
    try {
      await _updatePlaylist(updated);
    } catch (e) {
      if (emit.isDone) return;
      emit(PlaylistDetailLoaded(
        playlist: current.playlist,
        tracks: current.tracks,
        errorKey: failureFromException(e).toLocaleKey(),
      ));
    }
  }

  Future<void> _onReorder(
    PlaylistDetailReorder event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    var newIndex = event.newIndex;
    if (newIndex > event.oldIndex) newIndex--;

    final list = List<Track>.from(current.tracks);
    list.insert(newIndex, list.removeAt(event.oldIndex));

    final updated = _updatePlaylist.reorderTracks(
      current.playlist,
      event.oldIndex,
      event.newIndex,
    );
    emit(PlaylistDetailLoaded(playlist: updated, tracks: list));
    try {
      await _updatePlaylist(updated);
    } catch (e) {
      if (emit.isDone) return;
      emit(PlaylistDetailLoaded(
        playlist: current.playlist,
        tracks: current.tracks,
        errorKey: failureFromException(e).toLocaleKey(),
      ));
    }
  }

  Future<void> _onRename(
    PlaylistDetailRename event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final updated = _updatePlaylist.rename(current.playlist, event.name);
    emit(PlaylistDetailLoaded(playlist: updated, tracks: current.tracks));
    try {
      await _updatePlaylist(updated);
    } catch (e) {
      if (emit.isDone) return;
      emit(PlaylistDetailLoaded(
        playlist: current.playlist,
        tracks: current.tracks,
        errorKey: failureFromException(e).toLocaleKey(),
      ));
    }
  }

  Future<void> _onDelete(
    PlaylistDetailDelete event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    try {
      await _deletePlaylist(current.playlist.id);
      if (emit.isDone) return;
      emit(PlaylistDetailDeleted());
    } catch (e) {
      if (emit.isDone) return;
      emit(PlaylistDetailError(failureFromException(e).toLocaleKey()));
    }
  }
}
