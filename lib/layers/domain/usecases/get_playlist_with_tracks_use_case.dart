import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class PlaylistWithTracks {
  final Playlist playlist;
  final List<Track> tracks;

  const PlaylistWithTracks({required this.playlist, required this.tracks});
}

class GetPlaylistWithTracksUseCase {
  final PlaylistRepository _playlistRepository;
  final TrackRepository _trackRepository;

  GetPlaylistWithTracksUseCase({
    required PlaylistRepository playlistRepository,
    required TrackRepository trackRepository,
  }) : _playlistRepository = playlistRepository,
       _trackRepository = trackRepository;

  Future<PlaylistWithTracks> call(String playlistId) async {
    final playlist = await _playlistRepository.getPlaylistById(playlistId);
    if (playlist == null) throw Exception('Playlist not found');

    final tracks = await _trackRepository.getTracksByIds(playlist.trackIds);
    final trackMap = {for (final t in tracks) t.id: t};
    final ordered = playlist.trackIds
        .map((id) => trackMap[id])
        .whereType<Track>()
        .toList();

    return PlaylistWithTracks(playlist: playlist, tracks: ordered);
  }
}
