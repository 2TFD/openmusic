import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:openmusic/core/services/download/download_worker.dart';
import 'package:openmusic/core/services/embedding/embedding_worker.dart';

class AppBootstrap with WidgetsBindingObserver {
  final GetIt getIt;
  bool _observingLifecycle = false;

  AppBootstrap(this.getIt);

  Future<void> run() async {
    if (!_observingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    }
    await _initWorkers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) unawaited(stop());
  }

  Future<void> _initWorkers() async {
    unawaited(getIt<EmbeddingWorker>().start());
    unawaited(getIt<DownloadWorker>().startProcessing());
  }

  Future<void> stop() async {
    if (_observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _observingLifecycle = false;
    }
    await Future.wait([
      getIt<EmbeddingWorker>().stop(),
      getIt<DownloadWorker>().stop(),
    ]);
  }
}
