part of 'artist_detail_bloc.dart';

sealed class ArtistDetailEvent extends Equatable {
  const ArtistDetailEvent();

  @override
  List<Object?> get props => [];
}

final class ArtistDetailLoad extends ArtistDetailEvent {
  const ArtistDetailLoad(this.artistId);

  final String artistId;

  @override
  List<Object> get props => [artistId];
}

final class _ArtistDetailSnapshotReceived extends ArtistDetailEvent {
  const _ArtistDetailSnapshotReceived(this.artist);

  final ArtistSummary? artist;

  @override
  List<Object?> get props => [artist];
}

final class _ArtistDetailStreamErrored extends ArtistDetailEvent {
  const _ArtistDetailStreamErrored(this.error);

  final Object error;

  @override
  List<Object> get props => [error];
}
