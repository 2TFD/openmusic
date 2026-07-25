import 'package:openmusic/layers/domain/repositories/track_download_completion_repository.dart';

class CompleteTrackDownloadUseCase {
  final TrackDownloadCompletionRepository repository;

  CompleteTrackDownloadUseCase(this.repository);

  Future<void> completeLocal({
    required String trackId,
    required String filePath,
  }) => repository.completeLocal(trackId: trackId, filePath: filePath);

  Future<bool> completeClaimed({
    required String trackId,
    required String filePath,
    required String ownerId,
  }) => repository.completeClaimed(
    trackId: trackId,
    filePath: filePath,
    ownerId: ownerId,
  );
}
