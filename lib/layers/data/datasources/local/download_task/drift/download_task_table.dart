import 'package:drift/drift.dart';

class DownloadTaskTable extends Table {
  TextColumn get trackId => text()();
  TextColumn get originalUrl => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get leaseOwner => text().nullable()();
  DateTimeColumn get leaseUntil => dateTime().nullable()();
  TextColumn get failureCode => text().nullable()();
  TextColumn get failureMessage => text().nullable()();
  TextColumn get failureDetails => text().nullable()();
  DateTimeColumn get failedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}
