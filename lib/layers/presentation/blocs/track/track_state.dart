part of 'track_bloc.dart';

sealed class TrackState extends Equatable {
  const TrackState();

  @override
  List<Object> get props => [];
}

final class TrackInitial extends TrackState {}

final class TrackLoaded extends TrackState {
  final List<Track> tracks;
  const TrackLoaded(this.tracks);
}

final class TrackLoading extends TrackState {}

final class TrackError extends TrackState {
  final String error;
  const TrackError(this.error);
}
