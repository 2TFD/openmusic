import 'package:uuid/uuid.dart';

import '../../../core/services/music_analysis/music_analysis_model_registry.dart';
import '../../domain/entities/music_analysis.dart';
import '../../domain/entities/music_analysis_failure.dart';
import '../../domain/entities/track_embedding.dart';
import '../../domain/entities/track_emotion_analysis.dart';
import '../../domain/entities/track_temporal_embedding.dart';
import '../../domain/repositories/music_analysis_client.dart';
import '../../domain/repositories/music_analysis_repository.dart';
import '../../domain/repositories/track_embedding_repository.dart';
import '../../domain/repositories/track_emotion_repository.dart';
import '../../domain/repositories/track_lyrics_repository.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/repositories/track_temporal_embedding_repository.dart';

class MusicAnalysisRepositoryImpl implements MusicAnalysisRepository {
  MusicAnalysisRepositoryImpl({
    required TrackRepository tracks,
    required TrackEmbeddingRepository globalEmbeddings,
    required TrackTemporalEmbeddingRepository temporalEmbeddings,
    TrackEmotionRepository? emotions,
    TrackLyricsRepository? lyrics,
    required MusicAnalysisClient client,
    required MusicAnalysisModelRegistry registry,
  }) : _tracks = tracks,
       _globalEmbeddings = globalEmbeddings,
       _temporalEmbeddings = temporalEmbeddings,
       _emotions = emotions,
       _lyrics = lyrics,
       _client = client,
       _registry = registry;

  final TrackRepository _tracks;
  final TrackEmbeddingRepository _globalEmbeddings;
  final TrackTemporalEmbeddingRepository _temporalEmbeddings;
  final TrackEmotionRepository? _emotions;
  final TrackLyricsRepository? _lyrics;
  final MusicAnalysisClient _client;
  final MusicAnalysisModelRegistry _registry;

