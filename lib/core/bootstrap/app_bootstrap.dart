import 'package:background_downloader/background_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:openmusic/core/services/embedding/embedding_worker.dart';
import 'package:openmusic/layers/domain/usecases/complite_track_download_use_case.dart';

class AppBootstrap {
  final GetIt getIt;

  AppBootstrap(this.getIt);

  Future<void> run() async {
    await _initWorkers();
    _initDownloadSystem();
  }

  Future<void> _initWorkers() async {
    getIt<EmbeddingWorker>().start();
  }

  void _handleDownload(TaskUpdate update) {
    if (update is TaskStatusUpdate) {
      if (update.status == TaskStatus.complete) {
        getIt<CompleteTrackDownloadUseCase>().call(
          trackId: update.task.taskId,
          filePath: update.task.filename,
        );
      }
    }
  }

  Future<void> _initDownloadSystem() async {
    _listenToDownloads();
    await FileDownloader().start(autoCleanDatabase: true);
  }

  void _listenToDownloads() {
    FileDownloader().updates.listen(_handleDownload);
  }
}
