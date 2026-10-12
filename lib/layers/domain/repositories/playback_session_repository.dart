import 'package:owlsonic/layers/domain/entities/playback_session.dart';

abstract class PlaybackSessionRepository {
  Future<PlaybackSession?> load();
  Future<void> replace(PlaybackSession session);
  Future<void> updatePlayback(PlaybackSession session);
  Future<void> clear();
}
