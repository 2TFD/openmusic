import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';

class RetryTrackDownloadUseCase {
  const RetryTrackDownloadUseCase(this._repository);

  final DownloadTaskRepository _repository;

  Future<void> call(Track track) async {
    if (track.filePath != null) return;
    await _repository.enqueue(track.id, track.source.effectiveMediaUrl);
  }
}
