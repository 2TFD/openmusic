import '../entities/track.dart';

abstract class TrackRepository {
  Future<List<Track>> getTracks();
  Future<Track?> getTrackById(String id);
  Future<void> addTrack(Track track);
  Future<void> removeTrack(String trackId);
  Future<List<Track>> searchTracks(String query);
  Future<void> updateTrack(Track track);
  Future<void> updateTrackPathById({required String id, required String path});
  Future<void> updateTrackEmbeddingById({
    required String id,
    required List<double> vector,
  });
  Stream<dynamic> watchTracks();
}
