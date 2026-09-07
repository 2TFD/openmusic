import '../../../layers/domain/entities/track.dart';
import '../../../layers/domain/entities/wave_session.dart';
import '../../../layers/domain/repositories/track_embedding_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/repositories/track_temporal_embedding_repository.dart';
import '../music_analysis/music_analysis_model_registry.dart';
import 'artist_wave_config.dart';
import 'audio_wave_support.dart';
import 'wave_recommendation_strategy.dart';

class ArtistWaveEngine implements WaveRecommendationStrategy {
  ArtistWaveEngine({
    required TrackRepository tracks,
    required TrackEmbeddingRepository globalEmbeddings,
    required TrackTemporalEmbeddingRepository temporalEmbeddings,
    required MusicAnalysisModelRegistry registry,
    required ArtistWaveConfig config,
  }) : _loader = AudioWaveDataLoader(
         tracks: tracks,
         globals: globalEmbeddings,
         temporals: temporalEmbeddings,
         registry: registry,
       ),
       _config = config;

  final AudioWaveDataLoader _loader;
  final ArtistWaveConfig _config;

  ArtistWaveConfig get config => _config;

  @override
  WaveSourceType get sourceType => WaveSourceType.artist;

  Future<WaveRecommendationBatch> generate({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) => generateWave(
    session: session,
    currentTrackId: currentTrackId,
    queuedTrackIds: queuedTrackIds,
  );

  @override
  Future<WaveRecommendationBatch> generateWave({
    required WaveSession session,
    String? currentTrackId,
    Set<String> queuedTrackIds = const {},
  }) async {
    final source = session.source;
    if (source is! ArtistWaveSource) {
      throw ArgumentError('ArtistWaveEngine requires an ArtistWaveSource');
    }
    final data = await _loader.load();
    final artistTracks = data.tracks
        .where(
          (track) =>
              track.artists.any((artist) => artist.id == source.artistId),
        )
        .toList(growable: false);
    final representatives = _representatives(
      cachedIds: source.representativeTrackIds,
      artistTracks: artistTracks,
      compatibleTrackIds: data.globals.keys.toSet(),
      limit: _config.representativeTrackLimit,
    );
    final globalProfileTrackIds = _globalProfileTrackIds(
      cachedIds: source.globalProfileTrackIds,
      artistTracks: artistTracks,
      compatibleTrackIds: data.globals.keys.toSet(),
    );
    final updatedSession = session.withSource(
      source.copyWith(
        globalProfileTrackIds: globalProfileTrackIds,
        representativeTrackIds: representatives,
      ),
    );
    final seedVectors = [
      for (final id in globalProfileTrackIds) data.globals[id]!.vector,
    ];
    if (seedVectors.isEmpty) {
      return WaveRecommendationBatch(
        candidates: const [],
        session: updatedSession,
      );
    }
    final recentIds =
        session.profileTrackIds.length <= _config.recentContextSize
        ? session.profileTrackIds
        : session.profileTrackIds.sublist(
            session.profileTrackIds.length - _config.recentContextSize,
          );
    final recentVectors = [
      for (final id in recentIds)
        if (data.globals[id] case final embedding?) embedding.vector,
    ];
    final profile = AudioWaveScoring.blendedCentroid(
      seedVectors: seedVectors,
      recentVectors: recentVectors,
      recentWeight: _config.recentProfileWeight,
    );
    if (profile == null) {
      return WaveRecommendationBatch(
        candidates: const [],
        session: updatedSession,
      );
    }

    final excluded = <String>{
      ...representatives,
      ...session.recentTrackIds,
      ...session.cycleTrackIds,
      ...queuedTrackIds,
      ?currentTrackId,
    };
    final artistTrackIds = artistTracks.map((track) => track.id).toSet();
    final seedTemporal = [
      for (final id in representatives)
        if (data.temporals[id] case final embedding?) embedding.segments,
    ];
    final recentTemporal = [
      for (final id in recentIds)
        if (data.temporals[id] case final embedding?) embedding.segments,
    ];
    List<WaveCandidate> rank({required bool excludeArtist}) {
      final globalRanked = <({String id, double cosine, double similarity})>[];
      for (final track in data.tracks) {
        if (excluded.contains(track.id) ||
            (excludeArtist && artistTrackIds.contains(track.id)) ||
            !isPlayableWaveTrack(track)) {
          continue;
        }
        final embedding = data.globals[track.id];
        if (embedding == null) continue;
        final cosine = AudioWaveScoring.cosine(profile, embedding.vector);
        if (cosine == null) continue;
        globalRanked.add((
          id: track.id,
          cosine: cosine,
          similarity: AudioWaveScoring.normalizeCosine(cosine),
        ));
      }
      globalRanked.sort((left, right) {
        final score = right.similarity.compareTo(left.similarity);
        return score != 0 ? score : left.id.compareTo(right.id);
      });
      final candidates = <WaveCandidate>[];
      for (final global in globalRanked.take(_config.globalCandidatePoolSize)) {
        final temporal = data.temporals[global.id];
        final temporalSimilarity = temporal == null
            ? null
            : AudioWaveScoring.blendedTemporal(
                seedProfiles: seedTemporal,
                recentProfiles: recentTemporal,
                candidate: temporal.segments,
                recentWeight: _config.recentProfileWeight,
              );
        final score = AudioWaveScoring.weightedScore(
          globalSimilarity: global.similarity,
          temporalSimilarity: temporalSimilarity,
          globalWeight: _config.globalWeight,
          temporalWeight: _config.temporalWeight,
        );
        candidates.add(
          WaveCandidate(
            track: data.byId[global.id]!,
            globalCosineSimilarity: global.cosine,
            globalSimilarity: global.similarity,
            temporalSimilarity: temporalSimilarity,
            finalScore: score.score,
            availableWeight: score.availableWeight,
          ),
        );
      }
      candidates.sort(_compareCandidates);
      return candidates.take(_config.batchSize).toList(growable: false);
    }

    var selected = rank(excludeArtist: _config.excludeSameArtistTracks);
    if (selected.isEmpty &&
        _config.excludeSameArtistTracks &&
        _config.allowSameArtistFallback) {
      selected = rank(excludeArtist: false);
    }
    return WaveRecommendationBatch(
      candidates: selected,
      session: updatedSession.withGeneratedTracks(
        selected.map((candidate) => candidate.track.id),
      ),
    );
  }

  static List<String> selectRepresentativeTrackIds({
    required Iterable<Track> artistTracks,
    required Set<String> compatibleTrackIds,
    required int limit,
  }) => _representatives(
    cachedIds: const [],
    artistTracks: artistTracks.toList(growable: false),
    compatibleTrackIds: compatibleTrackIds,
    limit: limit,
  );

  static List<String> _representatives({
    required List<String> cachedIds,
    required List<Track> artistTracks,
    required Set<String> compatibleTrackIds,
    required int limit,
  }) {
    final eligibleById = <String, Track>{
      for (final track in artistTracks)
        if (isPlayableWaveTrack(track) && compatibleTrackIds.contains(track.id))
          track.id: track,
    };
    if (cachedIds.isNotEmpty) {
      return [
        for (final id in cachedIds)
          if (eligibleById.containsKey(id)) id,
      ].take(limit).toList(growable: false);
    }
    final eligible = eligibleById.values.toList()
      ..sort((left, right) {
        final release = _releaseKey(left).compareTo(_releaseKey(right));
        return release != 0 ? release : left.id.compareTo(right.id);
      });
    final result = <String>[];
    final coveredReleases = <String>{};
    for (final track in eligible) {
      if (coveredReleases.add(_releaseKey(track))) result.add(track.id);
      if (result.length == limit) return result;
    }
    for (final track in eligible) {
      if (!result.contains(track.id)) result.add(track.id);
      if (result.length == limit) break;
    }
    return result;
  }

  static List<String> _globalProfileTrackIds({
    required List<String> cachedIds,
    required List<Track> artistTracks,
    required Set<String> compatibleTrackIds,
  }) {
    final eligibleIds = {
      for (final track in artistTracks)
        if (isPlayableWaveTrack(track) && compatibleTrackIds.contains(track.id))
          track.id,
    };
    if (cachedIds.isNotEmpty) {
      final cached = [
        for (final id in cachedIds)
          if (eligibleIds.contains(id)) id,
      ];
      if (cached.length == eligibleIds.length) return cached;
    }
    final sorted = eligibleIds.toList()..sort();
    return sorted;
  }

  static String _releaseKey(Track track) {
    final album = track.album?.trim().toLowerCase();
    return album == null || album.isEmpty ? 'track:${track.id}' : album;
  }

  static int _compareCandidates(WaveCandidate left, WaveCandidate right) {
    final finalScore = right.finalScore.compareTo(left.finalScore);
    if (finalScore != 0) return finalScore;
    final global = (right.globalSimilarity ?? -1).compareTo(
      left.globalSimilarity ?? -1,
    );
    if (global != 0) return global;
    return left.track.id.compareTo(right.track.id);
  }
}
