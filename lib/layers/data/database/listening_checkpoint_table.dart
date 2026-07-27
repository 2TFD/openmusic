import 'package:drift/drift.dart';

class ListeningCheckpointTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId => text()();
  TextColumn get trackTitle => text()();
  TextColumn get artistName => text()();
  TextColumn get sourceType => text()();
  IntColumn get listenedMilliseconds => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
