import 'dart:io';

import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/domain/repositories/track_removal_repository.dart';
import 'package:path/path.dart' as path;

class TrackRemovalRepositoryImpl implements TrackRemovalRepository {
  TrackRemovalRepositoryImpl({required this.database, required this.appDir});

  final AppDatabase database;
  final String appDir;

  @override
  Future<void> removeTrack(String trackId) async {
    final assets = await database.transaction<List<String>>(() async {
      final track = await (database.select(
        database.trackTable,
      )..where((row) => row.id.equals(trackId))).getSingleOrNull();
      if (track == null) throw NotFoundFailure('track', trackId);

      final artistRows = await (database.select(
        database.trackArtistTable,
      )..where((row) => row.trackId.equals(trackId))).get();
      final artistIds = artistRows.map((row) => row.artistId).toSet();

      await (database.delete(
        database.downloadTaskTable,
      )..where((row) => row.trackId.equals(trackId))).go();
      await (database.delete(
        database.embeddingTaskTable,
      )..where((row) => row.trackId.equals(trackId))).go();
      await (database.delete(
        database.playlistTrackTable,
      )..where((row) => row.trackId.equals(trackId))).go();
      await (database.delete(
        database.trackArtistTable,
      )..where((row) => row.trackId.equals(trackId))).go();
      await (database.delete(
        database.trackTable,
      )..where((row) => row.id.equals(trackId))).go();

      for (final artistId in artistIds) {
        final stillReferenced = await (database.select(
          database.trackArtistTable,
        )..where((row) => row.artistId.equals(artistId))).getSingleOrNull();
        if (stillReferenced == null) {
          await (database.delete(
            database.artistTable,
          )..where((row) => row.id.equals(artistId))).go();
        }
      }

      return [track.pathToFile, track.imageUrl].whereType<String>().toList();
    });

    for (final asset in assets) {
      await _deleteOwnedAsset(asset);
    }
  }

  Future<void> _deleteOwnedAsset(String storedPath) async {
    if (storedPath.isEmpty || Uri.tryParse(storedPath)?.hasScheme == true) {
      return;
    }
    final root = path.normalize(path.absolute(appDir));
    final candidate = path.normalize(
      path.isAbsolute(storedPath) ? storedPath : path.join(root, storedPath),
    );
    if (candidate != root && !path.isWithin(root, candidate)) return;

    try {
      final file = File(candidate);
      if (await file.exists()) await file.delete();
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[TrackRemovalRepository] Failed to delete $candidate: '
        '$error, stackTrace: $stackTrace',
      );
    }
  }
}
