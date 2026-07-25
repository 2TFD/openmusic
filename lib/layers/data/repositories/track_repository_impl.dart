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
  Future<List<Track>> getTracksByIds(List<String> ids) async {
    final dtos = await localDataSource.getTracksByIds(ids);
    return dtos.map(TrackMapper.toEntity).toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    final model = await localDataSource.getTrackById(id);
    return model != null ? TrackMapper.toEntity(model) : null;
  }

  @override
  Future<void> addTrack(Track track) async {
    final existingTrack = await getTrackById(track.id);
    if (existingTrack != null) {
      await AppLogger.log(
        "[TrackRepositoryImpl] Track with id: ${track.id} already exists. Skipping addition.",
      );
      throw Exception('Track with id: ${track.id} already exists');
    }

    final model = TrackMapper.toDto(track);
    await localDataSource.saveTrack(model);
  }

  @override
  Future<void> removeTrack(String trackId) async {
    await localDataSource.deleteTrackById(trackId);
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    final dtos = await localDataSource.searchTracks(query);
    return dtos.map(TrackMapper.toEntity).toList();
  }

  @override
  Future<void> updateTrack(Track track) async {
    await localDataSource.updateTrack(TrackMapper.toDto(track));
  }

  @override
  Stream<List<Track>> watchTracks() {
    return localDataSource.watchTracks().map(
      (dtos) => dtos.map(TrackMapper.toEntity).toList(),
    );
  }
}
