import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/download_repository.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/usecases/complite_track_download_use_case.dart';

import '../repositories/track_repository.dart';

class AddTrackUseCase {
  final DownloadRepository downloadRepository;
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
            await trackRepository.addTrack(p.toTrack(null));

            if (p.source == SourceType.youtube) {
              // YouTube requires youtube_explode_dart — can't use background_downloader
              source
                  .download(p)
                  .then((filePath) async {
                    await completeDownload(trackId: p.id, filePath: filePath);
                  })
                  .catchError((e, st) {
                    AppLogger.log(
                      '[AddTrackUseCase] YouTube download failed for ${p.id}: $e\n$st',
                    );
                  });
            } else {
              await downloadRepository.enqueueTrackTask(
                DownloadTrackTask.fromPreview(p),
              );
            }
            return true;
          } catch (e, st) {
            await AppLogger.log(
              '[AddTrackUseCase.execute] Error adding/downloading track ${p.id}: $e, stackTrace: $st',
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
            '[AddTrackUseCase.execute] Warning: Failed to create playlist: $e, stackTrace: $st',
          );
        }
      }

      return previews.first.toTrack(null);
    } catch (e, st) {
      await AppLogger.log(
        '[AddTrackUseCase.execute] Error executing add track use case for input: $input, Error: $e, stackTrace: $st',
      );
      rethrow;
    }
  }
}
