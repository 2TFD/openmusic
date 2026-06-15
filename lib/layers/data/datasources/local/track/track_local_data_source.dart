import 'package:openmusic/layers/data/DTO/track_dto.dart';

abstract class TrackLocalDataSource {
  Future<List<TrackDto>> getTracks();
  Future<TrackDto?> getTrackById(String id);
  Future<void> saveTrack(TrackDto track);
  Future<void> deleteTrackById(String trackId);
  Future<void> updateTrack(TrackDto track);
  Stream<dynamic> watchTracks();
}
