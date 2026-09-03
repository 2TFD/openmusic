import 'package:drift/drift.dart';

class MusicAnalysisSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get serverEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
