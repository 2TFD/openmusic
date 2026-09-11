import '../../../layers/domain/entities/lyrics_resolution_state.dart';
import '../../../layers/domain/entities/source.dart';
import '../../../layers/domain/entities/track.dart';
import '../../../layers/domain/entities/track_lyrics.dart';
import '../../../layers/domain/repositories/lyrics_provider.dart';
import '../../../layers/domain/repositories/track_lyrics_repository.dart';
import '../../../layers/domain/repositories/track_repository.dart';
import '../../../layers/domain/services/lyrics_content_hasher.dart';
import '../../../layers/domain/usecases/queue_lyrics_analysis_use_case.dart';
import 'lyrics_config.dart';
import '../../utils/app_logger.dart';

class LyricsResolver {
  LyricsResolver({
    required TrackRepository tracks,
    required TrackLyricsRepository lyrics,
    required List<LyricsProvider> providers,
    required QueueLyricsAnalysisUseCase queueAnalysis,
    required LyricsConfig config,
    DateTime Function()? now,
  }) : _tracks = tracks,
       _lyrics = lyrics,
       _providers = List.unmodifiable(providers),
       _queueAnalysis = queueAnalysis,
       _config = config,
       _now = now ?? DateTime.now {
    if (_providers.isEmpty) throw ArgumentError.value(providers, 'providers');
  }

  final TrackRepository _tracks;
  final TrackLyricsRepository _lyrics;
  final List<LyricsProvider> _providers;
  final QueueLyricsAnalysisUseCase _queueAnalysis;
  final LyricsConfig _config;
  final DateTime Function() _now;

  Future<LyricsResolutionState> resolve(
    String trackId, {
    bool force = false,
  }) async {
    final track = await _tracks.getTrackById(trackId);
    if (track == null) {
      return _state(
        trackId: trackId,
        status: LyricsResolutionStatus.failed,
        failureCode: 'track_not_found',
      );
    }

    final cachedLyrics = await _lyrics.getForTrack(trackId);
    final cachedState = await _lyrics.getResolutionState(trackId);
    if (!force && _isValidCache(track, cachedLyrics, cachedState)) {
      return cachedState!;
    }

    final attemptCount = (cachedState?.attemptCount ?? 0) + 1;
    final startedAt = _now();
    await _lyrics.saveResolutionState(
      LyricsResolutionState(
        trackId: trackId,
        status: LyricsResolutionStatus.searching,
        metadataRevision: track.metadataRevision,
        attemptCount: attemptCount,
        lastAttemptAt: startedAt,
        updatedAt: startedAt,
      ),
    );

    LyricsProviderAmbiguous? ambiguous;
    LyricsSource? ambiguousSource;
    LyricsProviderTemporaryFailure? temporaryFailure;
    LyricsSource? temporarySource;
    LyricsProviderPermanentFailure? permanentFailure;
    LyricsSource? permanentSource;
    final request = _request(track);

    for (final provider in _providers) {
      final LyricsProviderResult result;
      try {
        result = await provider.resolve(request);
      } catch (error, stackTrace) {
        await AppLogger.captureException(
          error,
          stackTrace,
          operation: 'lyrics.provider.resolve',
        );
        temporaryFailure = const LyricsProviderTemporaryFailure(
          code: 'unexpected_provider_failure',
        );
        temporarySource = provider.source;
        continue;
      }
      switch (result) {
        case LyricsProviderFound():
          return _persistFound(
            track,
            provider.source,
            result,
            attemptCount,
            startedAt,
          );
        case LyricsProviderInstrumental():
          return _persistInstrumental(
            track,
            provider.source,
            result,
            attemptCount,
            startedAt,
          );
        case LyricsProviderAmbiguous():
          ambiguous ??= result;
          ambiguousSource ??= provider.source;
        case LyricsProviderTemporaryFailure():
          temporaryFailure ??= result;
          temporarySource ??= provider.source;
        case LyricsProviderPermanentFailure():
          permanentFailure ??= result;
          permanentSource ??= provider.source;
        case LyricsProviderNotFound():
          break;
      }
    }

    if (ambiguous != null) {
      return _saveState(
        _state(
          trackId: trackId,
          status: LyricsResolutionStatus.ambiguous,
          source: ambiguousSource,
          metadataRevision: track.metadataRevision,
          attemptCount: attemptCount,
          lastAttemptAt: startedAt,
          failureCode: 'ambiguous_match',
        ),
      );
    }
    if (temporaryFailure != null) {
      final retryAt = _now().add(
        temporaryFailure.retryAfter ?? _config.defaultRetryDelay,
      );
      return _saveState(
        _state(
          trackId: trackId,
          status: LyricsResolutionStatus.failed,
          source: temporarySource,
          metadataRevision: track.metadataRevision,
          attemptCount: attemptCount,
          lastAttemptAt: startedAt,
          retryAt: retryAt,
          failureCode: temporaryFailure.code,
        ),
      );
    }
    if (permanentFailure != null) {
      return _saveState(
        _state(
          trackId: trackId,
          status: LyricsResolutionStatus.failed,
          source: permanentSource,
          metadataRevision: track.metadataRevision,
          attemptCount: attemptCount,
          lastAttemptAt: startedAt,
          failureCode: permanentFailure.code,
        ),
      );
    }
    return _saveState(
      _state(
        trackId: trackId,
        status: LyricsResolutionStatus.notFound,
        metadataRevision: track.metadataRevision,
        attemptCount: attemptCount,
        lastAttemptAt: startedAt,
      ),
    );
  }

