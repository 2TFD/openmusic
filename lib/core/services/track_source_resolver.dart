import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:openmusic/layers/domain/entities/source.dart';

class TrackSourceResolver {
  final List<TrackSource> sources;

  TrackSourceResolver(this.sources);

  TrackSource resolveByUrl(String url) {
    return sources.firstWhere(
      (s) => s.canHandle(url),
      orElse: () => throw UnsupportedSourceFailure(url),
    );
  }

  TrackSource resolveByType(SourceType type) {
    return sources.firstWhere(
      (source) => source.sourceType == type,
      orElse: () => throw UnsupportedSourceFailure(type.name),
    );
  }
}
