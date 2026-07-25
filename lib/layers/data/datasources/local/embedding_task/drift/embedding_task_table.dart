import 'package:drift/drift.dart';

class EmbeddingTaskTable extends Table {
  TextColumn get id => text().unique()();

  TextColumn get trackId => text()();

  TextColumn get status => text()();

  TextColumn get filePath => text()();

  DateTimeColumn get createdAt => dateTime()();
  TextColumn get leaseOwner => text().nullable()();
  DateTimeColumn get leaseUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}
