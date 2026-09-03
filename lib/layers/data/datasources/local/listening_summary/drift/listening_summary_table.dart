import 'package:drift/drift.dart';

class ListeningSummaryTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId => text()();
  TextColumn get trackTitle => text()();
  TextColumn get artistName => text()();
  TextColumn get sourceType => text()();
  IntColumn get listenedDurationMilliseconds => integer()();
  DateTimeColumn get playedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}
