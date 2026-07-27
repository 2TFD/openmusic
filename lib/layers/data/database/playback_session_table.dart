import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';

class PlaybackSessionTable extends Table {
  TextColumn get id => text()();
  TextColumn get currentTrackId => text()
      .nullable()
      .references(TrackTable, #id, onDelete: KeyAction.setNull)();
  IntColumn get currentQueuePosition => integer()();
  IntColumn get positionMilliseconds => integer()();
  BoolColumn get shuffleEnabled => boolean()();
  TextColumn get loopMode => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
