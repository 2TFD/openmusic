import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/repositories/artist_repository.dart';

class WatchArtistSummariesUseCase {
  const WatchArtistSummariesUseCase(this.repository);

  final ArtistRepository repository;

  Stream<List<ArtistSummary>> call() => repository.watchArtistSummaries();
}
