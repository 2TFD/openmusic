import 'package:drift/drift.dart';

class AppNavigationStateTable extends Table {
  TextColumn get id => text()();
  TextColumn get section => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
