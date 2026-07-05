import 'package:get_it/get_it.dart';
import 'package:openmusic/core/services/download/download_worker.dart';
import 'package:openmusic/core/services/embedding/embedding_worker.dart';

class AppBootstrap {
  final GetIt getIt;

  AppBootstrap(this.getIt);

  Future<void> run() async {
    await _initWorkers();
  }

  Future<void> _initWorkers() async {
    getIt<EmbeddingWorker>().start();
    getIt<DownloadWorker>().startProcessing();
  }
}
