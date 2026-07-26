import '../entities/track.dart';

import '../repositories/track_repository.dart';

class SearchTracksUseCase {
  final TrackRepository repository;

  SearchTracksUseCase(this.repository);

  Future<List<Track>> call(String query) async {
    return await repository.searchTracks(query, limit: 100, offset: 0);
  }
}
