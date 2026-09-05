import '../../../core/services/music_analysis/music_analysis_model_registry.dart';
import '../../domain/entities/mood_map.dart';
import '../../domain/entities/music_analysis.dart';
import '../../domain/entities/track_emotion_analysis.dart';
import '../../domain/repositories/mood_map_repository.dart';
import '../../domain/repositories/track_emotion_repository.dart';
import '../../domain/repositories/track_repository.dart';
import '../database/app_database.dart';

class MoodMapRepositoryImpl implements MoodMapRepository {
  MoodMapRepositoryImpl({
    required this.database,
    required TrackRepository tracks,
    required TrackEmotionRepository emotions,
    required MusicAnalysisModelRegistry registry,
  }) : _tracks = tracks,
       _emotions = emotions,
       _registry = registry;

  final AppDatabase database;
  final TrackRepository _tracks;
  final TrackEmotionRepository _emotions;
  final MusicAnalysisModelRegistry _registry;

  @override
  Future<List<MoodMapTrack>> loadTracks() async {
    final models = await _registry.getModels();
    final model = models.find(MusicAnalysisRepresentation.audioEmotionGlobal);
    if (model == null) return const [];
    final allTracks = await _tracks.getTracks();
    final trackById = {for (final track in allTracks) track.id: track};
    final analyses = await _emotions.getGlobalsByPipeline(
      modelId: model.modelId,
      modelVersion: model.modelVersion,
      preprocessingVersion: model.preprocessingVersion,
    );
    final adjustmentRows = await database
        .select(database.personalMoodAdjustmentTable)
        .get();
    final adjustments = {
      for (final row in adjustmentRows)
        row.trackId: PersonalMoodAdjustment(
          trackId: row.trackId,
          valence: row.valence,
          arousal: row.arousal,
          updatedAt: row.updatedAt,
        ),
    };
    final result = <MoodMapTrack>[];
    for (final analysis in analyses) {
      final track = trackById[analysis.trackId];
      if (track == null ||
          analysis.audioRevision != track.audioRevision ||
          analysis.contentRevision != emotionContentRevisionFor(track)) {
        continue;
      }
      result.add(
        MoodMapTrack(
          track: track,
          modelAnalysis: analysis,
          personalAdjustment: adjustments[track.id],
        ),
      );
    }
    result.sort((a, b) => a.track.title.compareTo(b.track.title));
    return result;
  }

  @override
  Stream<void> watchChanges() => database
      .customSelect(
        '''
SELECT e.id, p.updated_at, t.audio_revision, t.content_identity
FROM track_emotion_analysis_table e
JOIN track_table t ON t.id = e.track_id
LEFT JOIN personal_mood_adjustment_table p ON p.track_id = e.track_id
''',
        readsFrom: {
          database.trackEmotionAnalysisTable,
          database.personalMoodAdjustmentTable,
          database.trackTable,
        },
      )
      .watch()
      .map((_) {});

  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async {
    if (!_inRange(adjustment.valence) || !_inRange(adjustment.arousal)) {
      throw ArgumentError('Personal mood position must be inside [-1, 1]');
    }
    await database
        .into(database.personalMoodAdjustmentTable)
        .insertOnConflictUpdate(
          PersonalMoodAdjustmentTableCompanion.insert(
            trackId: adjustment.trackId,
            valence: adjustment.valence,
            arousal: adjustment.arousal,
            updatedAt: adjustment.updatedAt,
          ),
        );
  }

  @override
  Future<void> resetPersonalPosition(String trackId) => (database.delete(
    database.personalMoodAdjustmentTable,
  )..where((table) => table.trackId.equals(trackId))).go();

  static bool _inRange(double value) =>
      value.isFinite && value >= -1 && value <= 1;
}
