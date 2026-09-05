import '../entities/mood_map.dart';
import '../entities/track_emotion_analysis.dart';

abstract interface class MoodMapRepository {
  Future<List<MoodMapTrack>> loadTracks();
  Stream<void> watchChanges();
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment);
  Future<void> resetPersonalPosition(String trackId);
}
