part of 'artist_detail_bloc.dart';

sealed class ArtistDetailState extends Equatable {
  const ArtistDetailState();

  @override
  List<Object?> get props => [];
}

final class ArtistDetailInitial extends ArtistDetailState {}

final class ArtistDetailLoading extends ArtistDetailState {}

final class ArtistDetailLoaded extends ArtistDetailState {
  const ArtistDetailLoaded({required this.artist, required this.tracks});

  final ArtistSummary artist;
  final List<Track> tracks;

  @override
  List<Object> get props => [artist, tracks];
}

final class ArtistDetailNotFound extends ArtistDetailState {}

final class ArtistDetailError extends ArtistDetailState {
  const ArtistDetailError(this.error);

  final UiError error;

  @override
  List<Object> get props => [error];
}
