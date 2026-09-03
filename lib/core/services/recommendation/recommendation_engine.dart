import 'dart:isolate';
import 'dart:math' as math;

import '../../../layers/domain/entities/music_analysis.dart';
import '../../../layers/domain/entities/recommendation.dart';
import '../../../layers/domain/entities/track.dart';
import '../../../layers/domain/entities/track_embedding.dart';
import '../../../layers/domain/entities/wave_config.dart';
import '../../../layers/domain/repositories/track_embedding_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/repositories/track_lyrics_repository.dart';
import '../../../layers/domain/repositories/track_temporal_embedding_repository.dart';
import '../../../layers/domain/services/temporal_dtw_similarity.dart';
import '../../../layers/domain/services/vector_similarity.dart';
import '../music_analysis/music_analysis_model_registry.dart';
import 'recommendation_config.dart';

class RecommendationEngine {
  RecommendationEngine({
    required TrackRepository tracks,
    required TrackEmbeddingRepository globalEmbeddings,
    required TrackTemporalEmbeddingRepository temporalEmbeddings,
    TrackLyricsRepository? lyrics,
    required MusicAnalysisModelRegistry registry,
    required RecommendationConfig config,
  }) : _tracks = tracks,
       _globalEmbeddings = globalEmbeddings,
       _temporalEmbeddings = temporalEmbeddings,
       _lyrics = lyrics,
       _registry = registry,
       _config = config;

  final TrackRepository _tracks;
  final TrackEmbeddingRepository _globalEmbeddings;
  final TrackTemporalEmbeddingRepository _temporalEmbeddings;
  final TrackLyricsRepository? _lyrics;
  final MusicAnalysisModelRegistry _registry;
  final RecommendationConfig _config;

