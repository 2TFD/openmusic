import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';

class TrackSourceResolver {
  final List<TrackSource> sources;

  TrackSourceResolver(this.sources);

  static final _urlPattern = RegExp(r'''(https?://|spotify:)[^\s<>"']+''');

  /// Share sheets hand over text like "Listen to X on SoundCloud https://…";
  /// sources expect the bare link. Local paths and plain links pass through.
  static String normalizeInput(String input) {
    final value = input.trim();
    final match = _urlPattern.firstMatch(value);
    if (match == null) return value;
    return match.group(0)!.replaceFirst(RegExp(r'[).,!?;]+$'), '');
  }

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
