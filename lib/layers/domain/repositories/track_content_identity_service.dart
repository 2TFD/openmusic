import '../entities/track_preview.dart';

abstract interface class TrackContentIdentityService {
  Future<String?> createFor(TrackPreview preview);

  Future<String> forLocalFile(String filePath);

  String forSoundCloudTrack(String trackId);
}