  @override
  Future<Set<MusicAnalysisRepresentation>> missingRepresentations({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async {
    final track = await _tracks.getTrackById(trackId);
    if (track == null) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.fileNotFound,
        details: 'Track was deleted',
      );
    }
    if (track.filePath == null) {
      throw const MusicAnalysisFailure(MusicAnalysisFailureKind.needsDownload);
    }
    if (_containsAudio(representations) &&
        track.audioRevision != audioRevision) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.staleContent,
        details: 'Stale analysis task audioRevision',
      );
    }

    final registry = await _registry.getModels();
    final missing = <MusicAnalysisRepresentation>{};
    for (final representation in representations) {
      String? contentRevision;
      if (representation == MusicAnalysisRepresentation.lyricsGlobal) {
        final lyrics = await _lyrics?.getForTrack(trackId);
        if (lyrics == null ||
            lyrics.isInstrumental ||
            lyrics.plainText.trim().isEmpty) {
          continue;
        }
        contentRevision = lyrics.contentHash;
      }
      final model = registry.find(representation);
      // A schema-v1 backend has no Music2Emo models. Its existing analysis
      // remains usable and the optional emotion capability is simply skipped.
      if (model == null) continue;
      if (!await _hasCached(
        trackId,
        audioRevision,
        model,
        audioContentRevision: emotionContentRevisionFor(track),
        contentRevision: contentRevision,
      )) {
        missing.add(representation);
      }
    }
    return missing;
  }

  @override
  Future<MusicAnalysisDisposition> analyzeTrack({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async {
    final missing = await missingRepresentations(
      trackId: trackId,
      audioRevision: audioRevision,
      representations: representations,
    );
    if (missing.isEmpty) return MusicAnalysisDisposition.cached;

    final track = await _tracks.getTrackById(trackId);
    if (track == null || track.filePath == null) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.fileNotFound,
        details: 'Track changed before analysis started or needs download',
      );
    }
    if (_containsAudio(missing) && track.audioRevision != audioRevision) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.staleContent,
        details: 'Track audio changed before analysis started',
      );
    }
    final capturedLyrics =
        missing.contains(MusicAnalysisRepresentation.lyricsGlobal)
        ? await _lyrics?.getForTrack(trackId)
        : null;
    if (missing.contains(MusicAnalysisRepresentation.lyricsGlobal) &&
        (capturedLyrics == null ||
            capturedLyrics.isInstrumental ||
            capturedLyrics.plainText.trim().isEmpty)) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.staleContent,
        details: 'Lyrics changed before analysis started',
      );
    }
    final registry = await _registry.getModels();

    final core = missing.where((entry) => !entry.isEmotion).toSet();
    final emotion = missing.where((entry) => entry.isEmotion).toSet();
    // Persist the lightweight/established representations first. A later
    // Music2Emo outage then leaves them cached and a task retry requests only
    // the missing emotion subset.
    for (final batch in [core, emotion]) {
      if (batch.isEmpty) continue;
      final response = await _client.analyze(
        trackId: track.id,
        filePath: track.filePath!,
        contentIdentity: track.contentIdentity,
        lyrics: capturedLyrics?.plainText,
        requestedRepresentations: batch,
      );
      await _validateSnapshot(
        response: response,
        trackId: trackId,
        expectedContentIdentity: track.contentIdentity,
        audioRevision: audioRevision,
        requested: batch,
        lyricsContentHash: capturedLyrics?.contentHash,
      );
      await _persistResponse(
        response: response,
        requested: batch,
        trackId: track.id,
        contentRevision: emotionContentRevisionFor(track),
        audioRevision: audioRevision,
        lyricsContentRevision: capturedLyrics?.contentHash,
        registry: registry,
      );
    }
    return MusicAnalysisDisposition.analyzed;
  }

  Future<void> _persistResponse({
    required MusicAnalysisResponse response,
    required Set<MusicAnalysisRepresentation> requested,
    required String trackId,
    required String contentRevision,
    required int audioRevision,
    required String? lyricsContentRevision,
    required MusicAnalysisModels registry,
  }) async {
    if (requested.contains(MusicAnalysisRepresentation.audioGlobal)) {
      final global = response.audioGlobal;
      if (global == null) _missing(MusicAnalysisRepresentation.audioGlobal);
      _validateAgainstRegistry(global.metadata, registry);
      await _globalEmbeddings.save(
        TrackEmbedding(
          trackId: trackId,
          modality: TrackEmbeddingModality.audio,
          modelId: global.metadata.modelId,
          modelVersion: global.metadata.modelVersion,
          preprocessingVersion: global.metadata.preprocessingVersion,
          provider: TrackEmbeddingProvider.server,
          audioRevision: audioRevision,
          dtype: global.metadata.dtype,
          normalized: global.metadata.normalized,
          dimensions: global.metadata.dimension,
          vector: global.vector,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (requested.contains(MusicAnalysisRepresentation.audioTemporal)) {
      final temporal = response.audioTemporal;
      if (temporal == null) {
        _missing(MusicAnalysisRepresentation.audioTemporal);
      }
      _validateAgainstRegistry(temporal.metadata, registry);
      await _temporalEmbeddings.save(
        TrackTemporalEmbedding(
          id: const Uuid().v4(),
          trackId: trackId,
          representation: temporal.metadata.representation.apiName,
          modelId: temporal.metadata.modelId,
          modelVersion: temporal.metadata.modelVersion,
          preprocessingVersion: temporal.metadata.preprocessingVersion,
          provider: TrackEmbeddingProvider.server,
          audioRevision: audioRevision,
          dimension: temporal.metadata.dimension,
          dtype: temporal.metadata.dtype,
          normalized: temporal.metadata.normalized,
          createdAt: DateTime.now(),
          summary: temporal.summary,
          segments: temporal.segments,
        ),
      );
    }
    if (requested.contains(MusicAnalysisRepresentation.audioEmotionGlobal)) {
      final emotion = response.audioEmotionGlobal;
      if (emotion == null) {
        _missing(MusicAnalysisRepresentation.audioEmotionGlobal);
      }
      _validateAgainstRegistry(emotion.metadata, registry);
      final repository = _emotions;
      if (repository == null) {
        _missing(MusicAnalysisRepresentation.audioEmotionGlobal);
      }
      await repository.saveGlobal(
        TrackEmotionAnalysis(
          id: const Uuid().v4(),
          trackId: trackId,
          representation: emotion.metadata.representation.apiName,
          modelId: emotion.metadata.modelId,
          modelVersion: emotion.metadata.modelVersion,
          preprocessingVersion: emotion.metadata.preprocessingVersion,
          contentRevision: contentRevision,
          audioRevision: audioRevision,
          valence: emotion.valence,
          arousal: emotion.arousal,
          rawValence: emotion.rawValence,
          rawArousal: emotion.rawArousal,
          moodDistribution: emotion.moodDistribution,
          analyzedAt: DateTime.now(),
        ),
      );
    }
    if (requested.contains(MusicAnalysisRepresentation.audioEmotionTemporal)) {
      final emotion = response.audioEmotionTemporal;
      if (emotion == null) {
        _missing(MusicAnalysisRepresentation.audioEmotionTemporal);
      }
      _validateAgainstRegistry(emotion.metadata, registry);
      final repository = _emotions;
      if (repository == null) {
        _missing(MusicAnalysisRepresentation.audioEmotionTemporal);
      }
      final analysisId = const Uuid().v4();
      await repository.saveTemporal(
        TrackEmotionTemporalAnalysis(
          id: analysisId,
          trackId: trackId,
          representation: emotion.metadata.representation.apiName,
          modelId: emotion.metadata.modelId,
          modelVersion: emotion.metadata.modelVersion,
          preprocessingVersion: emotion.metadata.preprocessingVersion,
          contentRevision: contentRevision,
          audioRevision: audioRevision,
          summary: emotion.summary,
          segments: emotion.segments
              .map(
                (segment) => TrackEmotionSegment(
                  analysisId: analysisId,
                  index: segment.index,
                  startMs: segment.startMs,
                  endMs: segment.endMs,
                  valence: segment.valence,
                  arousal: segment.arousal,
                  moodDistribution: segment.moodDistribution,
                ),
              )
              .toList(growable: false),
          analyzedAt: DateTime.now(),
        ),
      );
    }
    if (requested.contains(MusicAnalysisRepresentation.lyricsGlobal)) {
      final lyrics = response.lyricsGlobal;
      if (lyrics == null) {
        _missing(MusicAnalysisRepresentation.lyricsGlobal);
      }
      _validateAgainstRegistry(lyrics.metadata, registry);
      await _globalEmbeddings.save(
        TrackEmbedding(
          trackId: trackId,
          modality: TrackEmbeddingModality.lyrics,
          modelId: lyrics.metadata.modelId,
          modelVersion: lyrics.metadata.modelVersion,
          preprocessingVersion: lyrics.metadata.preprocessingVersion,
          provider: TrackEmbeddingProvider.server,
          contentRevision: lyricsContentRevision!,
          dtype: lyrics.metadata.dtype,
          normalized: lyrics.metadata.normalized,
          dimensions: lyrics.metadata.dimension,
          vector: lyrics.vector,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _validateSnapshot({
    required MusicAnalysisResponse response,
    required String trackId,
    required String? expectedContentIdentity,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> requested,
    required String? lyricsContentHash,
  }) async {
    if (response.trackId != null && response.trackId != trackId) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'Response track_id mismatch',
      );
    }
    if (response.contentIdentity != null &&
        response.contentIdentity != expectedContentIdentity) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.staleContent,
        details: 'Response content_identity mismatch',
      );
    }
    final currentTrack = await _tracks.getTrackById(trackId);
    if (currentTrack == null) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.fileNotFound,
        details: 'Track was deleted during analysis',
      );
    }
    if (_containsAudio(requested) &&
        currentTrack.audioRevision != audioRevision) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.staleContent,
        details: 'Audio changed during analysis',
      );
    }
    if (lyricsContentHash != null &&
        requested.contains(MusicAnalysisRepresentation.lyricsGlobal)) {
      final currentLyrics = await _lyrics?.getForTrack(trackId);
      if (currentLyrics?.contentHash != lyricsContentHash) {
        throw const MusicAnalysisFailure(
          MusicAnalysisFailureKind.staleContent,
          details: 'Lyrics changed during analysis',
        );
      }
    }
  }

  Future<bool> _hasCached(
    String trackId,
    int audioRevision,
    MusicAnalysisModel model, {
    required String audioContentRevision,
    String? contentRevision,
  }) async {
    return switch (model.representation) {
      MusicAnalysisRepresentation.audioGlobal =>
        (await _globalEmbeddings.get(
              trackId: trackId,
              modality: TrackEmbeddingModality.audio,
              modelId: model.modelId,
              modelVersion: model.modelVersion,
              preprocessingVersion: model.preprocessingVersion,
              provider: TrackEmbeddingProvider.server,
            ))?.audioRevision ==
            audioRevision,
      MusicAnalysisRepresentation.audioTemporal =>
        await _temporalEmbeddings.get(
              trackId: trackId,
              representation: model.representation.apiName,
              modelId: model.modelId,
              modelVersion: model.modelVersion,
              preprocessingVersion: model.preprocessingVersion,
              provider: TrackEmbeddingProvider.server,
              audioRevision: audioRevision,
            ) !=
            null,
      MusicAnalysisRepresentation.audioEmotionGlobal =>
        await _emotions?.getGlobal(
              trackId: trackId,
              modelId: model.modelId,
              modelVersion: model.modelVersion,
              preprocessingVersion: model.preprocessingVersion,
              contentRevision: audioContentRevision,
              audioRevision: audioRevision,
            ) !=
            null,
      MusicAnalysisRepresentation.audioEmotionTemporal =>
        await _emotions?.getTemporal(
              trackId: trackId,
              modelId: model.modelId,
              modelVersion: model.modelVersion,
              preprocessingVersion: model.preprocessingVersion,
              contentRevision: audioContentRevision,
              audioRevision: audioRevision,
            ) !=
            null,
      MusicAnalysisRepresentation.lyricsGlobal =>
        contentRevision != null &&
            await _globalEmbeddings.get(
                  trackId: trackId,
                  modality: TrackEmbeddingModality.lyrics,
                  modelId: model.modelId,
                  modelVersion: model.modelVersion,
                  preprocessingVersion: model.preprocessingVersion,
                  provider: TrackEmbeddingProvider.server,
                  contentRevision: contentRevision,
                ) !=
                null,
    };
  }

  static bool _containsAudio(
    Set<MusicAnalysisRepresentation> representations,
  ) => representations.any((representation) => representation.isAudio);

  static void _validateAgainstRegistry(
    MusicAnalysisModel actual,
    MusicAnalysisModels registry,
  ) {
    final expected = registry.require(actual.representation);
    if (actual != expected) {
      throw const MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'Response metadata differs from /v1/models',
      );
    }
  }

  static Never _missing(MusicAnalysisRepresentation representation) =>
      throw MusicAnalysisFailure(
        MusicAnalysisFailureKind.invalidRepresentation,
        details: 'Missing requested ${representation.apiName}',
      );
}
