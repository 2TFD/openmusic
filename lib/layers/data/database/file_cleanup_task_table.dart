import 'package:drift/drift.dart';

class FileCleanupTaskTable extends Table {
  TextColumn get path => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {path};
}
