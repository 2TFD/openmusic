import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

/// Client-side orchestration of per-track `POST /v1/tracks` uploads.
///
/// - bounded concurrency (default 2);
/// - retries only failures the backend marks `retryable` (e.g.
///   INGESTION_IN_PROGRESS, STORAGE_UNAVAILABLE, RATE_LIMITED) and transport
///   failures with uncertain outcome, honouring `Retry-After`. Every retry
///   re-sends the SAME request: same track id, same Idempotency-Key;
/// - one failed item never cancels the others;
/// - [stop] prevents queued items from starting; in-flight and completed
///   uploads are preserved.
class CloudImportBatch {
  CloudImportBatch({
    required CloudTrackUploadRepository uploader,
    this.concurrency = 2,
    this.maxAttempts = 5,
    this.initialBackoff = const Duration(seconds: 2),
    this.onUploaded,
    Future<void> Function(Duration)? delay,
  }) : assert(concurrency > 0 && maxAttempts > 0),
       _uploader = uploader,
       _delay = delay ?? Future<void>.delayed;

  final CloudTrackUploadRepository _uploader;
  final int concurrency;
  final int maxAttempts;
  final Duration initialBackoff;

  /// Invoked after each successful upload, e.g. to refresh the cloud library.
  /// ML analysis is asynchronous on the backend; success does not wait for it.
  final FutureOr<void> Function(CloudTrack track)? onUploaded;
  final Future<void> Function(Duration) _delay;

  final _states = <String, CloudUploadItemState>{};
  final _updates = StreamController<CloudUploadItemState>.broadcast();
  final _cancelSignal = Completer<void>();
  bool _stopped = false;

  Stream<CloudUploadItemState> get updates => _updates.stream;
  Map<String, CloudUploadItemState> get states => Map.unmodifiable(_states);
  bool get isStopped => _stopped;

  /// No further queued uploads start; in-flight uploads finish.
  void stop() => _stopped = true;

  /// Also aborts in-flight uploads.
  void cancelAll() {
    stop();
    if (!_cancelSignal.isCompleted) _cancelSignal.complete();
  }

  Future<Map<String, CloudUploadItemState>> run(
    List<CloudUploadRequest> requests,
  ) async {
    final queue = Queue.of(requests);
    for (final request in requests) {
      _emit(
        CloudUploadItemState(
          localId: request.localId,
          phase: CloudUploadPhase.queued,
        ),
      );
    }
    Future<void> worker() async {
      while (!_stopped && queue.isNotEmpty) {
        await _upload(queue.removeFirst());
      }
    }

    await Future.wait([
      for (var i = 0; i < math.min(concurrency, requests.length); i++) worker(),
    ]);
    for (final request in queue) {
      _emit(
        CloudUploadItemState(
          localId: request.localId,
          phase: CloudUploadPhase.skipped,
        ),
      );
    }
    await _updates.close();
    return states;
  }

  Future<void> _upload(CloudUploadRequest request) async {
    for (var attempt = 1; ; attempt++) {
      _emit(
        CloudUploadItemState(
          localId: request.localId,
          phase: attempt == 1
              ? CloudUploadPhase.uploading
              : CloudUploadPhase.retrying,
          attempt: attempt,
        ),
      );
      try {
        final track = await _uploader.upload(
          request,
          cancelled: _cancelSignal.future,
          onProgress: (sent, total) => _emit(
            CloudUploadItemState(
              localId: request.localId,
              phase: attempt == 1
                  ? CloudUploadPhase.uploading
                  : CloudUploadPhase.retrying,
              attempt: attempt,
              sentBytes: sent,
              totalBytes: total,
            ),
          ),
        );
        _emit(
          CloudUploadItemState(
            localId: request.localId,
            phase: CloudUploadPhase.succeeded,
            attempt: attempt,
            track: track,
          ),
        );
        await onUploaded?.call(track);
        return;
      } on OwlSonicApiException catch (error) {
        final canRetry =
            (error.retryable || error.isNetwork) &&
            !error.isCancelled &&
            attempt < maxAttempts &&
            !_stopped;
        if (!canRetry) {
          _fail(request, attempt, failureKindFor(error), error);
          return;
        }
        await _delay(
          error.retryAfter ?? initialBackoff * math.pow(2, attempt - 1).toInt(),
        );
        if (_stopped) {
          _fail(request, attempt, CloudUploadFailureKind.cancelled, error);
          return;
        }
      } on FileSystemException {
        _fail(request, attempt, CloudUploadFailureKind.fileMissing);
        return;
      } catch (_) {
        _fail(request, attempt, CloudUploadFailureKind.unknown);
        return;
      }
    }
  }

  void _fail(
    CloudUploadRequest request,
    int attempt,
    CloudUploadFailureKind kind, [
    OwlSonicApiException? error,
  ]) => _emit(
    CloudUploadItemState(
      localId: request.localId,
      phase: CloudUploadPhase.failed,
      attempt: attempt,
      failureKind: kind,
      errorCode: error?.code,
      errorMessage: error?.message,
      requestId: error?.requestId,
    ),
  );

  /// Classified by backend `error.code`; transport failures by kind.
  static CloudUploadFailureKind failureKindFor(OwlSonicApiException error) {
    if (error.isCancelled) return CloudUploadFailureKind.cancelled;
    if (error.isNetwork) return CloudUploadFailureKind.network;
    final byCode = CloudUploadFailureKind.fromCode(error.code);
    if (byCode != null) return byCode;
    if (error.isUnauthorized) return CloudUploadFailureKind.signedOut;
    final status = error.statusCode ?? 0;
    return status >= 500
        ? CloudUploadFailureKind.server
        : CloudUploadFailureKind.unknown;
  }

  void _emit(CloudUploadItemState state) {
    _states[state.localId] = state;
    if (!_updates.isClosed) _updates.add(state);
  }
}
