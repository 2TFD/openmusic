import 'package:drift/drift.dart';

class TrackTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get pathToFile => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get sourceType => text()();
  TextColumn get sourceUri => text()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get trackDescriptorJson => text().nullable()();
  TextColumn get embedding => text().nullable()();
  IntColumn get audioRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
