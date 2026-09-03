import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class MusicAnalysisTaskTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get requestedRepresentations => text()();
  IntColumn get audioRevision => integer()();
  TextColumn get status => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
