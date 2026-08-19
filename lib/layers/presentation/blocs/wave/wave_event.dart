part of 'wave_bloc.dart';

sealed class WaveEvent extends Equatable {
  const WaveEvent();
  @override
  List<Object> get props => [];
}

final class WaveInitialized extends WaveEvent {
  final WaveConfig config;
  const WaveInitialized(this.config);

  @override
  List<Object> get props => [config];
}

final class WaveConfigApplied extends WaveEvent {
  final WaveConfig config;
  const WaveConfigApplied(this.config);

  @override
  List<Object> get props => [config];
}

final class WaveSeedSelected extends WaveEvent {
  final String seed;
  const WaveSeedSelected(this.seed);

  @override
  List<Object> get props => [seed];
}

final class WaveSeedDeselected extends WaveEvent {
  final String seed;
  const WaveSeedDeselected(this.seed);

  @override
  List<Object> get props => [seed];
}

final class WaveRefreshRequested extends WaveEvent {}

final class WaveTrackSelected extends WaveEvent {
  final Track track;
  const WaveTrackSelected(this.track);

  @override
  List<Object> get props => [track];
}

final class WaveTrackDeselected extends WaveEvent {
  final Track track;
  const WaveTrackDeselected(this.track);

  @override
  List<Object> get props => [track];
}

final class WaveResetRequested extends WaveEvent {}
