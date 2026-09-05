import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/music_analysis.dart';
import '../../domain/entities/track_emotion_analysis.dart';
import '../../domain/repositories/track_emotion_repository.dart';
import '../database/app_database.dart';

class TrackEmotionRepositoryImpl implements TrackEmotionRepository {
  TrackEmotionRepositoryImpl(this.database);

  static const _codecVersion = 1;
  final AppDatabase database;

  @override
  Future<void> saveGlobal(TrackEmotionAnalysis analysis) async {
    await database
        .into(database.trackEmotionAnalysisTable)
        .insertOnConflictUpdate(
          TrackEmotionAnalysisTableCompanion.insert(
            id: analysis.id,
            trackId: analysis.trackId,
            representation: analysis.representation,
            modelId: analysis.modelId,
            modelVersion: analysis.modelVersion,
            preprocessingVersion: analysis.preprocessingVersion,
            contentRevision: analysis.contentRevision,
            audioRevision: analysis.audioRevision,
            valence: Value(analysis.valence),
            arousal: Value(analysis.arousal),
            rawValence: Value(analysis.rawValence),
            rawArousal: Value(analysis.rawArousal),
            moodDistributionJson: Value(_encodeMood(analysis.moodDistribution)),
            analyzedAt: analysis.analyzedAt,
          ),
        );
  }

