import '../../../layers/domain/entities/wave_session.dart';
import 'artist_wave_engine.dart';
import 'mood_wave_engine.dart';
import 'track_wave_engine.dart';
import 'wave_recommendation_config.dart';

class WaveRecommendationEngine {
  const WaveRecommendationEngine({
    required MoodWaveEngine mood,
    required TrackWaveEngine track,
    required ArtistWaveEngine artist,
    this.continuationConfig = const WaveContinuationConfig(),
  }) : _mood = mood,
       _track = track,
       _artist = artist;

  final MoodWaveEngine _mood;
  final TrackWaveEngine _track;
  final ArtistWaveEngine _artist;
  final WaveContinuationConfig continuationConfig;

  Future<WaveRecommendationBatch> generate({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) => switch (session.source) {
    MoodWaveSource() => _mood.generate(
      session: session,
      currentTrackId: currentTrackId,
      queuedTrackIds: queuedTrackIds,
    ),
    TrackWaveSource() => _track.generateWave(
      session: session,
      currentTrackId: currentTrackId,
      queuedTrackIds: queuedTrackIds,
    ),
    ArtistWaveSource() => _artist.generateWave(
      session: session,
      currentTrackId: currentTrackId,
      queuedTrackIds: queuedTrackIds,
    ),
  };
}
