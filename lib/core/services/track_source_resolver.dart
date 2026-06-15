import 'package:openmusic/layers/domain/repositories/track_source.dart';

class TrackSourceResolver {
  final List<TrackSource> sources;

  TrackSourceResolver(this.sources);

  TrackSource resolveByUrl(String url) {
    return sources.firstWhere(
      (s) => s.canHandle(url),
      orElse: () => throw Exception('No source for $url'),
    );
  }
}
