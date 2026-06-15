part of 'track_bloc.dart';

sealed class TrackEvent extends Equatable {
  const TrackEvent();

  @override
  List<Object> get props => [];
}

class LoadTracksEvent extends TrackEvent {}

class RemoveTrackEvent extends TrackEvent {
  final String trackId;

  const RemoveTrackEvent(this.trackId);

  @override
  List<Object> get props => [trackId];
}

class UpdateTrackEvent extends TrackEvent {
  final Track track;

  const UpdateTrackEvent(this.track);

  @override
  List<Object> get props => [track];
}

class TrackErrorEvent extends TrackEvent {
  final String message;

  const TrackErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}
