part of 'playlist_bloc.dart';

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaylisyEvent extends PlaylistEvent {}

class AddTrackPlaylisyEvent extends PlaylistEvent {
  final String playlistId;
  final String trackId;
  const AddTrackPlaylisyEvent(this.playlistId, this.trackId);
}

class CreatePlaylisyEvent extends PlaylistEvent {
  final Playlist playlist;
  const CreatePlaylisyEvent(this.playlist);
}

class PlaylistErrorEvent extends PlaylistEvent {
  final String message;
  const PlaylistErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}
