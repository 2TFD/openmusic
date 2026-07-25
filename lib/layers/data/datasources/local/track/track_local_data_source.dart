import 'package:openmusic/layers/data/DTO/track_dto.dart';

abstract class TrackLocalDataSource {
  Future<List<TrackDto>> getTracks();
  Future<List<TrackDto>> searchTracks(String query);
  Future<TrackDto?> getTrackById(String id);
  Future<List<TrackDto>> getTracksByIds(List<String> ids);
  Future<void> saveTrack(TrackDto track);
  Future<void> deleteTrackById(String trackId);
  Future<void> updateTrack(TrackDto track);
  Stream<List<TrackDto>> watchTracks();
}
