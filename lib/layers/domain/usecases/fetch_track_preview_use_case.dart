import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';

class FetchTrackPreviewUseCase {
  final TrackSourceResolver _trackResolver;

  FetchTrackPreviewUseCase({required TrackSourceResolver trackResolver})
    : _trackResolver = trackResolver;

  Future<ResolvedTrackInput> call(String url) async {
    final source = _trackResolver.resolveByUrl(url);
    final resolved = await source.resolve(url);
    if (resolved.tracks.isEmpty) {
      throw const EmptyResultFailure('resolve tracks');
    }
    return resolved;
  }
}
