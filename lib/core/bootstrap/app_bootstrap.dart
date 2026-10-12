import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_service.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/core/services/download/download_worker.dart';
import 'package:owlsonic/core/services/lyrics/lyrics_resolution_worker.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/repositories/track_removal_repository.dart';
import 'package:owlsonic/layers/domain/usecases/recover_listening_checkpoint_use_case.dart';

class AppBootstrap with WidgetsBindingObserver {
  final GetIt getIt;
  final Future<void> Function()? cleanupPendingOverride;
  final Future<void> Function()? recoverCheckpointOverride;
  final Future<void> Function()? startWorkersOverride;
  bool _observingLifecycle = false;
  Future<void>? _deferredStartup;

  AppBootstrap(
    this.getIt, {
    this.cleanupPendingOverride,
    this.recoverCheckpointOverride,
    this.startWorkersOverride,
  });

  Future<void> run() async {
    if (!_observingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    }
  }

  /// Starts maintenance and background workers after the first application
  /// frame. Repeated calls share the same work.
  Future<void> startDeferred() => _deferredStartup ??= _runDeferredStartup();

  Future<void> _runDeferredStartup() async {
    await _runDeferredStep(
      'cleanup',
      cleanupPendingOverride ?? getIt<TrackRemovalRepository>().cleanupPending,
    );
    await _runDeferredStep(
      'listening_recovery',
      recoverCheckpointOverride ??
          getIt<RecoverListeningCheckpointUseCase>().call,
    );
    await _initWorkers();
  }

  Future<void> _runDeferredStep(
    String name,
    Future<void> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      await operation();
      stopwatch.stop();
      await AppLogger.info(
        'Deferred startup $name: ${stopwatch.elapsedMilliseconds} ms',
        operation: 'startup.deferred.$name',
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      await AppLogger.warning(
        'Deferred startup $name failed after '
        '${stopwatch.elapsedMilliseconds} ms',
        operation: 'startup.deferred.$name',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) unawaited(stop());
    // Resume → delta sync; background → no polling. `inactive` (e.g. a
    // desktop window losing focus) is ignored to avoid needless syncs.
    if (getIt.isRegistered<CloudSyncCoordinator>()) {
      final coordinator = getIt<CloudSyncCoordinator>();
      if (state == AppLifecycleState.resumed) coordinator.setForeground(true);
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden) {
        coordinator.setForeground(false);
      }
    }
  }

  Future<void> _initWorkers() async {
    final override = startWorkersOverride;
    if (override != null) {
      await override();
      return;
    }
    unawaited(getIt<DownloadWorker>().startProcessing());
    unawaited(getIt<LyricsResolutionWorker>().start());
    // Cached library is already on screen; sync updates it progressively.
    if (getIt.isRegistered<CloudSyncCoordinator>()) {
      unawaited(getIt<CloudSyncCoordinator>().start());
    }
    if (getIt.isRegistered<AutoSyncService>()) {
      getIt<AutoSyncService>().start();
    }
  }

  Future<void> stop() async {
    if (_observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _observingLifecycle = false;
    }
    await Future.wait([
      getIt<DownloadWorker>().stop(),
      getIt<LyricsResolutionWorker>().stop(),
    ]);
  }
}