  bool _isValidCache(
    Track track,
    TrackLyrics? lyrics,
    LyricsResolutionState? state,
  ) {
    if (state == null || state.metadataRevision != track.metadataRevision) {
      return false;
    }
    if (state.status == LyricsResolutionStatus.found ||
        state.status == LyricsResolutionStatus.instrumental) {
      return lyrics != null;
    }
    if (state.status == LyricsResolutionStatus.notFound ||
        state.status == LyricsResolutionStatus.ambiguous) {
      return true;
    }
    if (state.status == LyricsResolutionStatus.failed) {
      return state.retryAt == null || state.retryAt!.isAfter(_now());
    }
    return false;
  }

  LyricsRequest _request(Track track) => LyricsRequest(
    trackId: track.id,
    title: track.title,
    artists: track.artists.map((artist) => artist.name).toList(),
    album: track.album,
    duration: track.duration == Duration.zero ? null : track.duration,
    filePath: track.filePath,
    originalFilePath: track.source.type == SourceType.localFile
        ? track.source.originalUrl
        : null,
    source: track.source.type,
  );

  Future<LyricsResolutionState> _persistFound(
    Track track,
    LyricsSource source,
    LyricsProviderFound result,
    int attemptCount,
    DateTime startedAt,
  ) async {
    final now = _now();
    final plainText = LyricsContentHasher.canonicalize(result.plainText);
    if (plainText.isEmpty) {
      return _saveState(
        _state(
          trackId: track.id,
          status: LyricsResolutionStatus.failed,
          source: source,
          metadataRevision: track.metadataRevision,
          attemptCount: attemptCount,
          lastAttemptAt: startedAt,
          failureCode: 'empty_lyrics',
        ),
      );
    }
    await _lyrics.save(
      TrackLyrics(
        trackId: track.id,
        source: source,
        sourceId: result.sourceId,
        plainText: plainText,
        syncedText: result.syncedText,
        language: result.language,
        contentHash: LyricsContentHasher.hash(plainText),
        matchConfidence: result.matchConfidence,
        matchedTitle: result.matchedTitle,
        matchedArtist: result.matchedArtist,
        matchedDurationMs: result.matchedDurationMs,
        fetchedAt: now,
        updatedAt: now,
      ),
    );
    final state = await _saveState(
      _state(
        trackId: track.id,
        status: LyricsResolutionStatus.found,
        source: source,
        metadataRevision: track.metadataRevision,
        attemptCount: attemptCount,
        lastAttemptAt: startedAt,
      ),
    );
    try {
      await _queueAnalysis(track);
    } catch (error, stackTrace) {
      // The durable analysis backfill can recover this independently.
      await AppLogger.warning(
        'Lyrics analysis scheduling failed; backfill will retry.',
        operation: 'lyrics.queue_analysis',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return state;
  }

  Future<LyricsResolutionState> _persistInstrumental(
    Track track,
    LyricsSource source,
    LyricsProviderInstrumental result,
    int attemptCount,
    DateTime startedAt,
  ) async {
    final now = _now();
    await _lyrics.save(
      TrackLyrics(
        trackId: track.id,
        source: source,
        sourceId: result.sourceId,
        plainText: '',
        contentHash: LyricsContentHasher.hash(''),
        isInstrumental: true,
        matchConfidence: result.matchConfidence,
        matchedTitle: result.matchedTitle,
        matchedArtist: result.matchedArtist,
        matchedDurationMs: result.matchedDurationMs,
        fetchedAt: now,
        updatedAt: now,
      ),
    );
    return _saveState(
      _state(
        trackId: track.id,
        status: LyricsResolutionStatus.instrumental,
        source: source,
        metadataRevision: track.metadataRevision,
        attemptCount: attemptCount,
        lastAttemptAt: startedAt,
      ),
    );
  }

  LyricsResolutionState _state({
    required String trackId,
    required LyricsResolutionStatus status,
    LyricsSource? source,
    int metadataRevision = 0,
    int attemptCount = 0,
    DateTime? lastAttemptAt,
    DateTime? retryAt,
    String? failureCode,
  }) => LyricsResolutionState(
    trackId: trackId,
    status: status,
    source: source,
    metadataRevision: metadataRevision,
    attemptCount: attemptCount,
    lastAttemptAt: lastAttemptAt,
    retryAt: retryAt,
    failureCode: failureCode,
    updatedAt: _now(),
  );

  Future<LyricsResolutionState> _saveState(LyricsResolutionState state) async {
    await _lyrics.saveResolutionState(state);
    return state;
  }
}
