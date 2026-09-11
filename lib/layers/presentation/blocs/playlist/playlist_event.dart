part of 'playlist_bloc.dart';

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

class CreatePlaylistEvent extends PlaylistEvent {
  final Playlist playlist;
  const CreatePlaylistEvent(this.playlist);

  @override
  List<Object> get props => [playlist];
}

class _PlaylistStreamErrored extends PlaylistEvent {
  final Object error;
  final StackTrace stackTrace;
  const _PlaylistStreamErrored(this.error, this.stackTrace);

  @override
  List<Object> get props => [error, stackTrace];
}

class _PlaylistSnapshotReceived extends PlaylistEvent {
  final List<PlaylistSummary> playlists;

  const _PlaylistSnapshotReceived(this.playlists);

  @override
  List<Object> get props => [playlists];
}
