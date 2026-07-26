import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';

class PlaylistTrackTable extends Table {
  TextColumn get playlistId =>
      text().references(PlaylistTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {playlistId, position},
  ];
}
