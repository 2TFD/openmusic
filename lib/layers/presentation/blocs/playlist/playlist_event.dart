part of 'playlist_bloc.dart';

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaylistEvent extends PlaylistEvent {}

class AddTrackPlaylistEvent extends PlaylistEvent {
  final String playlistId;
  final String trackId;
  const AddTrackPlaylistEvent(this.playlistId, this.trackId);

  @override
  List<Object> get props => [playlistId, trackId];
}

class CreatePlaylistEvent extends PlaylistEvent {
  final Playlist playlist;
  const CreatePlaylistEvent(this.playlist);

  @override
  List<Object> get props => [playlist];
}

class _PlaylistStreamErrored extends PlaylistEvent {
  final Object error;
  const _PlaylistStreamErrored(this.error);

  @override
  List<Object> get props => [error];
}

