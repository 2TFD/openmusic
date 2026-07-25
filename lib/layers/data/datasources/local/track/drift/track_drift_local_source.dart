import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:openmusic/layers/data/DTO/track_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';

class TrackDriftLocalSource implements TrackLocalDataSource {
  final AppDatabase database;

  TrackDriftLocalSource(this.database);

  @override
  Future<void> deleteTrackById(String trackId) async {
    await (database.delete(
      database.trackTable,
    )..where((t) => t.id.equals(trackId))).go();
  }

  @override
  Future<TrackDto?> getTrackById(String id) async {
    return await (database.select(database.trackTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull()
        .then((data) => data != null ? _mapToTrackDto(data) : null);
  }

  @override
  Future<List<TrackDto>> getTracksByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (database.select(
      database.trackTable,
    )..where((t) => t.id.isIn(ids))).get();
    final byId = {for (final r in rows) r.id: _mapToTrackDto(r)};
    return ids.map((id) => byId[id]).whereType<TrackDto>().toList();
  }

  @override
  Future<List<TrackDto>> getTracks() async {
    final List<TrackTableData> res =
        await (database.select(database.trackTable)..orderBy([
              (track) => OrderingTerm.desc(track.addedAt),
              (track) => OrderingTerm.asc(track.id),
            ]))
            .get();
    return compute(_decodeAll, res);
  }

  @override
  Future<List<TrackDto>> searchTracks(String query) async {
    final pattern = '%${query.toLowerCase()}%';
    final rows =
        await (database.select(database.trackTable)..where(
              (t) =>
                  t.title.lower().like(pattern) |
                  t.artistNames.lower().like(pattern),
            ))
            .get();
    return compute(_decodeAll, rows);
  }

  @override
  Future<void> saveTrack(TrackDto track) async {
    await database
        .into(database.trackTable)
        .insert(
          TrackTableCompanion(
            id: Value(track.id),
            title: Value(track.title),
            pathToFile: Value(track.filePath),
            artistIds: Value(jsonEncode(track.artistIds)),
            artistNames: Value(jsonEncode(track.artistNames)),
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
          ),
        );
  }

  @override
  Future<void> updateTrack(TrackDto track) async {
    await (database.update(
      database.trackTable,
    )..where((t) => t.id.equals(track.id))).write(
      TrackTableCompanion(
        title: Value(track.title),
        pathToFile: Value(track.filePath),
        artistIds: Value(jsonEncode(track.artistIds)),
        artistNames: Value(jsonEncode(track.artistNames)),
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
      ),
    );
  }

  @override
  Stream<List<TrackDto>> watchTracks() {
    return (database.select(database.trackTable)..orderBy([
          (track) => OrderingTerm.desc(track.addedAt),
          (track) => OrderingTerm.asc(track.id),
        ]))
        .watch()
        .asyncMap((rows) => compute(_decodeAll, rows));
  }

  static List<TrackDto> _decodeAll(List<TrackTableData> rows) =>
      rows.map(_mapToTrackDto).toList();

  static TrackDto _mapToTrackDto(TrackTableData data) {
    return TrackDto(
      id: data.id,
      title: data.title,
      filePath: data.pathToFile,
      artistIds: List<String>.from(jsonDecode(data.artistIds)),
      artistNames: List<String>.from(jsonDecode(data.artistNames)),
      durationMs: data.durationMs,
      sourceType: data.sourceType,
      originalUrl: data.sourceUri,
      addedAt: data.addedAt,
      album: data.album,
      imageUrl: data.imageUrl,
      trackDescriptorJson: data.trackDescriptorJson,
      embedding: data.embedding != null
          ? (jsonDecode(data.embedding!) as List)
                .map((e) => (e as num).toDouble())
                .toList()
          : null,
    );
  }
}
