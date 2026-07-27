import '../entities/track.dart';

abstract class TrackRepository {
  Future<List<Track>> getTracks();
  Future<Track?> getTrackById(String id);
  Future<List<Track>> getTracksByIds(List<String> ids);
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  });
  Future<void> updateMetadata(Track track);
  Stream<void> watchChanges();
}
