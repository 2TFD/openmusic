import 'dart:math' as math;
import 'dart:async';

import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/track_source_resolver.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/playlist_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_duplicate_lookup.dart';
import 'package:owlsonic/layers/domain/repositories/track_ingestion_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_content_identity_service.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:owlsonic/layers/domain/usecases/queue_lyrics_resolution_use_case.dart';

class AddTrackItemFailure {
  const AddTrackItemFailure({required this.preview, required this.failure});

  final TrackPreview preview;
  final Failure failure;
}

class AddTrackResult {
  const AddTrackResult({
    required this.addedTracks,
    required this.failures,
    this.playlist,
    this.playlistFailure,
    this.existingTrackIds = const {},
  });

  final List<Track> addedTracks;

  /// Ids in [addedTracks] that were already in the library, so no new track
  /// or audio object was created for them.
  final Set<String> existingTrackIds;
  final List<AddTrackItemFailure> failures;
  final Playlist? playlist;
  final Failure? playlistFailure;

  bool get isPartial => addedTracks.isNotEmpty && failures.isNotEmpty;
  bool get isEmpty => addedTracks.isEmpty;
  Track? get firstTrack => addedTracks.firstOrNull;
}

class AddTrackUseCase {
  AddTrackUseCase({
    required this.trackResolver,
    required this.trackRepository,
    required this.ingestionRepository,
    required this.playlistRepository,
    required this.contentIdentityService,
    required this.analytics,
    this.queueLyrics,
    this.duplicateLookup,
  });

  final TrackSourceResolver trackResolver;
  final TrackRepository trackRepository;
  final TrackIngestionRepository ingestionRepository;
  final PlaylistRepository playlistRepository;
  final TrackContentIdentityService contentIdentityService;
  final AnalyticsTracker analytics;
  final QueueLyricsResolutionUseCase? queueLyrics;
  final TrackDuplicateLookup? duplicateLookup;

  Future<AddTrackResult> execute(String rawInput) async {
    final input = TrackSourceResolver.normalizeInput(rawInput);
    try {
      final source = trackResolver.resolveByUrl(input);
      return await addResolved(await source.resolve(input));
    } catch (error) {
      unawaited(
        analytics.logEvent(
          'music_import_failed',
          properties: {
            'source_category': 'other',
            'error_category': _errorCategory(failureFromException(error)),
          },
        ),
      );
      await AppLogger.warning('Import failed', operation: 'music.import');
      rethrow;
    }
  }

  Future<AddTrackResult> addResolved(ResolvedTrackInput resolved) async {
    if (resolved.tracks.isEmpty) {
      throw const EmptyResultFailure('resolve tracks');
    }
    final source = trackResolver.resolveByType(resolved.sourceType);
    final outcomes = await _addAll(source, resolved.tracks);
    final addedTracks = outcomes
        .map((outcome) => outcome.track)
        .whereType<Track>()
        .toList();
    final failures = outcomes
        .map((outcome) => outcome.failure)
        .whereType<AddTrackItemFailure>()
        .toList();

    Playlist? playlist;
    Failure? playlistFailure;
    final collection = resolved.collection;
    if (collection != null && addedTracks.isNotEmpty) {
      try {
        final candidate = Playlist(
          id: collection.id,
          name: collection.name,
          trackIds: addedTracks.map((track) => track.id).toList(),
          createdAt: DateTime.now(),
          description: collection.description,
          imageUrl: collection.imageUrl,
        );
        final existing = await playlistRepository.getPlaylistById(candidate.id);
        if (existing == null) {
          await playlistRepository.createPlaylist(candidate);
          playlist = candidate;
        } else {
          for (final track in addedTracks) {
            await playlistRepository.addTrackToPlaylist(existing.id, track.id);
          }
          playlist = await playlistRepository.getPlaylistById(existing.id);
        }
      } catch (error, stackTrace) {
        playlistFailure = failureFromException(error);
        await AppLogger.log(
          '[AddTrackUseCase] Playlist creation failed: $error, stackTrace: $stackTrace',
        );
      }
    }

    if (addedTracks.isNotEmpty) {
      unawaited(
        analytics.logEvent(
          'music_import_completed',
          properties: {'source_category': _sourceCategory(resolved.sourceType)},
        ),
      );
    }
    if (failures.isNotEmpty) {
      unawaited(
        analytics.logEvent(
          'music_import_failed',
          properties: {
            'source_category': _sourceCategory(resolved.sourceType),
            'error_category': _errorCategory(failures.first.failure),
          },
        ),
      );
    }

    return AddTrackResult(
      addedTracks: addedTracks,
      failures: failures,
      playlist: playlist,
      playlistFailure: playlistFailure,
      existingTrackIds: outcomes
          .where((outcome) => outcome.existed)
          .map((outcome) => outcome.track!.id)
          .toSet(),
    );
  }

  /// Collections can hold thousands of tracks; adding them all at once floods
  /// the database queue and memory, so at most [_maxParallelAdds] run at once.
  static const _maxParallelAdds = 6;

