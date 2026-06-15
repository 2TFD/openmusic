part of 'playlist_detail_bloc.dart';

sealed class PlaylistDetailEvent extends Equatable {
  const PlaylistDetailEvent();

  @override
  List<Object> get props => [];
}

class PlaylistDetailLoad extends PlaylistDetailEvent {
  final String playlistId;
  const PlaylistDetailLoad(this.playlistId);

  @override
  List<Object> get props => [playlistId];
}

class PlaylistDetailRemoveTrack extends PlaylistDetailEvent {
  final String trackId;
  const PlaylistDetailRemoveTrack(this.trackId);

  @override
  List<Object> get props => [trackId];
}

class PlaylistDetailReorder extends PlaylistDetailEvent {
  final int oldIndex;
  final int newIndex;
  const PlaylistDetailReorder(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class PlaylistDetailRename extends PlaylistDetailEvent {
  final String name;
  const PlaylistDetailRename(this.name);

  @override
  List<Object> get props => [name];
}

class PlaylistDetailDelete extends PlaylistDetailEvent {
  const PlaylistDetailDelete();
}
