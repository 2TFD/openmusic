import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../repositories/lyrics_provider.dart';

class LyricsSearchCandidate extends Equatable {
  const LyricsSearchCandidate({required this.title, required this.artist});

  final String title;
  final String artist;

  @override
  List<Object> get props => [title, artist];
}

class LyricsTrackCandidate extends Equatable {
  const LyricsTrackCandidate({
    required this.sourceId,
    required this.title,
    required this.artist,
    this.album,
    this.duration,
  });

  final String sourceId;
  final String title;
  final String artist;
  final String? album;
  final Duration? duration;

  @override
  List<Object?> get props => [sourceId, title, artist, album, duration];
}

enum LyricsMatchDisposition { accepted, ambiguous, noMatch }

class LyricsTrackMatch extends Equatable {
  const LyricsTrackMatch({
    required this.disposition,
    this.candidate,
    this.confidence = 0,
    this.titleSimilarity = 0,
    this.artistSimilarity = 0,
    this.durationDelta,
  });

  final LyricsMatchDisposition disposition;
  final LyricsTrackCandidate? candidate;
  final double confidence;
  final double titleSimilarity;
  final double artistSimilarity;
  final Duration? durationDelta;

  @override
  List<Object?> get props => [
    disposition,
    candidate,
    confidence,
    titleSimilarity,
    artistSimilarity,
    durationDelta,
  ];
}

class LyricsTrackMatcher {
  const LyricsTrackMatcher();

  static final RegExp _technicalSuffix = RegExp(
    r'\s*[\(\[]\s*(?:official audio|official music video|free download)\s*[\)\]]\s*',
    caseSensitive: false,
  );
  static final RegExp _artistTitle = RegExp(r'^(.+?)\s+-\s+(.+)$');

  LyricsSearchCandidate buildSearchCandidate(LyricsRequest request) {
    final cleanedTitle = cleanupTitle(request.title);
    final split = _artistTitle.firstMatch(cleanedTitle);
    if (split != null) {
      return LyricsSearchCandidate(
        artist: split.group(1)!.trim(),
        title: split.group(2)!.trim(),
      );
    }
    return LyricsSearchCandidate(
      title: cleanedTitle,
      artist: request.artists
          .map((artist) => artist.trim())
          .firstWhere(
            (artist) => artist.isNotEmpty && !_isUnknownArtist(artist),
            orElse: () => '',
          ),
    );
  }

