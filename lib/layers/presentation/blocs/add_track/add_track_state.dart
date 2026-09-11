part of 'add_track_bloc.dart';

sealed class AddTrackState extends Equatable {
  const AddTrackState();

  @override
  List<Object?> get props => [];
}

final class AddTrackInitial extends AddTrackState {
  const AddTrackInitial();
}

final class AddTrackPreviewLoading extends AddTrackState {
  const AddTrackPreviewLoading();
}

final class AddTrackPreviewLoaded extends AddTrackState {
  final ResolvedTrackInput resolved;
  const AddTrackPreviewLoaded({required this.resolved});

  TrackPreview get preview => resolved.firstTrack;

  @override
  List<Object?> get props => [resolved];
}

final class AddTrackLoading extends AddTrackState {
  final ResolvedTrackInput resolved;
  const AddTrackLoading(this.resolved);

  TrackPreview get preview => resolved.firstTrack;

  @override
  List<Object?> get props => [resolved];
}

final class AddTrackSuccess extends AddTrackState {
  final Track track;
  final AddTrackResult result;
  final ResolvedTrackInput resolved;
  const AddTrackSuccess(
    this.track, {
    required this.result,
    required this.resolved,
  });

  @override
  List<Object?> get props => [
    track,
    result.addedTracks,
    result.failures,
    resolved,
  ];
}

final class AddTrackError extends AddTrackState {
  final UiError error;
  final TrackPreview? preview;
  const AddTrackError(this.error, {this.preview});

  @override
  List<Object?> get props => [error, preview];
}
