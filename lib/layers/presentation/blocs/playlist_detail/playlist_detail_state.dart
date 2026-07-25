part of 'playlist_detail_bloc.dart';

sealed class PlaylistDetailState extends Equatable {
  const PlaylistDetailState();

  @override
  List<Object?> get props => [];
}

final class PlaylistDetailInitial extends PlaylistDetailState {}

final class PlaylistDetailLoading extends PlaylistDetailState {}

final class PlaylistDetailLoaded extends PlaylistDetailState {
  final Playlist playlist;
  final List<Track> tracks;
  final String? errorKey;

  const PlaylistDetailLoaded({
    required this.playlist,
    required this.tracks,
    this.errorKey,
  });

  @override
  List<Object?> get props => [playlist, tracks, errorKey];
}

final class PlaylistDetailDeleted extends PlaylistDetailState {}

final class PlaylistDetailError extends PlaylistDetailState {
  final String message;
  const PlaylistDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
