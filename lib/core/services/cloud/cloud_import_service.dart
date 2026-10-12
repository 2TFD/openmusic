import 'dart:async';

import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_batch.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:path/path.dart' as p;

/// A file to upload as a new cloud track (import review or migration).
class CloudImportSource {
  const CloudImportSource({
    required this.key,
    required this.audioPath,
    required this.title,
    this.artistName,
    this.albumTitle,
    this.year,
    this.artworkPath,
    this.contentIdentity,
    this.sourceTrackId,
    this.sourceProvider,
  });

  /// Caller identity of the item (e.g. the review row path).
  final String key;
  final String audioPath;
  final String title;
  final String? artistName;
  final String? albumTitle;
  final int? year;

  /// Local artwork file (extracted at scan time); uploaded when present.
  final String? artworkPath;
  final String? contentIdentity;

  /// Local-only track being migrated; re-keyed to the cloud id on success.
  final String? sourceTrackId;

  /// Set for audio downloaded from a link (`COMMUNITY_IMPORT`); null for
  /// files the user owns (`LOCAL_UPLOAD`).
  final String? sourceProvider;
}

/// Uploads tracks to OwlSonic (`POST /v1/tracks`). A 201 is a finished import:
/// the track is written to the local library immediately and sync is
/// requested; backend analysis continues asynchronously.
///
/// Account isolation: a batch belongs to the session it started in. Its
/// requests are bound to that session (never sent or retried with another
/// account's token), it is cancelled when the session ends, results arriving
/// afterwards are not written locally, and its unfinished upload records are
/// discarded so they never resume under the next account. The user's files
/// are never touched.
class CloudImportService {
  CloudImportService({
    required AuthSession session,
    required bool configured,
    required CloudTrackUploadRepository uploader,
    required CloudUploadStore uploads,
    required CloudLocalStore local,
    void Function()? onLibraryChanged,
    Future<void> Function(Duration)? delay,
    AutoSyncPolicy? policy,
    this.concurrency = 2,
  }) : _session = session,
       _policy = policy,
       _configured = configured,
       _uploader = uploader,
       _uploads = uploads,
       _local = local,
       _onLibraryChanged = onLibraryChanged,
       _delay = delay;

  final AuthSession _session;
  final AutoSyncPolicy? _policy;
  final bool _configured;
  final CloudTrackUploadRepository _uploader;
  final CloudUploadStore _uploads;
  final CloudLocalStore _local;
  final void Function()? _onLibraryChanged;
  final Future<void> Function(Duration)? _delay;
  final int concurrency;
  CloudImportBatch? _batch;

  /// The backend is configured in this build (regardless of sign-in).
  bool get configured => _configured;

  /// Cloud import replaces local-only persistence while signed in.
  bool get enabled => _configured && _session.isSignedIn;

  /// Signed in, auto-sync is on, and the connection is allowed ("Wi-Fi
  /// only"): imports go to OwlSonic right away instead of staying on the
  /// device. Otherwise imports stay local and auto-sync uploads them later.
  Future<bool> autoUploadAllowed() async =>
      enabled && (_policy == null || await _policy.allowsUploadNow());

  /// Placeholder the local scanner uses when a file has no artist tag; it is
  /// not real metadata and is not sent to the shared catalog.
  static const _unknownArtist = 'Unknown Artist';

  /// Stops starting queued uploads; in-flight ones finish.
  void stop() => _batch?.stop();

  Future<Map<String, CloudUploadItemState>> importAll(
    List<CloudImportSource> sources, {
    void Function(String key, CloudUploadItemState state)? onUpdate,
  }) async {
    final epoch = _session.epoch;
    final keyByRecord = <String, String>{};
    final requests = <CloudUploadRequest>[];
    for (final source in sources) {
      final record = await _uploads.createOrReuse(
        audioPath: source.audioPath,
        artworkPath: source.artworkPath,
        sourceTrackId: source.sourceTrackId,
        contentIdentity: source.contentIdentity,
        manifestFor: (trackId) => TrackManifest(
          trackId: trackId,
          sourceProvider: source.sourceProvider,
          title: source.title.trim().isEmpty
              ? p.basenameWithoutExtension(source.audioPath)
              : source.title,
          artistName: source.artistName == _unknownArtist
              ? null
              : source.artistName,
          albumTitle: source.albumTitle,
          year: source.year,
        ),
      );
      keyByRecord[record.id] = source.key;
      requests.add(record.request);
    }
    final result = await _run(requests, keyByRecord, onUpdate, epoch);

    // TRACK_ID_CONFLICT: our generated id is taken; retry once as a new
    // logical upload (new id and key). Never reuse the old key for it.
    final conflicted = [
      for (final entry in result.entries)
        if (entry.value.failureKind == CloudUploadFailureKind.trackIdConflict)
          entry.key,
    ];
    if (conflicted.isNotEmpty && _session.isCurrent(epoch)) {
      final retry = <CloudUploadRequest>[];
      for (final recordId in conflicted) {
        retry.add((await _uploads.regenerateIdentity(recordId)).request);
      }
      result.addAll(await _run(retry, keyByRecord, onUpdate, epoch));
    }
    return {
      for (final entry in result.entries) keyByRecord[entry.key]!: entry.value,
    };
  }

