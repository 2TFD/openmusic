import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';

import '../repositories/track_repository.dart';

class AddTrackUseCase {
  final DownloadTaskRepository downloadRepository;
  final CompleteTrackDownloadUseCase completeDownload;
  final TrackSourceResolver trackResolver;
  final TrackRepository trackRepository;
  final PlaylistRepository playlistRepository;

  AddTrackUseCase({
    required this.downloadRepository,
    required this.completeDownload,
    required this.trackResolver,
    required this.trackRepository,
    required this.playlistRepository,
  });

  Future<Track> execute(String input) async {
    try {
      final source = trackResolver.resolveByUrl(input);
      final previews = await source.resolve(input);

      if (previews.isEmpty) {
        throw Exception('No tracks found from source');
      }

      final results = await Future.wait(
        previews.map((p) async {
          try {
            final existingTrack = await trackRepository.getTrackById(p.id);
            if (existingTrack == null) {
              await trackRepository.addTrack(p.toTrack(null));
            } else if (existingTrack.filePath != null) {
              return true;
            }

            if (p.source == SourceType.localFile) {
              final path = await source.download(p);
              await completeDownload.call(trackId: p.id, filePath: path);
            } else {
              await downloadRepository.enqueue(p.id, p.originalUrl);
            }
            return true;
          } catch (e, st) {
            await AppLogger.log(
              '[AddTrackUseCase] Error adding track ${p.id}: $e, stackTrace: $st',
            );
            return false;
          }
        }),
        eagerError: false,
      );

      if (!results.contains(true)) {
        throw Exception('Failed to add any tracks from source');
      }

      if (previews.length > 1) {
        try {
          await playlistRepository.createPlaylist(
            Playlist(
              id: previews.first.id,
              name: "${previews.first.title} playlist",
              trackIds: previews.map((e) => e.id).toList(),
              createdAt: DateTime.now(),
              imageUrl: previews.first.artworkUrl,
              description: null,
            ),
          );
        } catch (e, st) {
          await AppLogger.log(
            '[AddTrackUseCase] Warning: failed to create playlist: $e, stackTrace: $st',
          );
        }
      }

      return previews.first.toTrack(null);
    } catch (e, st) {
      await AppLogger.log(
        '[AddTrackUseCase] Error for input: $input, Error: $e, stackTrace: $st',
      );
      rethrow;
    }
  }
}