  Future<RecommendationResult> recommend(WaveConfig request) async {
    final stopwatch = Stopwatch()..start();
    final library = await _tracks.getTracks();
    final byId = {for (final track in library) track.id: track};
    final targets = _resolveTargets(request, library);
    final models = await _registry.getModels();
    final globalModel = models.require(MusicAnalysisRepresentation.audioGlobal);
    final temporalModel = models.require(
      MusicAnalysisRepresentation.audioTemporal,
    );
    final lyricsModel = _lyricsModel(models);
    final globals = await _globalEmbeddings.getBySpace(
      modality: TrackEmbeddingModality.audio,
      modelId: globalModel.modelId,
      modelVersion: globalModel.modelVersion,
      preprocessingVersion: globalModel.preprocessingVersion,
      provider: TrackEmbeddingProvider.server,
    );
    final validGlobals = {
      for (final embedding in globals)
        if (embedding.audioRevision != null &&
            byId[embedding.trackId]?.audioRevision == embedding.audioRevision &&
            embedding.dimensions == globalModel.dimension)
          embedding.trackId: embedding,
    };
    final seedGlobals = targets
        .map((target) => validGlobals[target.id])
        .whereType<TrackEmbedding>()
        .toList(growable: false);
    final missingSeedIds = [
      for (final target in targets)
        if (!validGlobals.containsKey(target.id)) target.id,
    ];

    if (targets.isEmpty || seedGlobals.isEmpty || request.queueSize <= 0) {
      stopwatch.stop();
      return RecommendationResult(
        readiness: targets.isEmpty
            ? RecommendationReadiness.insufficientLibrary
            : RecommendationReadiness.analysisRequired,
        missingSeedTrackIds: missingSeedIds,
        diagnostics: _diagnostics(
          library: library,
          analyzed: validGlobals.length,
          pool: 0,
          temporal: 0,
          duration: stopwatch.elapsed,
          globalModel: globalModel,
        ),
      );
    }

    final excludedIds = targets.map((track) => track.id).toSet();
    final globalInputs = [
      for (final entry in validGlobals.entries)
        if (!excludedIds.contains(entry.key))
          (trackId: entry.key, vector: entry.value.vector),
    ];
    final seedVectors = seedGlobals
        .map((embedding) => embedding.vector)
        .toList();
    final globalScores = await Isolate.run(
      () => _rankGlobal(seedVectors, globalInputs),
    );
    globalScores.sort((left, right) => right.score.compareTo(left.score));
    final pool = globalScores
        .take(_config.globalCandidatePoolSize)
        .toList(growable: false);

    final lyricsScores = await _rankLyrics(
      targets: targets,
      pool: pool,
      validTracks: byId,
      model: lyricsModel,
    );

    if (pool.isEmpty) {
      stopwatch.stop();
      return RecommendationResult(
        readiness: RecommendationReadiness.insufficientLibrary,
        missingSeedTrackIds: missingSeedIds,
        diagnostics: _diagnostics(
          library: library,
          analyzed: validGlobals.length,
          pool: 0,
          temporal: 0,
          duration: stopwatch.elapsed,
          globalModel: globalModel,
        ),
      );
    }

    final temporals = await _temporalEmbeddings.getBySpace(
      representation: temporalModel.representation.apiName,
      modelId: temporalModel.modelId,
      modelVersion: temporalModel.modelVersion,
      preprocessingVersion: temporalModel.preprocessingVersion,
      provider: TrackEmbeddingProvider.server,
    );
    final validTemporals = {
      for (final embedding in temporals)
        if (byId[embedding.trackId]?.audioRevision == embedding.audioRevision)
          embedding.trackId: embedding,
    };
    final seedTrajectories = [
      for (final seed in seedGlobals)
        if (validTemporals[seed.trackId] case final temporal?)
          temporal.segments,
    ];
    final temporalInputs = [
      for (final score in pool)
        if (validTemporals[score.trackId] case final temporal?)
          (trackId: score.trackId, segments: temporal.segments),
    ];
    final temporalScores = seedTrajectories.isEmpty
        ? const <String, double>{}
        : await Isolate.run(
            () => _rankTemporal(seedTrajectories, temporalInputs),
          );

    final candidates = [
      for (final global in pool)
        RecommendationCandidate(
          track: byId[global.trackId]!,
          finalScore: temporalScores[global.trackId] == null
              ? _scoreWithAvailableModalities(
                  global: global.score,
                  temporal: null,
                  lyrics: lyricsScores[global.trackId],
                )
              : _scoreWithAvailableModalities(
                  global: global.score,
                  temporal: temporalScores[global.trackId],
                  lyrics: lyricsScores[global.trackId],
                ),
          globalSimilarity: global.score,
          temporalSimilarity: temporalScores[global.trackId],
          lyricsSimilarity: lyricsScores[global.trackId],
          algorithmVersion: RecommendationConfig.algorithmVersion,
          modelId: globalModel.modelId,
          modelVersion: globalModel.modelVersion,
          preprocessingVersion: globalModel.preprocessingVersion,
        ),
    ]..sort((left, right) => right.finalScore.compareTo(left.finalScore));
    stopwatch.stop();
    return RecommendationResult(
      readiness: RecommendationReadiness.ready,
      candidates: candidates.take(request.queueSize).toList(growable: false),
      missingSeedTrackIds: missingSeedIds,
      diagnostics: _diagnostics(
        library: library,
        analyzed: validGlobals.length,
        pool: pool.length,
        temporal: temporalScores.length,
        lyrics: lyricsScores.length,
        duration: stopwatch.elapsed,
        globalModel: globalModel,
      ),
    );
  }

  static List<Track> _resolveTargets(WaveConfig request, List<Track> library) {
    final seedNames = request.seeds.map(_normalizeArtistName).toSet();
    return <String, Track>{
      for (final track in request.tracks) track.id: track,
      for (final track in library)
        if (track.artists.any(
          (artist) => seedNames.contains(_normalizeArtistName(artist.name)),
        ))
          track.id: track,
    }.values.toList(growable: false);
  }

  static String _normalizeArtistName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static List<({String trackId, double score})> _rankGlobal(
    List<List<double>> seeds,
    List<({String trackId, List<double> vector})> candidates,
  ) {
    final centroid = _normalizedMean(seeds);
    return [
      for (final candidate in candidates)
        (
          trackId: candidate.trackId,
          score: VectorSimilarity.cosine(centroid, candidate.vector),
        ),
    ];
  }

