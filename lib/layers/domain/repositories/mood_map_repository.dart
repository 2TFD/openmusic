import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';

abstract interface class MoodMapRepository {
  Future<List<MoodMapTrack>> loadTracks();
  Stream<void> watchChanges();
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment);
  Future<void> resetPersonalPosition(String trackId);
}
