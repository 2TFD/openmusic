import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class LyricsResolutionTaskTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {trackId},
  ];
}
