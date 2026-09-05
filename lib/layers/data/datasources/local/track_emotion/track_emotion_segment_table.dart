import 'package:drift/drift.dart';

import 'track_emotion_analysis_table.dart';

class TrackEmotionSegmentTable extends Table {
  TextColumn get analysisId => text().references(
    TrackEmotionAnalysisTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get segmentIndex => integer()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  RealColumn get valence => real()();
  RealColumn get arousal => real()();
  IntColumn get moodDistributionVersion =>
      integer().withDefault(const Constant(1))();
  TextColumn get moodDistributionJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {analysisId, segmentIndex};
}
