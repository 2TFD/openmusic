import 'package:openmusic/layers/domain/entities/track_preview.dart';

abstract interface class LocalTrackPicker {
  Future<List<TrackPreview>> pickTracks();
}
