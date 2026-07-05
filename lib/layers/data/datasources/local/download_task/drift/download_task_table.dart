import 'package:drift/drift.dart';

class DownloadTaskTable extends Table {
  TextColumn get trackId => text()();
  TextColumn get originalUrl => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}
