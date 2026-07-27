import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/delete_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_playlist_with_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_playlist_use_case.dart';

part 'playlist_detail_event.dart';
part 'playlist_detail_state.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  PlaylistDetailBloc({
    required GetPlaylistWithTracksUseCase getPlaylistWithTracks,
    required UpdatePlaylistUseCase updatePlaylist,
    required DeletePlaylistUseCase deletePlaylist,
    required AddTrackToPlaylistUseCase addTrack,
    required WatchPlaylistUseCase watchPlaylist,
    required Stream<void> trackChanges,
  }) : _getPlaylistWithTracks = getPlaylistWithTracks,
       _updatePlaylist = updatePlaylist,
       _deletePlaylist = deletePlaylist,
       _addTrack = addTrack,
       _watchPlaylist = watchPlaylist,
       _trackChanges = trackChanges,
       super(PlaylistDetailInitial()) {
    on<PlaylistDetailEvent>(_onEvent, transformer: _sequential());
  }

  final GetPlaylistWithTracksUseCase _getPlaylistWithTracks;
  final UpdatePlaylistUseCase _updatePlaylist;
  final DeletePlaylistUseCase _deletePlaylist;
  final AddTrackToPlaylistUseCase _addTrack;
  final WatchPlaylistUseCase _watchPlaylist;
  final Stream<void> _trackChanges;

  StreamSubscription<Playlist?>? _playlistSubscription;
  StreamSubscription<void>? _trackSubscription;
  bool _hasLoaded = false;

  @override
  Future<void> close() async {
    await _playlistSubscription?.cancel();
    await _trackSubscription?.cancel();
    return super.close();
  }

  Future<void> _onEvent(
    PlaylistDetailEvent event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    if (event is PlaylistDetailLoad) {
      await _onLoad(event, emit);
    } else if (event is PlaylistDetailAddTrack) {
      await _onAddTrack(event, emit);
    } else if (event is PlaylistDetailRemoveTrack) {
      await _onRemoveTrack(event, emit);
    } else if (event is PlaylistDetailReorder) {
      await _onReorder(event, emit);
    } else if (event is PlaylistDetailRename) {
      await _onRename(event, emit);
    } else if (event is PlaylistDetailDelete) {
      await _onDelete(emit);
    } else if (event is _PlaylistDetailSnapshotReceived) {
      await _onSnapshot(event, emit);
    } else if (event is _PlaylistTrackDataChanged) {
      await _refreshTracks(emit);
    } else if (event is _PlaylistDetailStreamErrored) {
      _emitFailure(event.error, emit);
    }
  }

  Future<void> _onLoad(
    PlaylistDetailLoad event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    emit(PlaylistDetailLoading());
    _hasLoaded = false;
    await _playlistSubscription?.cancel();
    await _trackSubscription?.cancel();
    _playlistSubscription = _watchPlaylist(event.playlistId).listen(
      (playlist) => add(_PlaylistDetailSnapshotReceived(playlist)),
      onError: (error, _) => add(_PlaylistDetailStreamErrored(error)),
    );
    _trackSubscription = _trackChanges.listen(
      (_) => add(const _PlaylistTrackDataChanged()),
      onError: (error, _) => add(_PlaylistDetailStreamErrored(error)),
    );
  }

  Future<void> _onSnapshot(
    _PlaylistDetailSnapshotReceived event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final playlist = event.playlist;
    if (playlist == null) {
      if (_hasLoaded) {
        emit(PlaylistDetailDeleted());
      } else {
        emit(
          PlaylistDetailError(const NotFoundFailure('playlist').toLocaleKey()),
        );
      }
      return;
    }

    try {
      final result = await _getPlaylistWithTracks.fromPlaylist(playlist);
      _hasLoaded = true;
      emit(
        PlaylistDetailLoaded(playlist: result.playlist, tracks: result.tracks),
      );
    } catch (error) {
      _emitFailure(error, emit);
    }
  }

  Future<void> _refreshTracks(Emitter<PlaylistDetailState> emit) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;
    try {
      final result = await _getPlaylistWithTracks.fromPlaylist(
        current.playlist,
      );
      emit(
        PlaylistDetailLoaded(playlist: result.playlist, tracks: result.tracks),
      );
    } catch (error) {
      _emitFailure(error, emit);
    }
  }

  Future<void> _onAddTrack(
    PlaylistDetailAddTrack event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;
    if (current.playlist.trackIds.contains(event.track.id)) return;

    emit(
      PlaylistDetailLoaded(
        playlist: current.playlist,
        tracks: current.tracks,
        isMutating: true,
      ),
    );
    try {
      await _addTrack(playlistId: current.playlist.id, trackId: event.track.id);
      emit(
        PlaylistDetailLoaded(
          playlist: current.playlist.copyWith(
            trackIds: [...current.playlist.trackIds, event.track.id],
            revision: current.playlist.revision + 1,
          ),
          tracks: [...current.tracks, event.track],
        ),
      );
    } catch (error) {
      _emitLoadedFailure(current, error, emit);
    }
  }

  Future<void> _onRemoveTrack(
    PlaylistDetailRemoveTrack event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final optimistic = current.playlist.copyWith(
      trackIds: current.playlist.trackIds
          .where((id) => id != event.trackId)
          .toList(),
      revision: current.playlist.revision + 1,
    );
    final tracks = current.tracks
        .where((track) => track.id != event.trackId)
        .toList();
    emit(PlaylistDetailLoaded(playlist: optimistic, tracks: tracks));
    try {
      await _updatePlaylist.removeTrack(current.playlist, event.trackId);
    } catch (error) {
      _emitLoadedFailure(current, error, emit);
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
    if (event.oldIndex < 0 ||
        event.oldIndex >= current.tracks.length ||
        newIndex < 0 ||
        newIndex >= current.tracks.length) {
      _emitLoadedFailure(current, RangeError('playlist reorder'), emit);
      return;
    }

    final tracks = List<Track>.from(current.tracks);
    tracks.insert(newIndex, tracks.removeAt(event.oldIndex));
    final ids = List<String>.from(current.playlist.trackIds);
    ids.insert(newIndex, ids.removeAt(event.oldIndex));
    final optimistic = current.playlist.copyWith(
      trackIds: ids,
      revision: current.playlist.revision + 1,
    );
    emit(PlaylistDetailLoaded(playlist: optimistic, tracks: tracks));
    try {
      await _updatePlaylist.reorderTracks(
        current.playlist,
        event.oldIndex,
        event.newIndex,
      );
    } catch (error) {
      _emitLoadedFailure(current, error, emit);
    }
  }

  Future<void> _onRename(
    PlaylistDetailRename event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final optimistic = current.playlist.copyWith(
      name: event.name,
      description: event.description,
      imageUrl: event.imageUrl,
      clearDescription: event.description == null,
      clearImageUrl: event.imageUrl == null,
      revision: current.playlist.revision + 1,
    );
    emit(PlaylistDetailLoaded(playlist: optimistic, tracks: current.tracks));
    try {
      await _updatePlaylist.updateMetadata(
        current.playlist,
        name: event.name,
        description: event.description,
        imageUrl: event.imageUrl,
        clearDescription: event.description == null,
        clearImageUrl: event.imageUrl == null,
      );
    } catch (error) {
      _emitLoadedFailure(current, error, emit);
    }
  }

  Future<void> _onDelete(Emitter<PlaylistDetailState> emit) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;
    try {
      await _deletePlaylist(current.playlist.id);
      emit(PlaylistDetailDeleted());
    } catch (error) {
      _emitLoadedFailure(current, error, emit);
    }
  }

  void _emitLoadedFailure(
    PlaylistDetailLoaded previous,
    Object error,
    Emitter<PlaylistDetailState> emit,
  ) {
    emit(
      PlaylistDetailLoaded(
        playlist: previous.playlist,
        tracks: previous.tracks,
        errorKey: failureFromException(error).toLocaleKey(),
      ),
    );
  }

  void _emitFailure(Object error, Emitter<PlaylistDetailState> emit) {
    final current = state;
    if (current is PlaylistDetailLoaded) {
      _emitLoadedFailure(current, error, emit);
    } else {
      emit(PlaylistDetailError(failureFromException(error).toLocaleKey()));
    }
  }
}

EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
