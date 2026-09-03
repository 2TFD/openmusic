import 'package:drift/drift.dart';

import '../track/drift/track_table.dart';

class LyricsResolutionStateTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text()();
  TextColumn get provider => text().nullable()();
  IntColumn get metadataRevision => integer().withDefault(const Constant(0))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}
