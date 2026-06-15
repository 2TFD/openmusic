import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/DTO/track_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';

class TrackDriftLocalSource implements TrackLocalDataSource {
  final AppDatabase database;

  TrackDriftLocalSource(this.database);

  @override
  Future<void> deleteTrackById(String trackId) async {
    try {
      await (database.delete(
        database.trackTable,
      )..where((t) => t.id.equals(trackId))).go();
    } catch (e, st) {
      await AppLogger.log(
        '[TrackDriftLocalSource.deleteTrackById] Error deleting track $trackId: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<TrackDto?> getTrackById(String id) async {
    try {
      return await (database.select(database.trackTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull()
          .then((data) => data != null ? _mapToTrackDto(data) : null);
    } catch (e, st) {
      await AppLogger.log(
        '[TrackDriftLocalSource.getTrackById] Error getting track $id: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<List<TrackDto>> getTracks() async {
    try {
      final List<TrackTableData> res = await database
          .select(database.trackTable)
          .get();
      return compute(_decodeAll, res);
    } catch (e, st) {
      await AppLogger.log(
        '[TrackDriftLocalSource.getTracks] Error getting tracks: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> saveTrack(TrackDto track) async {
    try {
      await database
          .into(database.trackTable)
          .insert(
            TrackTableCompanion(
              id: Value(track.id),
              title: Value(track.title),
              pathToFile: Value(track.pathToFile),
              artistIds: Value(jsonEncode(track.artistIds)),
              artistNames: Value(jsonEncode(track.artistNames)),
              durationMs: Value(track.durationMs),
              sourceType: Value(track.sourceType),
              sourceUri: Value(track.sourceUri),
              addedAt: Value(track.addedAt),
              album: Value(track.album),
              imageUrl: Value(track.imageUrl),
              trackDescriptorJson: Value(track.trackDescriptorJson),
              embedding: track.embedding != null
                  ? Value(jsonEncode(track.embedding))
                  : const Value(null),
            ),
          );
    } catch (e, st) {
      await AppLogger.log(
        '[TrackDriftLocalSource.saveTrack] Error saving track ${track.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTrack(TrackDto track) async {
    try {
      await (database.update(
        database.trackTable,
      )..where((t) => t.id.equals(track.id))).write(
        TrackTableCompanion(
          title: Value(track.title),
          pathToFile: Value(track.pathToFile),
          artistIds: Value(jsonEncode(track.artistIds)),
          artistNames: Value(jsonEncode(track.artistNames)),
          durationMs: Value(track.durationMs),
          sourceType: Value(track.sourceType),
          sourceUri: Value(track.sourceUri),
          addedAt: Value(track.addedAt),
          album: Value(track.album),
          imageUrl: Value(track.imageUrl),
          trackDescriptorJson: Value(track.trackDescriptorJson),
          embedding: track.embedding != null
              ? Value(jsonEncode(track.embedding))
              : const Value(null),
        ),
      );
    } catch (e, st) {
      await AppLogger.log(
        '[TrackDriftLocalSource.updateTrack] Error updating track ${track.id}: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  @override
  Stream<dynamic> watchTracks() {
    try {
      return database.select(database.trackTable).watch();
    } catch (e, st) {
      AppLogger.log(
        '[TrackDriftLocalSource.watchTracks] Error watching tracks: $e, stackTrace: $st',
      );
      rethrow;
    }
  }

  static List<TrackDto> _decodeAll(List<TrackTableData> rows) =>
      rows.map(_mapToTrackDto).toList();

  static TrackDto _mapToTrackDto(TrackTableData data) {
    return TrackDto(
      id: data.id,
      title: data.title,
      pathToFile: data.pathToFile,
      artistIds: List<String>.from(jsonDecode(data.artistIds)),
      artistNames: List<String>.from(jsonDecode(data.artistNames)),
      durationMs: data.durationMs,
      sourceType: data.sourceType,
      sourceUri: data.sourceUri,
      addedAt: data.addedAt,
      album: data.album,
      imageUrl: data.imageUrl,
      trackDescriptorJson: data.trackDescriptorJson,
      embedding: data.embedding != null
          ? List<double>.from(jsonDecode(data.embedding!))
          : null,
    );
  }
}
