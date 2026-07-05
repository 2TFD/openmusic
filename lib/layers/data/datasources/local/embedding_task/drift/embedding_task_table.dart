import 'package:drift/drift.dart';

class EmbeddingTaskTable extends Table {
  TextColumn get id => text()();

  TextColumn get trackId => text()();

  TextColumn get status => text()();

  TextColumn get filePath => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}
