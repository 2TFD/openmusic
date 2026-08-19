part of 'wave_bloc.dart';

sealed class WaveState extends Equatable {
  const WaveState();

  @override
  List<Object> get props => [];
}

class WaveInitial extends WaveState {}

class WaveGenerating extends WaveState {
  final WaveConfig config;
  final List<Track> previousTracks;

  const WaveGenerating(this.config, {this.previousTracks = const []});

  @override
  List<Object> get props => [config, previousTracks];
}

class WaveReady extends WaveState {
  final List<Track> tracks;
  final WaveConfig config;

  const WaveReady({required this.tracks, required this.config});

  @override
  List<Object> get props => [tracks, config];
}

class WaveEmpty extends WaveState {
  final WaveConfig config;
  const WaveEmpty(this.config);

  @override
  List<Object> get props => [config];
}

class WaveError extends WaveState {
  final String error;
  final WaveConfig config;
  final List<Track> previousTracks;

  const WaveError({
    required this.error,
    required this.config,
    this.previousTracks = const [],
  });

  @override
  List<Object> get props => [error, config, previousTracks];
}
