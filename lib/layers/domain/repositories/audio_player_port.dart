import 'package:openmusic/layers/domain/entities/track.dart';

enum PlaybackLoopMode { off, all, one }

enum PlaybackProcessingState { idle, loading, buffering, ready, completed }

abstract class AudioPlayerPort {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<bool> get playingStream;
  Stream<int?> get indexStream;
  Stream<PlaybackProcessingState> get processingStream;
  List<int>? get shuffleIndices;

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> seekToIndex(int index);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> setLoopMode(PlaybackLoopMode mode);
  Future<void> setShuffleModeEnabled(bool enabled);
  Future<void> setQueue(
    List<Track> tracks, {
    int index = 0,
    Duration initialPosition = Duration.zero,
  });
  Future<void> dispose();
}
