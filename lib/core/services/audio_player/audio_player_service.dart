import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:openmusic/core/infrastructure/mappers/track_audio_mapper.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';

class AudioPlayerService implements AudioPlayerPort {
  AudioPlayerService({required this.appDir});

  final String appDir;
  final AudioPlayer _player = AudioPlayer();
  @override
  Stream<Duration> get positionStream => _player.positionStream;
  @override
  Stream<Duration?> get durationStream => _player.durationStream;
  @override
  Stream<bool> get playingStream => _player.playingStream;
  @override
  Stream<int?> get indexStream => _player.currentIndexStream;
  @override
  Stream<PlaybackProcessingState> get processingStream =>
      _player.processingStateStream.map(_mapProcessingState);
  @override
  List<int>? get shuffleIndices => _player.shuffleIndices;

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e, st) {
      log('[AudioPlayerService.play] Error playing: $e, stackTrace: $st');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e, st) {
      log('[AudioPlayerService.pause] Error pausing: $e, stackTrace: $st');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e, st) {
      log(
        '[AudioPlayerService.seek] Error seeking to $position: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> seekToIndex(int index) async {
    try {
      await _player.seek(Duration.zero, index: index);
    } catch (e, st) {
      log(
        '[AudioPlayerService.seekToIndex] Error seeking to index $index: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      await _player.seekToNext();
    } catch (e, st) {
      log(
        '[AudioPlayerService.skipToNext] Error skipping to next: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _player.seekToPrevious();
    } catch (e, st) {
      log(
        '[AudioPlayerService.skipToPrevious] Error skipping to previous: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async {
    try {
      await _player.setLoopMode(switch (mode) {
        PlaybackLoopMode.off => LoopMode.off,
        PlaybackLoopMode.all => LoopMode.all,
        PlaybackLoopMode.one => LoopMode.one,
      });
    } catch (e, st) {
      log(
        '[AudioPlayerService.setLoopMode] Error setting loop mode to $mode: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> setShuffleModeEnabled(bool enabled) async {
    try {
      await _player.setShuffleModeEnabled(enabled);
    } catch (e, st) {
      log(
        '[AudioPlayerService.setShuffleModeEnabled] Error: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> setQueue(List<Track> tracks, {int index = 0}) async {
    try {
      await _player.stop();
      final sources = tracks.map((t) => t.toAudioSource(appDir)).toList();

      await _player.setAudioSources(sources, initialIndex: index);
    } catch (e, st) {
      log(
        '[AudioPlayerService.setQueue] Error setting queue: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() => _player.dispose();

  static PlaybackProcessingState _mapProcessingState(ProcessingState state) =>
      switch (state) {
        ProcessingState.idle => PlaybackProcessingState.idle,
        ProcessingState.loading => PlaybackProcessingState.loading,
        ProcessingState.buffering => PlaybackProcessingState.buffering,
        ProcessingState.ready => PlaybackProcessingState.ready,
        ProcessingState.completed => PlaybackProcessingState.completed,
      };
}
