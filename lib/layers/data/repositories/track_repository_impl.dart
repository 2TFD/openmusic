import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';

import '../../../core/utils/app_logger.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import '../mappers/track_mapper.dart';

class TrackRepositoryImpl implements TrackRepository {
  final TrackLocalDataSource localDataSource;

  TrackRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Track>> getTracks() async {
    final models = await localDataSource.getTracks();
    return models.map(TrackMapper.toEntity).toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    final model = await localDataSource.getTrackById(id);
    return model != null ? TrackMapper.toEntity(model) : null;
  }

  @override
  Future<void> addTrack(Track track) async {
    try {
      final existingTrack = await getTrackById(track.id);
      if (existingTrack != null) {
        await AppLogger.log(
          "[TrackRepositoryImpl] Track with id: ${track.id} already exists. Skipping addition.",
        );
        throw Exception('Track with id: ${track.id} already exists');
      }

      final model = TrackMapper.toDto(track);
      await localDataSource.saveTrack(model);
    } catch (e, st) {
      await AppLogger.log(
        "[TrackRepositoryImpl] ERROR adding track with id: ${track.id}. Error: $e, StackTrace: \n$st",
      );
      rethrow;
    }
  }

  @override
  Future<void> removeTrack(String trackId) async {
    try {
      await localDataSource.deleteTrackById(trackId);
    } catch (e, st) {
      await AppLogger.log(
        "[TrackRepositoryImpl] ERROR removing track with id: $trackId. Error: $e, StackTrace: \n$st",
      );
      rethrow;
    }
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    final allTracks = await getTracks();
    final lowerQuery = query.toLowerCase();

    return allTracks.where((track) {
      return track.title.toLowerCase().contains(lowerQuery) ||
          track.artists.any(
            (artist) => artist.name.toLowerCase().contains(lowerQuery),
          ) ||
          (track.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<void> updateTrack(Track track) async {
    try {
      await localDataSource.updateTrack(TrackMapper.toDto(track));
    } catch (e, st) {
      await AppLogger.log(
        "[TrackRepositoryImpl] ERROR updating track with id: ${track.id}. Error: $e, StackTrace: \n$st",
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTrackEmbeddingById({
    required String id,
    required List<double> vector,
  }) async {
    try {
      Track? track = await getTrackById(id);
      if (track == null) {
        throw Exception('not find track id:$id');
      }
      track = track.copyWith(embedding: vector);
      await localDataSource.updateTrack(TrackMapper.toDto(track));
    } catch (e, st) {
      await AppLogger.log(
        "[TrackRepositoryImpl] ERROR updating track embedding for id: $id. Error: $e, StackTrace: \n$st",
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTrackPathById({
    required String id,
    required String path,
  }) async {
    try {
      Track? track = await getTrackById(id);
      if (track == null) {
        throw Exception('not find track id:$id');
      }
      track = track.copyWith(pathToFile: path);
      await localDataSource.updateTrack(TrackMapper.toDto(track));
    } catch (e, st) {
      await AppLogger.log(
        "[TrackRepositoryImpl] ERROR updating track path for id: $id with path: $path. Error: $e, StackTrace: \n$st",
      );
      rethrow;
    }
  }

  @override
  Stream<dynamic> watchTracks() {
    return localDataSource.watchTracks();
  }
}
