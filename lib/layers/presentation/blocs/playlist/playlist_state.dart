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
  final String? errorKey;

  const PlaylistLoaded(
    this.playlists, {
    this.isMutating = false,
    this.completedOperationId,
    this.failedOperationId,
    this.errorKey,
  });

  @override
  List<Object?> get props => [
    playlists,
    isMutating,
    completedOperationId,
    failedOperationId,
    errorKey,
  ];
}

final class PlaylistLoading extends PlaylistState {}

final class PlaylistError extends PlaylistState {
  final String error;
  const PlaylistError(this.error);

  @override
  List<Object> get props => [error];
}