  String cleanupTitle(String value) => value
      .replaceAll(_technicalSuffix, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  LyricsTrackMatch match(
    LyricsRequest request,
    Iterable<LyricsTrackCandidate> candidates,
  ) {
    final scored =
        candidates.map((candidate) => _score(request, candidate)).toList()
          ..sort((left, right) => right.confidence.compareTo(left.confidence));
    if (scored.isEmpty)
      return const LyricsTrackMatch(
        disposition: LyricsMatchDisposition.noMatch,
      );

    final best = scored.first;
    if (!best.isPlausible) {
      return const LyricsTrackMatch(
        disposition: LyricsMatchDisposition.noMatch,
      );
    }
    final hasCloseCompetitor =
        scored.length > 1 &&
        scored[1].isPlausible &&
        best.confidence - scored[1].confidence <= 0.03;
    final disposition = best.isHighConfidence && !hasCloseCompetitor
        ? LyricsMatchDisposition.accepted
        : LyricsMatchDisposition.ambiguous;
    return LyricsTrackMatch(
      disposition: disposition,
      candidate: best.candidate,
      confidence: best.confidence,
      titleSimilarity: best.titleSimilarity,
      artistSimilarity: best.artistSimilarity,
      durationDelta: best.durationDelta,
    );
  }

  _ScoredCandidate _score(
    LyricsRequest request,
    LyricsTrackCandidate candidate,
  ) {
    final search = buildSearchCandidate(request);
    final titleSimilarity = _similarity(
      search.title,
      cleanupTitle(candidate.title),
    );
    final artistInputs = <String>{
      search.artist,
      ...request.artists,
    }.where((artist) => artist.trim().isNotEmpty).toList();
    final artistSimilarity = artistInputs.isEmpty
        ? 0.0
        : artistInputs
              .map((artist) => _similarity(artist, candidate.artist))
              .reduce(math.max);

    final requestDuration = _usableDuration(request.duration);
    final candidateDuration = _usableDuration(candidate.duration);
    final hasDuration = requestDuration != null && candidateDuration != null;
    final durationDelta = hasDuration
        ? Duration(
            milliseconds:
                (requestDuration.inMilliseconds -
                        candidateDuration.inMilliseconds)
                    .abs(),
          )
        : null;
    final durationTolerance = requestDuration == null
        ? null
        : math.max(4000, (requestDuration.inMilliseconds * 0.025).round());
    final hardDurationLimit = requestDuration == null
        ? null
        : math.max(12000, (requestDuration.inMilliseconds * 0.06).round());
    final durationSimilarity = durationDelta == null || requestDuration == null
        ? 0.0
        : (1 -
                  durationDelta.inMilliseconds /
                      math.max(15000, requestDuration.inMilliseconds * 0.08))
              .clamp(0.0, 1.0)
              .toDouble();
    final confidence = hasDuration
        ? 0.55 * titleSimilarity +
              0.30 * artistSimilarity +
              0.15 * durationSimilarity
        : 0.65 * titleSimilarity + 0.35 * artistSimilarity;
    final durationPlausible =
        durationDelta == null ||
        durationDelta.inMilliseconds <= hardDurationLimit!;
    final durationStrict =
        durationDelta != null &&
        durationDelta.inMilliseconds <= durationTolerance!;
    final plausible =
        titleSimilarity >= 0.82 &&
        artistSimilarity >= 0.78 &&
        durationPlausible;
    final highConfidence =
        plausible &&
        titleSimilarity >= 0.94 &&
        artistSimilarity >= 0.92 &&
        (hasDuration
            ? durationStrict && confidence >= 0.93
            : titleSimilarity >= 0.99 && artistSimilarity >= 0.98);
    return _ScoredCandidate(
      candidate: candidate,
      confidence: confidence,
      titleSimilarity: titleSimilarity,
      artistSimilarity: artistSimilarity,
      durationDelta: durationDelta,
      isPlausible: plausible,
      isHighConfidence: highConfidence,
    );
  }

  static Duration? _usableDuration(Duration? value) =>
      value == null || value == Duration.zero ? null : value;

  static bool _isUnknownArtist(String artist) {
    final value = artist.trim().toLowerCase();
    return value == 'unknown artist' || value == 'unknown';
  }

  static double _similarity(String left, String right) {
    final a = _normalize(left);
    final b = _normalize(right);
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;
    final distance = _levenshtein(a, b);
    return (1 - distance / math.max(a.length, b.length))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static int _levenshtein(String left, String right) {
    var previous = List<int>.generate(right.length + 1, (index) => index);
    for (var leftIndex = 0; leftIndex < left.length; leftIndex++) {
      final current = List<int>.filled(right.length + 1, 0);
      current[0] = leftIndex + 1;
      for (var rightIndex = 0; rightIndex < right.length; rightIndex++) {
        final substitution =
            previous[rightIndex] +
            (left.codeUnitAt(leftIndex) == right.codeUnitAt(rightIndex)
                ? 0
                : 1);
        current[rightIndex + 1] = math.min(
          math.min(current[rightIndex] + 1, previous[rightIndex + 1] + 1),
          substitution,
        );
      }
      previous = current;
    }
    return previous.last;
  }
}

class _ScoredCandidate {
  const _ScoredCandidate({
    required this.candidate,
    required this.confidence,
    required this.titleSimilarity,
    required this.artistSimilarity,
    required this.durationDelta,
    required this.isPlausible,
    required this.isHighConfidence,
  });

  final LyricsTrackCandidate candidate;
  final double confidence;
  final double titleSimilarity;
  final double artistSimilarity;
  final Duration? durationDelta;
  final bool isPlausible;
  final bool isHighConfidence;
}
