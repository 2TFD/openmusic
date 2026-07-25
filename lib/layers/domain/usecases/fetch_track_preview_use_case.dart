import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';

class FetchTrackPreviewUseCase {
  final TrackSourceResolver _trackResolver;

  FetchTrackPreviewUseCase({required TrackSourceResolver trackResolver})
    : _trackResolver = trackResolver;

  Future<TrackPreview> call(String url) async {
    final source = _trackResolver.resolveByUrl(url);
    return source.fetchTrackPreview(url);
  }
}
