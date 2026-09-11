part of 'player_bloc.dart';

// presentation/blocs/player/player_event.dart

sealed class PlayerEvent {}

class PlayerRestoreRequested extends PlayerEvent {}

class PlayerSessionFlushRequested extends PlayerEvent {}

// Публичные — вызываются из UI
class PlayerQueueSet extends PlayerEvent {
  final List<Track> tracks;
  final Track? startTrack;
  final bool autoPlay;
  PlayerQueueSet(this.tracks, {this.startTrack, this.autoPlay = true});
}

class PlayerMoodWaveStarted extends PlayerEvent {
  final double targetValence;
  final double targetArousal;
  final double radius;
  final MoodWaveMode mode;
  final bool autoPlay;

  PlayerMoodWaveStarted({
    required this.targetValence,
    required this.targetArousal,
    required this.radius,
    required this.mode,
    this.autoPlay = true,
  });
}

class PlayerTrackWaveStarted extends PlayerEvent {
  final Track track;
  final bool autoPlay;

  PlayerTrackWaveStarted({required this.track, this.autoPlay = true});
}

class PlayerArtistWaveStarted extends PlayerEvent {
  final String artistId;
  final String artistName;
  final String? imageUrl;
  final bool autoPlay;

  PlayerArtistWaveStarted({
    required this.artistId,
    required this.artistName,
    this.imageUrl,
    this.autoPlay = true,
  });
}

class PlayerWaveMoodSettingsUpdated extends PlayerEvent {
  final MoodWaveMode? mode;
  final double? radius;
  final double? targetValence;
  final double? targetArousal;

  PlayerWaveMoodSettingsUpdated({
    this.mode,
    this.radius,
    this.targetValence,
    this.targetArousal,
  });
}

class PlayerWaveStopped extends PlayerEvent {}

class PlayerWaveRetryRequested extends PlayerEvent {}

@Deprecated('Use PlayerWaveStopped')
class PlayerMoodWaveStopped extends PlayerEvent {}

class PlayerTrackRemoved extends PlayerEvent {
  final String trackId;
  final Completer<void>? completer;

  PlayerTrackRemoved(this.trackId, {this.completer});
}

class PlayerPlayPauseToggled extends PlayerEvent {}

class PlayerSeeked extends PlayerEvent {
  final Duration position;
  PlayerSeeked(this.position);
}

class PlayerTrackSelected extends PlayerEvent {
  final int index;
  PlayerTrackSelected({required this.index});
}

class PlayerSkippedNext extends PlayerEvent {}

class PlayerSkippedPrevious extends PlayerEvent {}

class PlayerShuffleToggled extends PlayerEvent {}

class PlayerRepeatCycled extends PlayerEvent {}

class PlayerErrorShown extends PlayerEvent {}

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
  final PlaybackProcessingState state;
  _PlayerProcessingUpdated(this.state);
}

class _PlayerPlaybackFailed extends PlayerEvent {
  final Object error;
  final StackTrace stackTrace;
  _PlayerPlaybackFailed(this.error, this.stackTrace);
}

/// Команда с экрана блокировки / наушников / Bluetooth. Приходит как обычное
/// событие, чтобы решение принималось на актуальном state, а не на том, каким
/// он был в момент нажатия.
class _PlayerSystemCommandReceived extends PlayerEvent {
  final PlaybackCommand command;
  _PlayerSystemCommandReceived(this.command);
}
