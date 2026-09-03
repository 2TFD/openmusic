import 'package:openmusic/layers/domain/entities/listening_summary.dart';
import 'package:openmusic/layers/domain/entities/track.dart';

abstract class ListeningCheckpointRepository {
  Future<ListeningCheckpoint> save(Track track, Duration listenedDuration);
  Future<ListeningCheckpoint?> load();
  Future<void> clear(String id);
}
