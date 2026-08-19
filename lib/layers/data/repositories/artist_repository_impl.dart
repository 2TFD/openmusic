import 'package:openmusic/layers/data/datasources/local/artist/artist_local_data_source.dart';
import 'package:openmusic/layers/data/mappers/artist_mapper.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/artist_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  ArtistRepositoryImpl({
    required this.localDataSource,
    required this.trackRepository,
  });

  final ArtistLocalDataSource localDataSource;
  final TrackRepository trackRepository;

  @override
  Stream<List<ArtistSummary>> watchArtistSummaries() {
    return localDataSource.watchArtistSummaries().map(
      (items) => items.map(ArtistMapper.summaryToEntity).toList(),
    );
  }

  @override
  Stream<ArtistSummary?> watchArtistById(String id) {
    return localDataSource
        .watchArtistById(id)
        .map(
          (item) => item == null ? null : ArtistMapper.summaryToEntity(item),
        );
  }

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async {
    final ids = await localDataSource.getTrackIdsByArtist(artistId);
    return trackRepository.getTracksByIds(ids);
  }
}
