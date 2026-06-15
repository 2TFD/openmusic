import 'package:openmusic/layers/domain/entities/download_track_task.dart';

abstract class DownloadRepository {
  Future<void> enqueueTrackTask(DownloadTrackTask task);
}
