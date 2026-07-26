import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/local_track_picker.dart';

class PickLocalTracksUseCase {
  const PickLocalTracksUseCase(this._picker);

  final LocalTrackPicker _picker;

  Future<List<TrackPreview>> call() => _picker.pickTracks();
}
