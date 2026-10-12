import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/repositories/artist_repository.dart';

class WatchArtistUseCase {
  const WatchArtistUseCase(this.repository);

  final ArtistRepository repository;

  Stream<ArtistSummary?> call(String id) => repository.watchArtistById(id);
}
