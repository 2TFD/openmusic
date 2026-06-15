import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

abstract class TrackSource {
  bool canHandle(String input);
  Future<TrackPreview> fetchTrackPreview(String input);
  Future<List<TrackPreview>> resolve(String input);
  Future<String> download(TrackPreview track);
  Future<Playlist> createPlaylist(String url, List<Track> tracks);
}
