import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/database/playback_session_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';

class PlaybackQueueItemTable extends Table {
  TextColumn get sessionId => text().references(
    PlaybackSessionTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {sessionId, trackId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionId, position},
  ];
}
