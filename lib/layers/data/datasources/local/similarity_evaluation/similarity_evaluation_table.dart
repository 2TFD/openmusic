import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class SimilarityEvaluationTable extends Table {
  TextColumn get id => text()();
  @ReferenceName('seedSimilarityEvaluations')
  TextColumn get seedTrackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('candidateSimilarityEvaluations')
  TextColumn get candidateTrackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get methodVersion => text()();
  TextColumn get sourceRepresentationModelId => text()();
  TextColumn get sourceRepresentationModelVersion => text()();
  TextColumn get sourcePreprocessingVersion => text()();
  RealColumn get scoreShown => real()();
  RealColumn get rawDistance => real().nullable()();
  IntColumn get soundRating => integer().nullable()();
  IntColumn get atmosphereRating => integer().nullable()();
  IntColumn get trajectoryRating => integer().nullable()();
  BoolColumn get wouldListenNext => boolean().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {
      seedTrackId,
      candidateTrackId,
      methodVersion,
      sourceRepresentationModelId,
      sourceRepresentationModelVersion,
      sourcePreprocessingVersion,
    },
  ];
}