  static List<double> _normalizedMean(List<List<double>> vectors) {
    if (vectors.isEmpty) throw ArgumentError('Seed embeddings are empty');
    final dimension = vectors.first.length;
    if (dimension == 0 || vectors.any((vector) => vector.length != dimension)) {
      throw ArgumentError('Seed embedding dimensions do not match');
    }
    final mean = List<double>.filled(dimension, 0);
    for (final vector in vectors) {
      for (var index = 0; index < dimension; index++) {
        mean[index] += vector[index] / vectors.length;
      }
    }
    final norm = math.sqrt(
      mean.fold<double>(0, (sum, value) => sum + value * value),
    );
    if (norm == 0 || !norm.isFinite) {
      throw ArgumentError('Seed centroid cannot be normalized');
    }
    return [for (final value in mean) value / norm];
  }

  static Map<String, double> _rankTemporal(
    List<List<TemporalAnalysisSegment>> seeds,
    List<({String trackId, List<TemporalAnalysisSegment> segments})> candidates,
  ) {
    const dtw = TemporalDtwSimilarity();
    return {
      for (final candidate in candidates)
        candidate.trackId:
            seeds.fold<double>(
              0,
              (sum, seed) =>
                  sum + dtw.compare(seed, candidate.segments).rankingScore,
            ) /
            seeds.length,
    };
  }

  Future<Map<String, double>> _rankLyrics({
    required List<Track> targets,
    required List<({String trackId, double score})> pool,
    required Map<String, Track> validTracks,
    required MusicAnalysisModel? model,
  }) async {
    if (_lyrics == null || model == null || _config.lyricsWeight == 0) {
      return const {};
    }
    final embeddings = await _globalEmbeddings.getBySpace(
      modality: TrackEmbeddingModality.lyrics,
      modelId: model.modelId,
      modelVersion: model.modelVersion,
      preprocessingVersion: model.preprocessingVersion,
      provider: TrackEmbeddingProvider.server,
    );
    final hashes = <String, String>{};
    await Future.wait([
      for (final track in validTracks.values)
        _lyrics.getForTrack(track.id).then((value) {
          if (value != null && value.plainText.trim().isNotEmpty) {
            hashes[track.id] = value.contentHash;
          }
        }),
    ]);
    final valid = {
      for (final embedding in embeddings)
        if (embedding.contentRevision != null &&
            embedding.contentRevision == hashes[embedding.trackId] &&
            embedding.dimensions == model.dimension)
          embedding.trackId: embedding,
    };
    final seedVectors = [
      for (final target in targets)
        if (valid[target.id] case final embedding?) embedding.vector,
    ];
    if (seedVectors.isEmpty) return const {};
    final candidateVectors = [
      for (final candidate in pool)
        if (valid[candidate.trackId] case final embedding?)
          (trackId: candidate.trackId, vector: embedding.vector),
    ];
    final centroid = _normalizedMean(seedVectors);
    return {
      for (final candidate in candidateVectors)
        candidate.trackId: VectorSimilarity.cosine(centroid, candidate.vector),
    };
  }

  double _scoreWithAvailableModalities({
    required double global,
    required double? temporal,
    required double? lyrics,
  }) {
    var weighted = _config.globalWeight * global;
    var available = _config.globalWeight;
    if (temporal != null) {
      weighted += _config.temporalWeight * temporal;
      available += _config.temporalWeight;
    }
    if (lyrics != null) {
      weighted += _config.lyricsWeight * lyrics;
      available += _config.lyricsWeight;
    }
    return weighted / available;
  }

  static MusicAnalysisModel? _lyricsModel(MusicAnalysisModels models) {
    for (final model in models.models) {
      if (model.representation == MusicAnalysisRepresentation.lyricsGlobal) {
        return model;
      }
    }
    return null;
  }

  static RecommendationDiagnostics _diagnostics({
    required List<Track> library,
    required int analyzed,
    required int pool,
    required int temporal,
    int lyrics = 0,
    required Duration duration,
    required MusicAnalysisModel globalModel,
  }) => RecommendationDiagnostics(
    analyzedTrackCount: analyzed,
    libraryTrackCount: library.length,
    candidatePoolSize: pool,
    temporalCandidateCount: temporal,
    lyricsCandidateCount: lyrics,
    rankingDuration: duration,
    algorithmVersion: RecommendationConfig.algorithmVersion,
    modelVersion: globalModel.modelVersion,
    preprocessingVersion: globalModel.preprocessingVersion,
  );
}
