import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class RemoveTrackUseCase {
  final TrackRepository trackRepository;
  RemoveTrackUseCase({required this.trackRepository});
  Future<void> call(String trackId) async {
    await trackRepository.removeTrack(trackId);
  }
}
