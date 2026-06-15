import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:openmusic/layers/domain/entities/track.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get indexStream => _player.currentIndexStream;
  Stream<ProcessingState> get processingStream => _player.processingStateStream;
  List<int>? get shuffleIndices => _player.shuffleIndices;

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e, st) {
      log('[AudioPlayerService.play] Error playing: $e, stackTrace: $st');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e, st) {
      log('[AudioPlayerService.pause] Error pausing: $e, stackTrace: $st');
      rethrow;
    }
  }

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

  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await _player.setLoopMode(mode);
    } catch (e, st) {
      log(
        '[AudioPlayerService.setLoopMode] Error setting loop mode to $mode: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

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

  Future<void> setQueue(
    List<Track> tracks,
    String appDir, {
    int index = 0,
  }) async {
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

  Future<void> dispose() => _player.dispose();
}
