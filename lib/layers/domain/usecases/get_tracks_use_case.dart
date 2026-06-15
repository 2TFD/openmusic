import '../entities/track.dart';
import '../repositories/track_repository.dart';

class GetTracksUseCase {
  final TrackRepository repository;

  GetTracksUseCase(this.repository);

  Future<List<Track>> call() async {
    return await repository.getTracks();
  }
}
