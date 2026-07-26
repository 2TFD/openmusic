abstract class TrackRemovalRepository {
  /// Removes the track, its active background work and owned local assets.
  Future<void> removeTrack(String trackId);
}
