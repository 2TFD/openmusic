import '../entities/lyrics_resolution_state.dart';
import '../entities/track_lyrics.dart';

abstract interface class TrackLyricsRepository {
  Future<TrackLyrics?> getForTrack(String trackId);

  Future<void> save(TrackLyrics lyrics);

  Future<LyricsResolutionState?> getResolutionState(String trackId);

  Future<void> saveResolutionState(LyricsResolutionState state);

  Future<void> deleteForTrack(String trackId);
}
