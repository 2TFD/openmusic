import 'dart:async';

import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/services/download/download_failure_classifier.dart';
import 'package:owlsonic/core/services/track_source_resolver.dart';
import 'package:owlsonic/core/services/task_lease.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/repositories/download_task_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:owlsonic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:uuid/uuid.dart';

class DownloadWorker {
  final DownloadTaskRepository downloadRepository;
  final TrackSourceResolver trackResolver;
  final CompleteTrackDownloadUseCase completeDownload;
  final AnalyticsTracker analytics;

  /// Title and artist for file names when the source is not re-resolved.
  final TrackRepository? trackRepository;

  /// A failure with one of these codes is temporary (a bot check on this
  /// network, no connection, a rate limit): the task goes back to the queue
  /// on its own after [retryFailedAfter], checked every [retryCheckInterval]
  /// while the queue is idle.
  static const temporaryFailureCodes = {
    DownloadFailureCodes.botCheck,
    DownloadFailureCodes.network,
    DownloadFailureCodes.rateLimited,
  };
  final Duration retryFailedAfter;
  final Duration retryCheckInterval;
  DateTime? _lastRetryCheck;
  final String _ownerId;

  bool _isRunning = false;
  Future<void>? _processing;
  OperationCancellation? _inFlightCancellation;

  DownloadWorker({
    required this.downloadRepository,
    required this.trackResolver,
    required this.completeDownload,
    this.analytics = const NoopAnalyticsTracker(),
    this.trackRepository,
    this.retryFailedAfter = const Duration(minutes: 20),
    this.retryCheckInterval = const Duration(minutes: 1),
    String? ownerId,
  }) : _ownerId = ownerId ?? const Uuid().v4();

  Future<void> startProcessing() {
    final active = _processing;
    if (active != null) return active;
    _isRunning = true;
    final processing = _processQueue();
    _processing = processing;
    return processing.whenComplete(() {
      if (identical(_processing, processing)) _processing = null;
      _isRunning = false;
    });
  }

  Future<void> stop() async {
    _isRunning = false;
    _inFlightCancellation?.cancel();
    await _processing;
  }

