import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class UpdateTrackUseCase {
  final TrackRepository trackRepository;
  UpdateTrackUseCase({required this.trackRepository});
  Future<void> call(Track track) async {
    await trackRepository.updateTrack(track);
  }
}
