part of 'playlist_detail_bloc.dart';

sealed class PlaylistDetailEvent extends Equatable {
  const PlaylistDetailEvent();

  @override
  List<Object?> get props => [];
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

class PlaylistDetailAddTrack extends PlaylistDetailEvent {
  final Track track;

  const PlaylistDetailAddTrack(this.track);

  @override
  List<Object> get props => [track];
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
  final String? description;
  final String? imageUrl;

  const PlaylistDetailRename({
    required this.name,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, imageUrl];
}

class PlaylistDetailDelete extends PlaylistDetailEvent {
  const PlaylistDetailDelete();
}

class _PlaylistDetailSnapshotReceived extends PlaylistDetailEvent {
  final Playlist? playlist;

  const _PlaylistDetailSnapshotReceived(this.playlist);

  @override
  List<Object> get props => [?playlist];
}

class _PlaylistTrackDataChanged extends PlaylistDetailEvent {
  const _PlaylistTrackDataChanged();
}

class _PlaylistDetailStreamErrored extends PlaylistDetailEvent {
  final Object error;

  const _PlaylistDetailStreamErrored(this.error);

  @override
  List<Object> get props => [error];
}
