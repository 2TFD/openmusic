import 'package:openmusic/layers/domain/entities/track.dart';

/// Commits a track and the follow-up work required for its audio source in one
/// database transaction.
abstract class TrackIngestionRepository {
  Future<Track> ingestRemote(Track track);

  Future<Track> ingestLocal(Track track, {required String filePath});
}
