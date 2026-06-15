import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

abstract class SearchSource {
  Future<List<Track>> searchLocal(String query);
  Future<List<TrackPreview>> searchExternal(String query, {int offset = 0});
}
