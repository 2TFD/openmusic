import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';

class TrackDriftLocalSource implements TrackLocalDataSource {
  TrackDriftLocalSource(this.database);

  final AppDatabase database;

  @override
  Future<TrackDto?> getTrackById(String id) async {
    final row = await (database.select(
      database.trackTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final artists = await _loadArtists([id]);
    return _mapToTrackDto(row, artists[id] ?? const []);
  }

  @override
  Future<List<TrackDto>> getTracksByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (database.select(
      database.trackTable,
    )..where((table) => table.id.isIn(ids))).get();
    final dtos = await _mapRows(rows);
    final byId = {for (final dto in dtos) dto.id: dto};
    return ids.map((id) => byId[id]).whereType<TrackDto>().toList();
  }

  @override
  Future<List<TrackDto>> getTracks() async {
    final rows =
        await (database.select(database.trackTable)..orderBy([
              (track) => OrderingTerm.desc(track.addedAt),
              (track) => OrderingTerm.asc(track.id),
            ]))
            .get();
    return _mapRows(rows);
  }

  @override
  Future<List<TrackDto>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async {
    final pattern = '%${query.toLowerCase()}%';
    final statement =
        database.select(database.trackTable).join([
            leftOuterJoin(
              database.trackArtistTable,
              database.trackArtistTable.trackId.equalsExp(
                database.trackTable.id,
              ),
            ),
            leftOuterJoin(
              database.artistTable,
              database.artistTable.id.equalsExp(
                database.trackArtistTable.artistId,
              ),
            ),
          ])
          ..where(
            database.trackTable.title.lower().like(pattern) |
                database.artistTable.name.lower().like(pattern),
          )
          ..groupBy([database.trackTable.id])
          ..orderBy([
            OrderingTerm.desc(database.trackTable.addedAt),
            OrderingTerm.asc(database.trackTable.id),
          ])
          ..limit(limit, offset: offset);
    final rows = await statement.get();
    return _mapRows(rows.map((row) => row.readTable(database.trackTable)));
  }

  @override
  Future<void> saveTrack(TrackDto track) async {
    await database.transaction(() async {
      await database
          .into(database.trackTable)
          .insert(_trackCompanion(track, includeId: true));
      await _replaceArtists(track);
    });
  }

  @override
  Future<void> updateTrackMetadata(TrackDto track) async {
    await database.transaction(() async {
      await (database.update(
        database.trackTable,
      )..where((table) => table.id.equals(track.id))).write(
        TrackTableCompanion(
          title: Value(track.title),
          durationMs: Value(track.durationMs),
          album: Value(track.album),
          imageUrl: Value(track.imageUrl),
        ),
      );
      await _replaceArtists(track);
    });
  }

  @override
  Stream<List<TrackDto>> watchTracks() {
    final statement =
        database.select(database.trackTable).join([
          leftOuterJoin(
            database.trackArtistTable,
            database.trackArtistTable.trackId.equalsExp(database.trackTable.id),
          ),
          leftOuterJoin(
            database.artistTable,
            database.artistTable.id.equalsExp(
              database.trackArtistTable.artistId,
            ),
          ),
        ])..orderBy([
          OrderingTerm.desc(database.trackTable.addedAt),
          OrderingTerm.asc(database.trackTable.id),
          OrderingTerm.asc(database.trackArtistTable.position),
        ]);

    return statement.watch().map((rows) {
      final tracks = <String, TrackTableData>{};
      final artists = <String, List<({String id, String name})>>{};
      for (final row in rows) {
        final track = row.readTable(database.trackTable);
        tracks[track.id] = track;
        final artist = row.readTableOrNull(database.artistTable);
        if (artist != null) {
          artists.putIfAbsent(track.id, () => []).add((
            id: artist.id,
            name: artist.name,
          ));
        }
      }
      return tracks.values
          .map((track) => _mapToTrackDto(track, artists[track.id] ?? const []))
          .toList();
    });
  }

  Future<List<TrackDto>> _mapRows(Iterable<TrackTableData> rows) async {
    final list = rows.toList();
    final artists = await _loadArtists(list.map((row) => row.id).toList());
    return list
        .map((row) => _mapToTrackDto(row, artists[row.id] ?? const []))
        .toList();
  }

  Future<Map<String, List<({String id, String name})>>> _loadArtists(
    List<String> trackIds,
  ) async {
    if (trackIds.isEmpty) return const {};
    final statement =
        database.select(database.trackArtistTable).join([
            innerJoin(
              database.artistTable,
              database.artistTable.id.equalsExp(
                database.trackArtistTable.artistId,
              ),
            ),
          ])
          ..where(database.trackArtistTable.trackId.isIn(trackIds))
          ..orderBy([
            OrderingTerm.asc(database.trackArtistTable.trackId),
            OrderingTerm.asc(database.trackArtistTable.position),
          ]);
    final result = <String, List<({String id, String name})>>{};
    for (final row in await statement.get()) {
      final relation = row.readTable(database.trackArtistTable);
      final artist = row.readTable(database.artistTable);
      result.putIfAbsent(relation.trackId, () => []).add((
        id: artist.id,
        name: artist.name,
      ));
    }
    return result;
  }

  Future<void> _replaceArtists(TrackDto track) async {
    await (database.delete(
      database.trackArtistTable,
    )..where((table) => table.trackId.equals(track.id))).go();

    final seenIds = <String>{};
    var position = 0;
    for (final artist in track.artists) {
      final artistId = artist.id;
      if (artistId.isEmpty || !seenIds.add(artistId)) continue;
      await database
          .into(database.artistTable)
          .insertOnConflictUpdate(
            ArtistTableCompanion.insert(id: artistId, name: artist.name),
          );
      await database
          .into(database.trackArtistTable)
          .insert(
            TrackArtistTableCompanion.insert(
              trackId: track.id,
              artistId: artistId,
              position: position++,
            ),
          );
    }
  }

  TrackTableCompanion _trackCompanion(
    TrackDto track, {
    bool includeId = false,
  }) {
    return TrackTableCompanion(
      id: includeId ? Value(track.id) : const Value.absent(),
      title: Value(track.title),
      pathToFile: Value(track.filePath),
      durationMs: Value(track.durationMs),
      sourceType: Value(track.sourceType),
      sourceUri: Value(track.originalUrl),
      addedAt: Value(track.addedAt),
      album: Value(track.album),
      imageUrl: Value(track.imageUrl),
      trackDescriptorJson: Value(track.trackDescriptorJson),
      embedding: track.embedding != null
          ? Value(jsonEncode(track.embedding))
          : const Value(null),
    );
  }

  static TrackDto _mapToTrackDto(
    TrackTableData data,
    List<({String id, String name})> artists,
  ) {
    return TrackDto(
      id: data.id,
      title: data.title,
      filePath: data.pathToFile,
      artists: artists
          .map((artist) => ArtistDto(id: artist.id, name: artist.name))
          .toList(),
      durationMs: data.durationMs,
      sourceType: data.sourceType,
      originalUrl: data.sourceUri,
      addedAt: data.addedAt,
      album: data.album,
      imageUrl: data.imageUrl,
      trackDescriptorJson: data.trackDescriptorJson,
      embedding: data.embedding != null
          ? (jsonDecode(data.embedding!) as List)
                .map((value) => (value as num).toDouble())
                .toList()
          : null,
    );
  }
}
