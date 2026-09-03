import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class TrackLyricsTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get source => text()();
  TextColumn get sourceId => text().nullable()();
  TextColumn get plainText => text()();
  TextColumn get syncedText => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get contentHash => text()();
  BoolColumn get isInstrumental =>
      boolean().withDefault(const Constant(false))();
  RealColumn get matchConfidence => real().nullable()();
  TextColumn get matchedTitle => text().nullable()();
  TextColumn get matchedArtist => text().nullable()();
  IntColumn get matchedDurationMs => integer().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}
