import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/artist_table.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_table.dart';

class TrackArtistTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get artistId =>
      text().references(ArtistTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {trackId, artistId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {trackId, position},
  ];
}
