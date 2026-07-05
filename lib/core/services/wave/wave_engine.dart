import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'dart:math';

class WaveEngine {
  static List<Track> generate(WaveConfig config, List<Track> tracks) {
    if (tracks.isEmpty) return [];
    final List<Track> similarTracks = _getSimilarTracks(
      config.tracks,
      tracks,
    ).map((e) => e.track).toList();
    return similarTracks;
  }

  static List<_SimilarTrack> _getSimilarTracks(
    List<Track> targets,
    List<Track> allTracks,
  ) {
    try {
      final targetEmbedding = _averageEmbedding(targets);

      final result = allTracks
          .where(
            (track) =>
                !targets.contains(track) &&
                track.isReady &&
                track.embedding!.length == targetEmbedding.length,
          )
          .map((track) {
            return _SimilarTrack(
              track: track,
              similarity: _cosineSimilarity(targetEmbedding, track.embedding!),
            );
          })
          .toList();
      result.sort((a, b) => b.similarity.compareTo(a.similarity));

      return result;
    } catch (_) {
      return [];
    }
  }

  static List<double> _averageEmbedding(List<Track> tracks) {
    if (tracks.isEmpty) {
      throw ArgumentError('tracks is empty');
    }

    final dim = tracks.first.embedding?.length;
    if (dim == null) throw ArgumentError('embedding null');
    final avg = List<double>.filled(dim, 0);

    for (final track in tracks) {
      if (track.embedding == null) throw ArgumentError('embedding null');
      for (var i = 0; i < dim; i++) {
        avg[i] += track.embedding![i];
      }
    }

    for (var i = 0; i < dim; i++) {
      avg[i] /= tracks.length;
    }

    return avg;
  }

  static double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) {
      return 0;
    }

    return dot / (sqrt(normA) * sqrt(normB));
  }
}

class _SimilarTrack {
  final Track track;
  final double similarity;

  _SimilarTrack({required this.track, required this.similarity});
}
