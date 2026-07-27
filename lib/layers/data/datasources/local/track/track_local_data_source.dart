import 'package:openmusic/layers/data/models/track_dto.dart';

abstract class TrackLocalDataSource {
  Future<List<TrackDto>> getTracks();
  Future<List<TrackDto>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  });
  Future<TrackDto?> getTrackById(String id);
  Future<List<TrackDto>> getTracksByIds(List<String> ids);
  Future<void> saveTrack(TrackDto track);
  Future<bool> updateTrackMetadata(TrackDto track);
  Stream<void> watchChanges();
}
