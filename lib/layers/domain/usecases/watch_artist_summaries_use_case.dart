import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/repositories/artist_repository.dart';

class WatchArtistSummariesUseCase {
  const WatchArtistSummariesUseCase(this.repository);

  final ArtistRepository repository;

  Stream<List<ArtistSummary>> call() => repository.watchArtistSummaries();
}
