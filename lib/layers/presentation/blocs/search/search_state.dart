part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchLoaded extends SearchState {
  final List<Track> tracks;
  final List<TrackPreview> trackPreviews;
  final bool isLocal;
  final bool hasMore;
  final int currentOffset;

  const SearchLoaded({
    this.tracks = const [],
    this.trackPreviews = const [],
    required this.isLocal,
    this.hasMore = false,
    this.currentOffset = 0,
  });

  @override
  List<Object> get props => [
    tracks,
    trackPreviews,
    isLocal,
    hasMore,
    currentOffset,
  ];
}

final class SearchError extends SearchState {
  final String error;

  const SearchError(this.error);

  @override
  List<Object> get props => [error];
}
