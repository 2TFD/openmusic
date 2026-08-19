import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/repositories/artist_repository.dart';

class WatchArtistUseCase {
  const WatchArtistUseCase(this.repository);

  final ArtistRepository repository;

  Stream<ArtistSummary?> call(String id) => repository.watchArtistById(id);
}