  /// Resumes uploads interrupted by a restart or a retryable failure, with
  /// their persisted track id and Idempotency-Key.
  Future<void> resumePending() async {
    if (!enabled || _batch != null) return;
    final epoch = _session.epoch;
    final pending = await _uploads.pending();
    if (pending.isEmpty) return;
    await _run(
      [for (final record in pending) record.request],
      {for (final record in pending) record.id: record.id},
      null,
      epoch,
    );
  }

  Future<Map<String, CloudUploadItemState>> _run(
    List<CloudUploadRequest> requests,
    Map<String, String> keyByRecord,
    void Function(String key, CloudUploadItemState state)? onUpdate,
    int epoch,
  ) async {
    final batch = CloudImportBatch(
      uploader: _uploader,
      concurrency: concurrency,
      delay: _delay,
      onUploaded: (track) => _onUploaded(track, epoch),
    );
    _batch = batch;
    final subscription = batch.updates.listen((state) {
      onUpdate?.call(keyByRecord[state.localId] ?? state.localId, state);
    });
    // Sign-out or another account: abort in-flight uploads, start no more.
    final sessionWatch = _session.changes.listen((_) {
      if (!_session.isCurrent(epoch)) batch.cancelAll();
    });
    if (!_session.isCurrent(epoch)) batch.cancelAll();
    try {
      final states = await _session.bind(epoch, () => batch.run(requests));
      if (!_session.isCurrent(epoch)) {
        await _uploads.discardUnfinished(
          requests.map((request) => request.localId),
        );
        return Map.of(states);
      }
      for (final state in states.values) {
        if (state.phase != CloudUploadPhase.failed) continue;
        await _uploads.markFailed(
          state.localId,
          code: state.errorCode ?? state.failureKind?.name,
          message: state.errorMessage,
          retryable: _resumable(state.failureKind),
          attempts: state.attempt,
        );
      }
      return Map.of(states);
    } finally {
      await sessionWatch.cancel();
      await subscription.cancel();
      if (identical(_batch, batch)) _batch = null;
    }
  }

  Future<void> _onUploaded(CloudTrack track, int epoch) async {
    // A result for a session that ended belongs to that account; its next
    // sync brings the track in. Never write it into another account's view.
    if (!_session.isCurrent(epoch)) return;
    final record = await _uploads.byTrackId(track.id);
    if (record == null) return;
    try {
      final source = record.sourceTrackId;
      if (source != null) {
        await _local.adoptMigratedTrack(localTrackId: source, uploaded: track);
      } else {
        await _local.insertUploadedTrack(
          track,
          localAudioPath: record.request.audioPath,
          localArtworkPath: record.request.artworkPath,
          contentIdentity: record.contentIdentity,
        );
      }
      await _uploads.markSucceeded(record.id);
    } catch (error, stackTrace) {
      // The upload itself succeeded; the next sync brings the track in.
      await AppLogger.captureException(
        error,
        stackTrace,
        operation: 'owlsonic.import.persist',
      );
      await AppLogger.warning(
        'Uploaded track could not be written locally; sync will repair it.',
        operation: 'owlsonic.import.persist',
        error: error,
        stackTrace: stackTrace,
      );
      await _uploads.markSucceeded(record.id);
    }
    _onLibraryChanged?.call();
  }

  /// Failures whose outcome may still change with the same request.
  static bool _resumable(CloudUploadFailureKind? kind) => switch (kind) {
    CloudUploadFailureKind.network ||
    CloudUploadFailureKind.ingestionInProgress ||
    CloudUploadFailureKind.rateLimited ||
    CloudUploadFailureKind.storageUnavailable ||
    CloudUploadFailureKind.serviceUnavailable ||
    CloudUploadFailureKind.signedOut ||
    CloudUploadFailureKind.cancelled => true,
    _ => false,
  };
}
