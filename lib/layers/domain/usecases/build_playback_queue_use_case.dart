import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/track.dart';

class PlaybackQueue {
  final List<Track> tracks;
  final int startIndex;

  const PlaybackQueue({required this.tracks, required this.startIndex});

  bool get isEmpty => tracks.isEmpty;
}

class BuildPlaybackQueueUseCase {
  PlaybackQueue call(List<Track> tracks, {Track? startTrack}) {
    final queue = tracks.where((t) => t.isReadyToPlay).toList();
    if (queue.isEmpty) {
      return const PlaybackQueue(tracks: [], startIndex: 0);
    }
    if (startTrack == null) {
      return PlaybackQueue(tracks: queue, startIndex: 0);
    }
    final index = queue.indexWhere((t) => t.id == startTrack.id);
    if (index == -1) throw const TrackNotReadyFailure();
    return PlaybackQueue(tracks: queue, startIndex: index);
  }
}
