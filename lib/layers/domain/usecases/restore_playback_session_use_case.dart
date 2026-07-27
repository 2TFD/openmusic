import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/repositories/playback_session_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class RestoredPlaybackSession extends Equatable {
  const RestoredPlaybackSession({
    required this.tracks,
    required this.startIndex,
    required this.position,
    required this.shuffleEnabled,
    required this.loopMode,
  });

  final List<Track> tracks;
  final int startIndex;
  final Duration position;
  final bool shuffleEnabled;
  final PlaybackLoopMode loopMode;

  @override
  List<Object?> get props => [
    tracks,
    startIndex,
    position,
    shuffleEnabled,
    loopMode,
  ];
}

class RestorePlaybackSessionUseCase {
  const RestorePlaybackSessionUseCase({
    required this.sessions,
    required this.tracks,
  });

  final PlaybackSessionRepository sessions;
  final TrackRepository tracks;

  Future<RestoredPlaybackSession?> call() async {
    final snapshot = await sessions.load();
    if (snapshot == null) return null;
    final storedTracks = await tracks.getTracksByIds(snapshot.queueTrackIds);
    final byId = {for (final track in storedTracks) track.id: track};
    final available = <({int originalPosition, Track track})>[];
    for (var index = 0; index < snapshot.queueTrackIds.length; index++) {
      final track = byId[snapshot.queueTrackIds[index]];
      if (track != null && track.isReadyToPlay) {
        available.add((originalPosition: index, track: track));
      }
    }
    if (available.isEmpty) {
      await sessions.clear();
      return null;
    }

    var startIndex = available.indexWhere(
      (entry) => entry.track.id == snapshot.currentTrackId,
    );
    if (startIndex == -1) {
      startIndex = available.indexWhere(
        (entry) => entry.originalPosition >= snapshot.currentQueuePosition,
      );
      if (startIndex == -1) startIndex = available.length - 1;
    }
    final selected = available[startIndex].track;
    var position = selected.id == snapshot.currentTrackId
        ? snapshot.position
        : Duration.zero;
    if (position < Duration.zero) position = Duration.zero;
    if (selected.duration > Duration.zero) {
      final latestUsefulPosition =
          selected.duration - const Duration(seconds: 3);
      if (position >= latestUsefulPosition) position = Duration.zero;
    }

    final cleanedIds = available.map((entry) => entry.track.id).toList();
    final cleaned = snapshot.copyWith(
      queueTrackIds: cleanedIds,
      currentTrackId: selected.id,
      currentQueuePosition: startIndex,
      position: position,
      updatedAt: DateTime.now(),
    );
    if (cleanedIds.length != snapshot.queueTrackIds.length ||
        selected.id != snapshot.currentTrackId ||
        startIndex != snapshot.currentQueuePosition ||
        position != snapshot.position) {
      await sessions.replace(cleaned);
    }

    return RestoredPlaybackSession(
      tracks: available.map((entry) => entry.track).toList(),
      startIndex: startIndex,
      position: position,
      shuffleEnabled: snapshot.shuffleEnabled,
      loopMode: snapshot.loopMode,
    );
  }
}
