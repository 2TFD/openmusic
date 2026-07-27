import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/data/datasources/local/track/track_local_data_source.dart';

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
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async {
    final dtos = await localDataSource.searchTracks(
      query,
      limit: limit,
      offset: offset,
    );
    return dtos.map(TrackMapper.toEntity).toList();
  }

  @override
  Future<void> updateMetadata(Track track) async {
    final updated = await localDataSource.updateTrackMetadata(
      TrackMapper.toDto(track),
    );
    if (!updated) throw ConflictFailure('track metadata', track.id);
  }

  @override
  Stream<void> watchChanges() => localDataSource.watchChanges();
}
