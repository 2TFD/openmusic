import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/artist_repository.dart';

class GetArtistTracksUseCase {
  const GetArtistTracksUseCase(this.repository);

  final ArtistRepository repository;

  Future<List<Track>> call(String artistId) {
    return repository.getTracksByArtist(artistId);
  }
}
