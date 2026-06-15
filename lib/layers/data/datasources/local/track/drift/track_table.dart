import 'package:drift/drift.dart';

class TrackTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get pathToFile => text().nullable()();
  TextColumn get artistIds => text()();
  TextColumn get artistNames => text()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get sourceType => text()();
  TextColumn get sourceUri => text()();
  TextColumn get addedAt => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get trackDescriptorJson => text().nullable()();
  TextColumn get embedding => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
