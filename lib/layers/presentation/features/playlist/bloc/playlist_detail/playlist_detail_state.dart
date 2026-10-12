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
  final UiError? error;
  final bool isMutating;

  const PlaylistDetailLoaded({
    required this.playlist,
    required this.tracks,
    this.error,
    this.isMutating = false,
  });

  @override
  List<Object?> get props => [playlist, tracks, error, isMutating];
}

final class PlaylistDetailDeleted extends PlaylistDetailState {}

final class PlaylistDetailError extends PlaylistDetailState {
  final UiError error;
  const PlaylistDetailError(this.error);

  @override
  List<Object?> get props => [error];
}
