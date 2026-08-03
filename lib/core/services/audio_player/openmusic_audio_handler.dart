import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openmusic/core/services/audio_player/audio_player_service.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';

/// Адаптер между системной media session и приложением.
///
/// Команды (экран блокировки, наушники, Bluetooth) не трогают плеер напрямую —
/// они уходят в [PlaybackCommandBus], где решение принимает PlayerBloc через
/// SkipTrackUseCase. В обратную сторону handler только зеркалит состояние
/// плеера в нотификацию.
class OpenmusicAudioHandler extends BaseAudioHandler with SeekHandler {
  OpenmusicAudioHandler({
    required AudioPlayerService player,
    required PlaybackCommandBus commands,
  }) : _player = player.rawPlayer,
       _commands = commands {
    _subscribe();
  }

  final AudioPlayer _player;
  final PlaybackCommandBus _commands;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  List<String> _queueIds = const [];

  // Входящие команды: только формулируем намерение, решение принимает блок.

  @override
  Future<void> play() async => _commands.send(const PlayRequested());

  @override
  Future<void> pause() async => _commands.send(const PauseRequested());

  @override
  Future<void> stop() async => _commands.send(const StopRequested());

  @override
  Future<void> skipToNext() async => _commands.send(const SkipNextRequested());

  @override
  Future<void> skipToPrevious() async =>
      _commands.send(const SkipPreviousRequested());

  /// Покрывает и fastForward/rewind: [SeekHandler] выражает их через seek.
  @override
  Future<void> seek(Duration position) async =>
      _commands.send(SeekRequested(position));

  @override
  Future<void> skipToQueueItem(int index) async =>
      _commands.send(QueueItemRequested(index));

  // Исходящее состояние: плеер → media session.

  void _subscribe() {
    _subscriptions.addAll([
      _player.playbackEventStream.listen(
        (_) => _broadcastState(),
        onError: (Object e, StackTrace st) => AppLogger.log(
          '[OpenmusicAudioHandler] playbackEventStream error: '
          '$e, stackTrace: $st',
        ),
      ),
      _player.playingStream.listen(
        (_) => _broadcastState(),
        onError: (Object e, StackTrace st) => AppLogger.log(
          '[OpenmusicAudioHandler] playingStream error: $e, stackTrace: $st',
        ),
      ),
      _player.sequenceStateStream.listen(
        _onSequenceState,
        onError: (Object e, StackTrace st) => AppLogger.log(
          '[OpenmusicAudioHandler] sequenceStateStream error: '
          '$e, stackTrace: $st',
        ),
      ),
      // Длительность из Track может расходиться с реальной — иначе скраббер на
      // экране блокировки врёт.
      _player.durationStream.listen(
        _onDuration,
        onError: (Object e, StackTrace st) => AppLogger.log(
          '[OpenmusicAudioHandler] durationStream error: $e, stackTrace: $st',
        ),
      ),
    ]);
  }

  void _onSequenceState(SequenceState state) {
    final items = state.sequence
        .map((source) => source.tag)
        .whereType<MediaItem>()
        .toList();
    final ids = items.map((item) => item.id).toList();
    if (!_sameIds(_queueIds, ids)) {
      _queueIds = ids;
      queue.add(items);
    }
    final current = state.currentSource?.tag;
    if (current is MediaItem && mediaItem.value?.id != current.id) {
      mediaItem.add(current);
    }
    _broadcastState();
  }

  void _onDuration(Duration? duration) {
    final current = mediaItem.value;
    if (current == null || duration == null || duration <= Duration.zero) return;
    if (current.duration == duration) return;
    mediaItem.add(current.copyWith(duration: duration));
  }

  void _broadcastState() {
    playbackState.add(
      playbackState.value.copyWith(
        // skipToPrevious всегда доступна: на первом треке она перематывает
        // трек в начало, поэтому скрывать её нельзя.
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
        repeatMode: switch (_player.loopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.all => AudioServiceRepeatMode.all,
          LoopMode.one => AudioServiceRepeatMode.one,
        },
        shuffleMode: _player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  static bool _sameIds(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
