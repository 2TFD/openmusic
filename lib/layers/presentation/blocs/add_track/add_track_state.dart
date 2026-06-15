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
  final TrackPreview preview;
  const AddTrackPreviewLoaded({required this.preview});

  @override
  List<Object?> get props => [preview];
}

final class AddTrackLoading extends AddTrackState {
  final TrackPreview preview;
  const AddTrackLoading(this.preview);

  @override
  List<Object?> get props => [preview];
}

final class AddTrackSuccess extends AddTrackState {
  final Track track;
  const AddTrackSuccess(this.track);

  @override
  List<Object?> get props => [track];
}

final class AddTrackError extends AddTrackState {
  final String message;
  final TrackPreview? preview;
  const AddTrackError(this.message, {this.preview});

  @override
  List<Object?> get props => [message, preview];
}
