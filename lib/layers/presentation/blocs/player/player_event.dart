part of 'player_bloc.dart';

// presentation/blocs/player/player_event.dart

sealed class PlayerEvent {}

// Публичные — вызываются из UI
class PlayerQueueSet extends PlayerEvent {
  final List<Track> tracks;
  final int startIndex;
  PlayerQueueSet(this.tracks, {this.startIndex = 0});
}

class PlayerPlayPauseToggled extends PlayerEvent {}

class PlayerSeeked extends PlayerEvent {
  final Duration position;
  PlayerSeeked(this.position);
}

class PlayerIndexSeeked extends PlayerEvent {
  final List<Track>? tracks;
  final int index;
  PlayerIndexSeeked({required this.index, this.tracks});
}

class PlayerSkippedNext extends PlayerEvent {}

class PlayerSkippedPrevious extends PlayerEvent {}

class PlayerShuffleToggled extends PlayerEvent {}

class PlayerRepeatCycled extends PlayerEvent {}

// Внутренние — только от стримов, UI не трогает
class _PlayerPositionUpdated extends PlayerEvent {
  final Duration position;
  _PlayerPositionUpdated(this.position);
}

class _PlayerDurationUpdated extends PlayerEvent {
  final Duration duration;
  _PlayerDurationUpdated(this.duration);
}

class _PlayerPlayingUpdated extends PlayerEvent {
  final bool playing;
  _PlayerPlayingUpdated(this.playing);
}

class _PlayerIndexUpdated extends PlayerEvent {
  final int index;
  _PlayerIndexUpdated(this.index);
}

class _PlayerProcessingUpdated extends PlayerEvent {
  final ProcessingState state;
  _PlayerProcessingUpdated(this.state);
}
