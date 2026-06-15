import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

part 'playlist_detail_event.dart';
part 'playlist_detail_state.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  final PlaylistRepository playlistRepo;
  final TrackRepository trackRepo;

  PlaylistDetailBloc({
    required this.playlistRepo,
    required this.trackRepo,
  }) : super(PlaylistDetailInitial()) {
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
      final playlist = await playlistRepo.getPlaylistById(event.playlistId);
      if (playlist == null) throw Exception('Playlist not found');
      final loaded = await Future.wait(
        playlist.trackIds.map((id) => trackRepo.getTrackById(id)),
      );
      emit(PlaylistDetailLoaded(
        playlist: playlist,
        tracks: loaded.whereType<Track>().toList(),
      ));
    } catch (e, st) {
      log(e.toString(), stackTrace: st);
      emit(PlaylistDetailError(e.toString()));
    }
  }

  Future<void> _onRemoveTrack(
    PlaylistDetailRemoveTrack event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final newTracks = current.tracks
        .where((t) => t.id != event.trackId)
        .toList();
    final updated = current.playlist.copyWith(
      trackIds: newTracks.map((t) => t.id).toList(),
    );

    emit(PlaylistDetailLoaded(playlist: updated, tracks: newTracks));
    await playlistRepo.updatePlaylist(updated);
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

    final updated = current.playlist.copyWith(
      trackIds: list.map((t) => t.id).toList(),
    );

    emit(PlaylistDetailLoaded(playlist: updated, tracks: list));
    await playlistRepo.updatePlaylist(updated);
  }

  Future<void> _onRename(
    PlaylistDetailRename event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    final updated = current.playlist.copyWith(name: event.name);
    emit(PlaylistDetailLoaded(playlist: updated, tracks: current.tracks));
    await playlistRepo.updatePlaylist(updated);
  }

  Future<void> _onDelete(
    PlaylistDetailDelete event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final current = state;
    if (current is! PlaylistDetailLoaded) return;

    await playlistRepo.deletePlaylist(current.playlist.id);
    emit(PlaylistDetailDeleted());
  }
}
