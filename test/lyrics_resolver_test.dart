import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/lyrics/lyrics_config.dart';
import 'package:openmusic/core/services/lyrics/lyrics_resolver.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/lyrics_resolution_state.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_failure.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_task.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_lyrics.dart';
import 'package:openmusic/layers/domain/repositories/lyrics_provider.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_repository.dart';
import 'package:openmusic/layers/domain/repositories/music_analysis_task_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_lyrics_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/usecases/queue_lyrics_analysis_use_case.dart';

void main() {
  late _Tracks tracks;
  late _Lyrics lyrics;
  late _Analysis analysis;
  late List<LyricsProvider> providers;
  late LyricsResolver resolver;

  setUp(() {
    tracks = _Tracks(_track());
    lyrics = _Lyrics();
    analysis = _Analysis();
    providers = [
      _Provider(LyricsSource.embedded, const LyricsProviderNotFound()),
    ];
    resolver = LyricsResolver(
      tracks: tracks,
      lyrics: lyrics,
      providers: providers,
      queueAnalysis: QueueLyricsAnalysisUseCase(
        analysis: analysis,
        tasks: _Tasks(),
      ),
      config: LyricsConfig(defaultRetryDelay: const Duration(minutes: 5)),
      now: () => DateTime.utc(2026, 8, 27, 12),
    );
  });

  test('valid found cache skips all providers', () async {
    await lyrics.save(
      _storedLyrics('cached lyrics', source: LyricsSource.embedded),
    );
    await lyrics.saveResolutionState(
      LyricsResolutionState(
        trackId: 'track-1',
        status: LyricsResolutionStatus.found,
        source: LyricsSource.embedded,
        metadataRevision: 0,
        updatedAt: DateTime.utc(2026),
      ),
    );
    final provider = _Provider(
      LyricsSource.lrclib,
      LyricsProviderFound(plainText: 'must not be used'),
    );
    providers = [provider];
    resolver = _resolver(tracks, lyrics, analysis, providers);

    final state = await resolver.resolve('track-1');

    expect(state.status, LyricsResolutionStatus.found);
    expect(provider.calls, 0);
  });

  test('embedded result wins and fallback providers are not called', () async {
    final embedded = _Provider(
      LyricsSource.embedded,
      LyricsProviderFound(plainText: 'embedded lyrics'),
    );
    final lrclib = _Provider(
      LyricsSource.lrclib,
      LyricsProviderFound(plainText: 'remote lyrics'),
    );
    resolver = _resolver(tracks, lyrics, analysis, [embedded, lrclib]);

    final state = await resolver.resolve('track-1');

    expect(state.status, LyricsResolutionStatus.found);
    expect(
      (await lyrics.getForTrack('track-1'))?.source,
      LyricsSource.embedded,
    );
    expect(embedded.calls, 1);
    expect(lrclib.calls, 0);
  });

  test('ambiguous result is never persisted as found text', () async {
    final provider = _Provider(
      LyricsSource.lrclib,
      LyricsProviderAmbiguous(bestConfidence: 0.72),
    );
    resolver = _resolver(tracks, lyrics, analysis, [provider]);

    final state = await resolver.resolve('track-1');

    expect(state.status, LyricsResolutionStatus.ambiguous);
    expect(await lyrics.getForTrack('track-1'), isNull);
  });

  test('instrumental result is persisted distinctly', () async {
    final provider = _Provider(
      LyricsSource.lrclib,
      LyricsProviderInstrumental(sourceId: '42'),
    );
    resolver = _resolver(tracks, lyrics, analysis, [provider]);

    final state = await resolver.resolve('track-1');
    final stored = await lyrics.getForTrack('track-1');

    expect(state.status, LyricsResolutionStatus.instrumental);
    expect(stored?.isInstrumental, isTrue);
    expect(stored?.plainText, isEmpty);
  });

  test(
    'temporary failure is retry-gated and does not call provider repeatedly',
    () async {
      final provider = _Provider(
        LyricsSource.lrclib,
        const LyricsProviderTemporaryFailure(
          code: 'rate_limited',
          retryAfter: Duration(minutes: 2),
        ),
      );
      resolver = _resolver(tracks, lyrics, analysis, [provider]);

      final first = await resolver.resolve('track-1');
      final second = await resolver.resolve('track-1');

      expect(first.status, LyricsResolutionStatus.failed);
      expect(second.status, LyricsResolutionStatus.failed);
      expect(first.retryAt, DateTime.utc(2026, 8, 27, 12, 2));
      expect(provider.calls, 1);
    },
  );
}

