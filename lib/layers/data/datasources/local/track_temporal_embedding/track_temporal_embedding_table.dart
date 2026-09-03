import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class TrackTemporalEmbeddingTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get representation => text()();
  TextColumn get modelId => text()();
  TextColumn get modelVersion => text()();
  TextColumn get preprocessingVersion => text()();
  TextColumn get provider => text()();
  IntColumn get audioRevision => integer()();
  IntColumn get dimension => integer()();
  TextColumn get dtype => text()();
  BoolColumn get normalized => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get numberOfSegments => integer()();
  RealColumn get meanAdjacentDistance => real()();
  RealColumn get maxAdjacentDistance => real()();
  RealColumn get trajectoryVariance => real()();
  IntColumn get largestTransitionIndex => integer().nullable()();

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
      provider,
      audioRevision,
    },
  ];
}
