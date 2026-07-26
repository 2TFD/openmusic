import 'package:openmusic/layers/domain/repositories/track_removal_repository.dart';

class RemoveTrackUseCase {
  final TrackRemovalRepository trackRemovalRepository;
  RemoveTrackUseCase({required this.trackRemovalRepository});
  Future<void> call(String trackId) async {
    await trackRemovalRepository.removeTrack(trackId);
  }
}
