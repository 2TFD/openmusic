import 'package:drift/drift.dart';

class ListeningEventTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get trackId => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get positionMs => integer().nullable()();
  IntColumn get listenedMs => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get previousTrackId => text().nullable()();
  TextColumn get transitionReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
