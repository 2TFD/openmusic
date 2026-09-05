import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class PersonalMoodAdjustmentTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  RealColumn get valence => real()();
  RealColumn get arousal => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}
