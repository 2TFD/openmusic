part of 'playlist_bloc.dart';

sealed class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

final class PlaylistLoaded extends PlaylistState {
  final List<PlaylistSummary> playlists;
  final bool isMutating;
  final String? completedOperationId;
  final String? failedOperationId;
  final UiError? error;

  const PlaylistLoaded(
    this.playlists, {
    this.isMutating = false,
    this.completedOperationId,
    this.failedOperationId,
    this.error,
  });

  @override
  List<Object?> get props => [
    playlists,
    isMutating,
    completedOperationId,
    failedOperationId,
    error,
  ];
}

final class PlaylistLoading extends PlaylistState {}

final class PlaylistError extends PlaylistState {
  final UiError error;
  const PlaylistError(this.error);

  @override
  List<Object> get props => [error];
}