LyricsResolver _resolver(
  _Tracks tracks,
  _Lyrics lyrics,
  _Analysis analysis,
  List<LyricsProvider> providers,
) => LyricsResolver(
  tracks: tracks,
  lyrics: lyrics,
  providers: providers,
  queueAnalysis: QueueLyricsAnalysisUseCase(
    analysis: analysis,
    tasks: _Tasks(),
  ),
  config: LyricsConfig(),
  now: () => DateTime.utc(2026, 8, 27, 12),
);

Track _track() => Track(
  id: 'track-1',
  title: 'Song',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.localFile,
    originalUrl: '/music/song.mp3',
  ),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
);

TrackLyrics _storedLyrics(
  String text, {
  LyricsSource source = LyricsSource.lrclib,
}) => TrackLyrics(
  trackId: 'track-1',
  source: source,
  plainText: text,
  contentHash:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  fetchedAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _Provider implements LyricsProvider {
  _Provider(this.source, this.result);
  @override
  final LyricsSource source;
  final LyricsProviderResult result;
  int calls = 0;
  @override
  Future<LyricsProviderResult> resolve(LyricsRequest request) async {
    calls++;
    return result;
  }
}

class _Tracks implements TrackRepository {
  _Tracks(this.track);
  Track track;
  @override
  Future<List<Track>> getTracks() async => [track];
  @override
  Future<Track?> getTrackById(String id) async => id == track.id ? track : null;
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => [
    if (ids.contains(track.id)) track,
  ];
  @override
  Future<List<Track>> searchTracks(
    String query, {
    required int limit,
    required int offset,
  }) async => [track];
  @override
  Future<void> updateMetadata(Track track) async => this.track = track;
  @override
  Stream<void> watchChanges() => const Stream.empty();
}

class _Lyrics implements TrackLyricsRepository {
  TrackLyrics? value;
  LyricsResolutionState? state;
  @override
  Future<TrackLyrics?> getForTrack(String trackId) async => value;
  @override
  Future<void> save(TrackLyrics lyrics) async => value = lyrics;
  @override
  Future<LyricsResolutionState?> getResolutionState(String trackId) async =>
      state;
  @override
  Future<void> saveResolutionState(LyricsResolutionState state) async =>
      this.state = state;
  @override
  Future<void> deleteForTrack(String trackId) async {
    value = null;
    state = null;
  }
}

class _Analysis implements MusicAnalysisRepository {
  @override
  Future<Set<MusicAnalysisRepresentation>> missingRepresentations({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async => const {};
  @override
  Future<MusicAnalysisDisposition> analyzeTrack({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async => MusicAnalysisDisposition.cached;
}

class _Tasks implements MusicAnalysisTaskRepository {
  @override
  Stream<List<MusicAnalysisTask>> watchAll() => const Stream.empty();
  @override
  Stream<int> watchPendingCount() => const Stream.empty();
  @override
  Future<List<MusicAnalysisTask>> getAll() async => const [];
  @override
  Future<void> enqueue({
    required String trackId,
    required int audioRevision,
    required Set<MusicAnalysisRepresentation> representations,
  }) async {}
  @override
  Future<MusicAnalysisTask?> claimNext() async => null;
  @override
  Future<void> complete(String id) async {}
  @override
  Future<void> fail(
    String id,
    MusicAnalysisFailure failure, {
    required bool requeue,
  }) async {}
  @override
  Future<void> retryFailed() async {}
  @override
  Future<void> resetRunning() async {}
}
