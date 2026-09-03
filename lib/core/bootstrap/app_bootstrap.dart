import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:openmusic/core/services/download/download_worker.dart';
import 'package:openmusic/core/services/music_analysis/music_analysis_worker.dart';
import 'package:openmusic/core/services/lyrics/lyrics_resolution_worker.dart';
import 'package:openmusic/layers/domain/repositories/track_removal_repository.dart';
import 'package:openmusic/layers/domain/usecases/recover_listening_checkpoint_use_case.dart';

class AppBootstrap with WidgetsBindingObserver {
  final GetIt getIt;
  bool _observingLifecycle = false;

  AppBootstrap(this.getIt);

  Future<void> run() async {
    if (!_observingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    }
    await getIt<TrackRemovalRepository>().cleanupPending();
    await getIt<RecoverListeningCheckpointUseCase>()();
    await _initWorkers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) unawaited(stop());
  }

  Future<void> _initWorkers() async {
    unawaited(getIt<DownloadWorker>().startProcessing());
    unawaited(getIt<MusicAnalysisWorker>().start());
    unawaited(getIt<LyricsResolutionWorker>().start());
  }

  Future<void> stop() async {
    if (_observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _observingLifecycle = false;
    }
    await Future.wait([
      getIt<DownloadWorker>().stop(),
      getIt<MusicAnalysisWorker>().stop(),
      getIt<LyricsResolutionWorker>().stop(),
    ]);
  }
}