  Future<void> _requeueTemporaryFailures() async {
    final now = DateTime.now();
    final last = _lastRetryCheck;
    if (last != null && now.difference(last) < retryCheckInterval) return;
    _lastRetryCheck = now;
    try {
      await downloadRepository.requeueFailed(
        codes: temporaryFailureCodes,
        failedBefore: now.subtract(retryFailedAfter),
      );
    } catch (error, stackTrace) {
      await AppLogger.warning(
        'Could not re-queue temporarily failed downloads.',
        operation: 'download_worker.requeue_failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<TrackPreview?> _directPreview(
    TrackSource source,
    DownloadTrackTask task,
    Track? track,
  ) async {
    if (source is! DirectDownloadSource) return null;
    final artists = track?.artists.map((artist) => artist.name).join(', ');
    return (source as DirectDownloadSource).previewForDownload(
      task.originalUrl,
      title: track?.title,
      artist: artists == null || artists.isEmpty ? null : artists,
    );
  }

  Future<TrackPreview> _resolvedPreview(
    TrackSource source,
    DownloadTrackTask task,
  ) async {
    final resolved = await source.resolve(task.originalUrl);
    return resolved.tracks.firstWhere(
      (preview) => preview.id == task.trackId,
      orElse: () => resolved.firstTrack,
    );
  }

  Future<({String filePath, MediaLocator? media})> _downloadWithFallback(
    TrackSource source,
    TrackPreview preview,
    Track? track,
    OperationCancellation cancellation,
  ) async {
    try {
      final filePath = await source.download(
        preview,
        cancellation: cancellation,
      );
      return (filePath: filePath, media: null);
    } catch (error, stackTrace) {
      cancellation.throwIfCancelled();
      final failure = failureFromException(error);
      final canFallback =
          source.sourceType == SourceType.youtube &&
          track?.source.type == SourceType.spotify &&
          track?.source.media?.type == SourceType.youtube &&
          (failure is YouTubeFailure ||
              failure is RemoteAccessFailure ||
              failure is RateLimitFailure ||
              failure is NetworkFailure ||
              failure is UnsupportedMediaFailure);
      if (!canFallback) Error.throwWithStackTrace(error, stackTrace);

      final spotify = trackResolver.resolveByType(SourceType.spotify);
      if (spotify is! TrackAudioFallback) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      final alternate = await (spotify as TrackAudioFallback).findFallback(
        track!,
      );
      if (alternate == null || alternate.source != SourceType.soundcloud) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      cancellation.throwIfCancelled();
      final alternateSource = trackResolver.resolveByType(alternate.source);
      final filePath = await alternateSource.download(
        alternate,
        cancellation: cancellation,
      );
      return (
        filePath: filePath,
        media: MediaLocator(
          type: alternate.source,
          id: alternate.id,
          url: alternate.originalUrl,
        ),
      );
    }
  }

  Future<void> _processQueue() async {
    while (_isRunning) {
      DownloadTrackTask? task;
      OperationCancellation? cancellation;
      try {
        // Claiming includes the status transition. There is deliberately no
        // separate get-then-mark sequence (TOCTOU race).
        task = await downloadRepository.claimNext(ownerId: _ownerId);
        if (task == null) {
          await _requeueTemporaryFailures();
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        cancellation = OperationCancellation();
        _inFlightCancellation = cancellation;
        final source = trackResolver.resolveByUrl(task.originalUrl);
        final heartbeat = LeaseHeartbeat(
          interval: TaskLeasePolicy.heartbeatInterval,
          renew: () => downloadRepository.renewLease(
            trackId: task!.trackId,
            ownerId: _ownerId,
          ),
        );
        final result = await heartbeat.run(task.trackId, () async {
          final track = await trackRepository
              ?.getTrackById(task!.trackId)
              .catchError((Object _) => null);
          final preview =
              await _directPreview(source, task!, track) ??
              await _resolvedPreview(source, task!);
          cancellation!.throwIfCancelled();
          return _downloadWithFallback(source, preview, track, cancellation);
        });
        cancellation.throwIfCancelled();
        final completed = await completeDownload.completeClaimed(
          trackId: task.trackId,
          filePath: result.filePath,
          ownerId: _ownerId,
          media: result.media,
        );
        if (!completed) throw TaskLeaseLostException(task.trackId);
        unawaited(analytics.logEvent('offline_download_completed'));
      } catch (e, st) {
        final failure = failureFromException(e);
        if (failure is UnknownFailure) {
          await AppLogger.captureException(
            e,
            st,
            operation: 'download_worker.process',
            message: 'Download worker failed unexpectedly',
          );
        } else {
          await AppLogger.warning(
            '[DownloadWorker] Error processing ${task?.trackId}',
            operation: 'download_worker.process',
            error: e,
            stackTrace: st,
          );
        }
        if (task != null) {
          final trackId = task.trackId;
          final terminalUpdate =
              cancellation?.isCancelled == true ||
                  e is OperationCancelledException ||
                  e is TaskLeaseLostException
              ? downloadRepository.releaseLease(
                  trackId: trackId,
                  ownerId: _ownerId,
                )
              : downloadRepository.markFailed(
                  trackId: trackId,
                  ownerId: _ownerId,
                  failure: DownloadFailureClassifier.classify(
                    e,
                    st,
                    trackId: trackId,
                    originalUrl: task.originalUrl,
                  ),
                );
          await terminalUpdate.catchError((error, stackTrace) {
            AppLogger.captureException(
              error,
              stackTrace,
              operation: 'download_worker.terminal_update',
              message: 'Download worker could not save terminal state',
            );
            return false;
          });
        }
        if (_isRunning && cancellation?.isCancelled != true) {
          await Future.delayed(const Duration(seconds: 5));
        }
      } finally {
        if (identical(_inFlightCancellation, cancellation)) {
          _inFlightCancellation = null;
        }
      }
    }
  }
}
