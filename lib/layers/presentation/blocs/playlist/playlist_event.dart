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
}

class CreatePlaylistEvent extends PlaylistEvent {
  final Playlist playlist;
  const CreatePlaylistEvent(this.playlist);
}

class PlaylistErrorEvent extends PlaylistEvent {
  final String message;
  const PlaylistErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}
