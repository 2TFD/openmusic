import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/artist_repository.dart';

class GetArtistTracksUseCase {
  const GetArtistTracksUseCase(this.repository);

  final ArtistRepository repository;

  Future<List<Track>> call(String artistId) {
    return repository.getTracksByArtist(artistId);
  }
}
