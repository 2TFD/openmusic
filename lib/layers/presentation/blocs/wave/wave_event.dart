part of 'wave_bloc.dart';

sealed class WaveEvent extends Equatable {
  const WaveEvent();
  @override
  List<Object> get props => [];
}

final class WaveInitialized extends WaveEvent {
  final WaveConfig config;
  const WaveInitialized(this.config);
}

final class WaveSeedSelected extends WaveEvent {
  final String seed;
  const WaveSeedSelected(this.seed);
}

final class WaveSeedDeselected extends WaveEvent {
  final String seed;
  const WaveSeedDeselected(this.seed);
}

final class WaveRefreshRequested extends WaveEvent {}

final class WaveTrackSelected extends WaveEvent {
  final Track track;
  const WaveTrackSelected(this.track);
}

final class WaveTrackDeselected extends WaveEvent {
  final Track track;
  const WaveTrackDeselected(this.track);
}

final class WaveResetRequested extends WaveEvent {}
