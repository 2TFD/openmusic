import 'package:drift/drift.dart';

class PlaylistTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get trackIds => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}