  @override
  Future<void> saveTemporal(TrackEmotionTemporalAnalysis analysis) {
    return database.transaction(() async {
      final existing = await _findRow(
        trackId: analysis.trackId,
        representation: analysis.representation,
        modelId: analysis.modelId,
        modelVersion: analysis.modelVersion,
        preprocessingVersion: analysis.preprocessingVersion,
        contentRevision: analysis.contentRevision,
        audioRevision: analysis.audioRevision,
      );
      final persistedId = existing?.id ?? analysis.id;
      await database
          .into(database.trackEmotionAnalysisTable)
          .insertOnConflictUpdate(
            TrackEmotionAnalysisTableCompanion.insert(
              id: persistedId,
              trackId: analysis.trackId,
              representation: analysis.representation,
              modelId: analysis.modelId,
              modelVersion: analysis.modelVersion,
              preprocessingVersion: analysis.preprocessingVersion,
              contentRevision: analysis.contentRevision,
              audioRevision: analysis.audioRevision,
              temporalSummaryJson: Value(_encodeSummary(analysis.summary)),
              analyzedAt: analysis.analyzedAt,
            ),
          );
      await (database.delete(
        database.trackEmotionSegmentTable,
      )..where((table) => table.analysisId.equals(persistedId))).go();
      await database.batch((batch) {
        batch.insertAll(
          database.trackEmotionSegmentTable,
          analysis.segments
              .map(
                (segment) => TrackEmotionSegmentTableCompanion.insert(
                  analysisId: persistedId,
                  segmentIndex: segment.index,
                  startMs: segment.startMs,
                  endMs: segment.endMs,
                  valence: segment.valence,
                  arousal: segment.arousal,
                  moodDistributionJson: _encodeMood(segment.moodDistribution),
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  @override
  Future<TrackEmotionAnalysis?> getGlobal({
    required String trackId,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String contentRevision,
    required int audioRevision,
  }) async {
    final row = await _findRow(
      trackId: trackId,
      representation: MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
      modelId: modelId,
      modelVersion: modelVersion,
      preprocessingVersion: preprocessingVersion,
      contentRevision: contentRevision,
      audioRevision: audioRevision,
    );
    return row == null ? null : _globalFromRow(row);
  }

  @override
  Future<TrackEmotionTemporalAnalysis?> getTemporal({
    required String trackId,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String contentRevision,
    required int audioRevision,
  }) async {
    final row = await _findRow(
      trackId: trackId,
      representation: MusicAnalysisRepresentation.audioEmotionTemporal.apiName,
      modelId: modelId,
      modelVersion: modelVersion,
      preprocessingVersion: preprocessingVersion,
      contentRevision: contentRevision,
      audioRevision: audioRevision,
    );
    if (row == null) return null;
    final segmentRows =
        await (database.select(database.trackEmotionSegmentTable)
              ..where((table) => table.analysisId.equals(row.id))
              ..orderBy([(table) => OrderingTerm.asc(table.segmentIndex)]))
            .get();
    return TrackEmotionTemporalAnalysis(
      id: row.id,
      trackId: row.trackId,
      representation: row.representation,
      modelId: row.modelId,
      modelVersion: row.modelVersion,
      preprocessingVersion: row.preprocessingVersion,
      contentRevision: row.contentRevision,
      audioRevision: row.audioRevision,
      summary: _decodeSummary(row.temporalSummaryJson!),
      segments: segmentRows
          .map(
            (segment) => TrackEmotionSegment(
              analysisId: row.id,
              index: segment.segmentIndex,
              startMs: segment.startMs,
              endMs: segment.endMs,
              valence: segment.valence,
              arousal: segment.arousal,
              moodDistribution: _decodeMood(
                segment.moodDistributionJson,
                segment.moodDistributionVersion,
              ),
            ),
          )
          .toList(growable: false),
      analyzedAt: row.analyzedAt,
    );
  }

  @override
  Future<List<TrackEmotionAnalysis>> getGlobalsByPipeline({
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
  }) async {
    final rows =
        await (database.select(database.trackEmotionAnalysisTable)..where(
              (table) =>
                  table.representation.equals(
                    MusicAnalysisRepresentation.audioEmotionGlobal.apiName,
                  ) &
                  table.modelId.equals(modelId) &
                  table.modelVersion.equals(modelVersion) &
                  table.preprocessingVersion.equals(preprocessingVersion),
            ))
            .get();
    return rows.map(_globalFromRow).toList(growable: false);
  }

  @override
  Stream<void> watchChanges() =>
      database.select(database.trackEmotionAnalysisTable).watch().map((_) {});

  Future<TrackEmotionAnalysisTableData?> _findRow({
    required String trackId,
    required String representation,
    required String modelId,
    required String modelVersion,
    required String preprocessingVersion,
    required String contentRevision,
    required int audioRevision,
  }) =>
      (database.select(database.trackEmotionAnalysisTable)..where(
            (table) =>
                table.trackId.equals(trackId) &
                table.representation.equals(representation) &
                table.modelId.equals(modelId) &
                table.modelVersion.equals(modelVersion) &
                table.preprocessingVersion.equals(preprocessingVersion) &
                table.contentRevision.equals(contentRevision) &
                table.audioRevision.equals(audioRevision),
          ))
          .getSingleOrNull();

  static TrackEmotionAnalysis _globalFromRow(
    TrackEmotionAnalysisTableData row,
  ) => TrackEmotionAnalysis(
    id: row.id,
    trackId: row.trackId,
    representation: row.representation,
    modelId: row.modelId,
    modelVersion: row.modelVersion,
    preprocessingVersion: row.preprocessingVersion,
    contentRevision: row.contentRevision,
    audioRevision: row.audioRevision,
    valence: row.valence!,
    arousal: row.arousal!,
    rawValence: row.rawValence,
    rawArousal: row.rawArousal,
    moodDistribution: _decodeMood(
      row.moodDistributionJson!,
      row.moodDistributionVersion,
    ),
    analyzedAt: row.analyzedAt,
  );

  static String _encodeMood(MoodDistribution distribution) => jsonEncode({
    'version': _codecVersion,
    'scores': distribution.scores,
    'kind': distribution.kind,
    'vocabulary_version': distribution.vocabularyVersion,
  });

  static MoodDistribution _decodeMood(String value, int columnVersion) {
    if (columnVersion != _codecVersion) {
      throw StateError('Unsupported mood distribution version $columnVersion');
    }
    final root = jsonDecode(value) as Map<String, dynamic>;
    if (root['version'] != _codecVersion) {
      throw StateError('Unsupported mood distribution payload');
    }
    final rawScores = root['scores'] as Map<String, dynamic>;
    return MoodDistribution(
      rawScores.map(
        (label, score) => MapEntry(label, (score as num).toDouble()),
      ),
      kind: root['kind'] as String?,
      vocabularyVersion: root['vocabulary_version'] as String?,
    );
  }

  static String _encodeSummary(AudioEmotionTemporalSummary summary) =>
      jsonEncode({
        'version': _codecVersion,
        'number_of_segments': summary.numberOfSegments,
        'valence_mean': summary.valenceMean,
        'valence_std': summary.valenceStd,
        'valence_min': summary.minValence,
        'valence_max': summary.maxValence,
        'arousal_mean': summary.arousalMean,
        'arousal_std': summary.arousalStd,
        'arousal_min': summary.minArousal,
        'arousal_max': summary.maxArousal,
        'emotion_path_length': summary.emotionPathLength,
        'largest_emotion_change_index': summary.largestEmotionChangeIndex,
        'start_end_emotion_distance': summary.startEndEmotionDistance,
      });

  static AudioEmotionTemporalSummary _decodeSummary(String value) {
    final root = jsonDecode(value) as Map<String, dynamic>;
    if (root['version'] != _codecVersion) {
      throw StateError('Unsupported emotion summary version');
    }
    double? number(String key) => (root[key] as num?)?.toDouble();
    return AudioEmotionTemporalSummary(
      numberOfSegments: root['number_of_segments'] as int,
      valenceMean: number('valence_mean'),
      valenceStd: number('valence_std'),
      minValence: number('valence_min'),
      maxValence: number('valence_max'),
      arousalMean: number('arousal_mean'),
      arousalStd: number('arousal_std'),
      minArousal: number('arousal_min'),
      maxArousal: number('arousal_max'),
      emotionPathLength: number('emotion_path_length'),
      largestEmotionChangeIndex: root['largest_emotion_change_index'] as int?,
      startEndEmotionDistance: number('start_end_emotion_distance'),
    );
  }
}
