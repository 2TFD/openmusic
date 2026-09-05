import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class TrackEmotionAnalysisTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get representation => text()();
  TextColumn get modelId => text()();
  TextColumn get modelVersion => text()();
  TextColumn get preprocessingVersion => text()();
  TextColumn get contentRevision => text()();
  IntColumn get audioRevision => integer()();
  RealColumn get valence => real().nullable()();
  RealColumn get arousal => real().nullable()();
  RealColumn get rawValence => real().nullable()();
  RealColumn get rawArousal => real().nullable()();
  IntColumn get moodDistributionVersion =>
      integer().withDefault(const Constant(1))();
  TextColumn get moodDistributionJson => text().nullable()();
  TextColumn get temporalSummaryJson => text().nullable()();
  DateTimeColumn get analyzedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {
      trackId,
      representation,
      modelId,
      modelVersion,
      preprocessingVersion,
      contentRevision,
      audioRevision,
    },
  ];
}
