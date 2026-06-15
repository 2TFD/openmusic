part of 'wave_bloc.dart';

sealed class WaveState extends Equatable {
  const WaveState();

  @override
  List<Object> get props => [];
}

class WaveInitial extends WaveState {}

class WaveGenerating extends WaveState {
  final WaveConfig config;
  const WaveGenerating(this.config);
}

class WaveReady extends WaveState {
  final List<Track> tracks;
  final WaveConfig config;

  const WaveReady({required this.tracks, required this.config});
}

class WaveEmpty extends WaveState {
  final WaveConfig config;
  const WaveEmpty(this.config);
}

class WaveError extends WaveState {
  final String error;
  final WaveConfig config;
  const WaveError({required this.error, required this.config});
}