  Future<List<_AddTrackOutcome>> _addAll(
    TrackSource source,
    List<TrackPreview> previews,
  ) async {
    final outcomes = List<_AddTrackOutcome?>.filled(previews.length, null);
    var next = 0;
    Future<void> lane() async {
      while (next < previews.length) {
        final index = next++;
        outcomes[index] = await _addPreview(source, previews[index]);
      }
    }

    await Future.wait(
      List.generate(math.min(_maxParallelAdds, previews.length), (_) => lane()),
    );
    return outcomes.cast<_AddTrackOutcome>();
  }

  Future<_AddTrackOutcome> _addPreview(
    TrackSource source,
    TrackPreview preview,
  ) async {
    try {
      final contentIdentity = await contentIdentityService.createFor(preview);
      var existingTrack = await trackRepository.getTrackById(preview.id);
      if (existingTrack != null &&
          preview.source == SourceType.localFile &&
          existingTrack.source.originalUrl != preview.originalUrl &&
          (contentIdentity == null ||
              existingTrack.contentIdentity != contentIdentity)) {
        // Local ids are a 32-bit path hash: another file with the same id is a
        // collision, not this track. Give this file an id of its own.
        preview = preview.copyWith(
          id: '${preview.id}-${_identitySuffix(contentIdentity, preview)}',
        );
        existingTrack = await trackRepository.getTrackById(preview.id);
      }
      if (existingTrack == null && contentIdentity != null) {
        // Same audio under a different id (a moved file, or a Spotify match of
        // a YouTube video already imported): reuse the library entry instead
        // of creating a second track pointing at the same audio.
        final sameAudio = await duplicateLookup?.findByContentIdentity(
          contentIdentity,
        );
        if (sameAudio != null)
          return _AddTrackOutcome.success(sameAudio, existed: true);
      }
      if (existingTrack?.filePath != null) {
        if (existingTrack!.contentIdentity == null && contentIdentity != null) {
          final withIdentity = existingTrack.copyWith(
            contentIdentity: contentIdentity,
          );
          final persisted = preview.source == SourceType.localFile
              ? await ingestionRepository.ingestLocal(
                  withIdentity,
                  filePath: existingTrack.filePath!,
                )
              : await ingestionRepository.ingestRemote(withIdentity);
          await _queueAnalysisIfAvailable(persisted);
          return _AddTrackOutcome.success(persisted, existed: true);
        }
        await _queueAnalysisIfAvailable(existingTrack);
        return _AddTrackOutcome.success(existingTrack, existed: true);
      }

      final track = existingTrack == null
          ? preview.toTrack(null, contentIdentity: contentIdentity)
          : existingTrack.contentIdentity == null
          ? existingTrack.copyWith(contentIdentity: contentIdentity)
          : existingTrack;

      if (preview.source == SourceType.localFile) {
        final path = await source.download(preview);
        final persisted = await ingestionRepository.ingestLocal(
          track,
          filePath: path,
        );
        await _queueAnalysisIfAvailable(persisted);
        return _AddTrackOutcome.success(persisted);
      }

      // ingestRemote also queues the download in the same transaction.
      final persisted = await ingestionRepository.ingestRemote(track);
      return _AddTrackOutcome.success(persisted);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[AddTrackUseCase] Error adding track ${preview.id}: $error, stackTrace: $stackTrace',
      );
      return _AddTrackOutcome.failed(
        AddTrackItemFailure(
          preview: preview,
          failure: failureFromException(error),
        ),
      );
    }
  }

  Future<void> _queueAnalysisIfAvailable(Track track) async {
    if (track.filePath == null) return;
    final lyricsQueue = queueLyrics;
    if (lyricsQueue == null) return;
    try {
      await lyricsQueue(track);
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[AddTrackUseCase] Lyrics queue failed for ${track.id}: '
        '$error, stackTrace: $stackTrace',
      );
    }
  }
}

String _identitySuffix(String? contentIdentity, TrackPreview preview) {
  final digest = contentIdentity?.split(':').last;
  if (digest != null && digest.length >= 12) return digest.substring(0, 12);
  return preview.originalUrl.hashCode.toUnsigned(32).toRadixString(16);
}

class _AddTrackOutcome {
  const _AddTrackOutcome._({this.track, this.failure, this.existed = false});

  factory _AddTrackOutcome.success(Track track, {bool existed = false}) =>
      _AddTrackOutcome._(track: track, existed: existed);
  factory _AddTrackOutcome.failed(AddTrackItemFailure failure) =>
      _AddTrackOutcome._(failure: failure);

  final Track? track;
  final AddTrackItemFailure? failure;
  final bool existed;
}

String _sourceCategory(SourceType source) => switch (source) {
  SourceType.localFile => 'local',
  SourceType.youtube => 'youtube',
  SourceType.soundcloud => 'soundcloud',
  SourceType.spotify => 'spotify',
  SourceType.owlsonic => 'cloud',
  SourceType.unknown => 'other',
};

String _errorCategory(Failure failure) => switch (failure) {
  NetworkFailure() || RateLimitFailure() => 'network',
  DbFailure() ||
  StorageFailure() ||
  FileNotFoundFailure() ||
  PermissionFailure() => 'storage',
  UnsupportedSourceFailure() || UnsupportedMediaFailure() => 'unsupported',
  RemoteServiceFailure() || CloudUploadFailure() => 'server',
  _ => 'unknown',
};
