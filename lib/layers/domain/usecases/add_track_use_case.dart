import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_ingestion_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';

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
  });

  final List<Track> addedTracks;
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
  });

  final TrackSourceResolver trackResolver;
  final TrackRepository trackRepository;
  final TrackIngestionRepository ingestionRepository;
  final PlaylistRepository playlistRepository;

  Future<AddTrackResult> execute(String input) async {
    try {
      final source = trackResolver.resolveByUrl(input);
      return addResolved(await source.resolve(input));
    } catch (error, stackTrace) {
      await AppLogger.log(
        '[AddTrackUseCase] Error for input: $input, Error: $error, stackTrace: $stackTrace',
      );
      rethrow;
    }
  }

  Future<AddTrackResult> addResolved(ResolvedTrackInput resolved) async {
    if (resolved.tracks.isEmpty) {
      throw const EmptyResultFailure('resolve tracks');
    }
    final source = trackResolver.resolveByType(resolved.sourceType);

    final outcomes = await Future.wait(
      resolved.tracks.map((preview) => _addPreview(source, preview)),
      eagerError: false,
    );
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

    return AddTrackResult(
      addedTracks: addedTracks,
      failures: failures,
      playlist: playlist,
      playlistFailure: playlistFailure,
    );
  }

  Future<_AddTrackOutcome> _addPreview(
    TrackSource source,
    TrackPreview preview,
  ) async {
    try {
      final existingTrack = await trackRepository.getTrackById(preview.id);
      if (existingTrack?.filePath != null) {
        return _AddTrackOutcome.success(existingTrack!);
      }

      final track = existingTrack ?? preview.toTrack(null);

      if (preview.source == SourceType.localFile) {
        final path = await source.download(preview);
        final persisted = await ingestionRepository.ingestLocal(
          track,
          filePath: path,
        );
        return _AddTrackOutcome.success(persisted);
      }

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
}

class _AddTrackOutcome {
  const _AddTrackOutcome._({this.track, this.failure});

  factory _AddTrackOutcome.success(Track track) =>
      _AddTrackOutcome._(track: track);
  factory _AddTrackOutcome.failed(AddTrackItemFailure failure) =>
      _AddTrackOutcome._(failure: failure);

  final Track? track;
  final AddTrackItemFailure? failure;
}
