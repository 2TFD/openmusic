import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/local_track_picker.dart';

class PickLocalTracksUseCase {
  const PickLocalTracksUseCase(this._picker);

  final LocalTrackPicker _picker;

  Future<List<TrackPreview>> call() => _picker.pickTracks();

  /// Call once picked files are imported; their picker copies are no longer
  /// needed.
  Future<void> clearPickedCache() => _picker.clearPickedCache();
}
