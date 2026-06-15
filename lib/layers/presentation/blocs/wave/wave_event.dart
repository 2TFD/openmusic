part of 'wave_bloc.dart';

sealed class WaveEvent extends Equatable {
  const WaveEvent();
  @override
  List<Object> get props => [];
}

final class WaveStarted extends WaveEvent {
  final WaveConfig config;
  const WaveStarted(this.config);
}

final class WaveSeedAdded extends WaveEvent {
  final String seed;
  const WaveSeedAdded(this.seed);
}

final class WaveSeedRemoved extends WaveEvent {
  final String seed;
  const WaveSeedRemoved(this.seed);
}

final class WaveMoodChanged extends WaveEvent {
  final String mood;
  const WaveMoodChanged(this.mood);
}

final class WaveRefreshed extends WaveEvent {}

final class WaveAddTrack extends WaveEvent {
  final Track track;
  const WaveAddTrack(this.track);
}

final class WaveRemoveTrack extends WaveEvent {
  final Track track;
  const WaveRemoveTrack(this.track);
}

final class WaveReset extends WaveEvent {}
