import '../entities/track.dart';

abstract class TrackRepository {
  Future<List<Track>> getTracks();
  Future<Track?> getTrackById(String id);
  Future<List<Track>> getTracksByIds(List<String> ids);
  Future<void> addTrack(Track track);
  Future<void> removeTrack(String trackId);
  Future<List<Track>> searchTracks(String query);
  Future<void> updateTrack(Track track);
  Stream<List<Track>> watchTracks();
}
