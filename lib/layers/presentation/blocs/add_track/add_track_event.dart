part of 'add_track_bloc.dart';

sealed class AddTrackEvent extends Equatable {
  const AddTrackEvent();

  @override
  List<Object?> get props => [];
}

final class FetchTrackPreview extends AddTrackEvent {
  final String url;
  const FetchTrackPreview(this.url);

  @override
  List<Object?> get props => [url];
}

final class AddTrackToLibrary extends AddTrackEvent {
  final ResolvedTrackInput resolved;
  const AddTrackToLibrary(this.resolved);

  @override
  List<Object?> get props => [resolved];
}

final class UseResolvedTrackInput extends AddTrackEvent {
  final ResolvedTrackInput resolved;
  const UseResolvedTrackInput(this.resolved);

  @override
  List<Object?> get props => [resolved];
}

final class ResetAddTrack extends AddTrackEvent {
  const ResetAddTrack();
}
