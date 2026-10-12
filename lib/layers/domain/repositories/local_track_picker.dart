import 'package:owlsonic/layers/domain/entities/track_preview.dart';

abstract interface class LocalTrackPicker {
  Future<List<TrackPreview>> pickTracks();

  /// Releases temporary copies the platform picker made of picked files.
  Future<void> clearPickedCache();
}
