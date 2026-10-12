import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/download/download_failure_classifier.dart';
import 'package:owlsonic/core/services/download/download_worker.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/services/track_source_resolver.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/spotify_track_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:owlsonic/layers/data/repositories/download_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_repository_impl.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:owlsonic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/retry_track_download_use_case.dart';

const _videoUrl = 'https://www.youtube.com/watch?v=D8byISljNdE';
const _preview = TrackPreview(
  id: 'D8byISljNdE',
  title: 'Track',
  artist: 'Artist',
  source: SourceType.youtube,
  originalUrl: _videoUrl,
  urlFile: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('application DI resolves YouTube and Spotify without opt-in', () async {
    await configureDependencies(
      appDir: '/unused',
      database: AppDatabase(NativeDatabase.memory()),
    );
    addTearDown(() async {
      await getIt<AppDatabase>().close();
      await getIt.reset();
    });

    final resolver = getIt<TrackSourceResolver>();
    expect(resolver.resolveByUrl(_videoUrl), isA<YoutubeTrackSource>());
    expect(
      resolver.resolveByUrl('https://open.spotify.com/track/spotify-track'),
      isA<SpotifyTrackSource>(),
    );
    expect(
      resolver.resolveByType(SourceType.youtube),
      isA<YoutubeTrackSource>(),
    );
    expect(
      resolver.resolveByType(SourceType.spotify),
      isA<SpotifyTrackSource>(),
    );
    expect(
      () => resolver.resolveByUrl('https://example.com/track'),
      throwsA(isA<UnsupportedSourceFailure>()),
    );
  });

  for (final retry in [false, true]) {
    test(
      retry
          ? 'worker downloads YouTube after retrying an unsupported failure'
          : 'worker downloads a queued YouTube track',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        final local = DownloadTaskDriftLocalSource(database);
        final tasks = DownloadTaskRepositoryImpl(localDataSource: local);
        await database
            .into(database.trackTable)
            .insert(
              TrackTableCompanion.insert(
                id: _preview.id,
                title: _preview.title,
                sourceType: SourceType.youtube.name,
                sourceUri: _videoUrl,
              ),
            );
        await tasks.enqueue(_preview.id, _videoUrl);

        if (retry) {
          await tasks.claimNext(ownerId: 'previous-worker');
          await tasks.markFailed(
            trackId: _preview.id,
            ownerId: 'previous-worker',
            failure: DownloadFailureClassifier.classify(
              const UnsupportedSourceFailure(_videoUrl),
              StackTrace.current,
              trackId: _preview.id,
              originalUrl: _videoUrl,
            ),
          );
          expect(
            (await local.getAll()).single.failure?.code,
            DownloadFailureCodes.unsupported,
          );
          await RetryTrackDownloadUseCase(tasks)(_preview.toTrack(null));
          final retried = (await local.getAll()).single;
          expect(retried.status, DownloadStatus.queued);
          expect(retried.failure, isNull);
        }

        final source = _FakeYoutubeSource();
        final worker = DownloadWorker(
          downloadRepository: tasks,
          trackResolver: TrackSourceResolver([source]),
          completeDownload: CompleteTrackDownloadUseCase(
            TrackDownloadCompletionRepositoryImpl(database),
          ),
        );
        addTearDown(worker.stop);
        final completed = tasks.watchAll().firstWhere((queue) => queue.isEmpty);
        final processing = worker.startProcessing();
        await completed.timeout(const Duration(seconds: 10));
        await worker.stop();
        await processing;

        expect(
          source.resolvedUrls,
          isEmpty,
          reason:
              'YouTube downloads from the stored link; re-resolving the watch '
              'page is an extra request that a bot check can fail',
        );
        expect(source.downloadedIds, [_preview.id]);
        final track = await database.select(database.trackTable).getSingle();
        expect(track.pathToFile, '/downloaded/D8byISljNdE.m4a');
        expect(await local.getAll(), isEmpty);
      },
    );
  }

  test('Spotify download falls back after YouTube bot check', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = DownloadTaskDriftLocalSource(database);
    final tasks = DownloadTaskRepositoryImpl(localDataSource: local);
    await database
        .into(database.trackTable)
        .insert(
          TrackTableCompanion.insert(
            id: 'spotify-track',
            title: 'Song',
            sourceType: SourceType.spotify.name,
            sourceUri: 'https://open.spotify.com/track/spotify-track',
            mediaSourceType: Value(SourceType.youtube.name),
            mediaSourceId: const Value('D8byISljNdE'),
            mediaSourceUri: const Value(_videoUrl),
          ),
        );
    await tasks.enqueue('spotify-track', _videoUrl);
    final youtube = _BlockedYoutubeSource();
    final spotify = _FakeSpotifyFallback();
    final soundcloud = _FakeSoundcloudSource();
    final analytics = _RecordingAnalytics();
    final worker = DownloadWorker(
      downloadRepository: tasks,
      analytics: analytics,
      trackResolver: TrackSourceResolver([youtube, spotify, soundcloud]),
      completeDownload: CompleteTrackDownloadUseCase(
        TrackDownloadCompletionRepositoryImpl(database),
      ),
      trackRepository: TrackRepositoryImpl(
        localDataSource: TrackDriftLocalSource(database),
      ),
    );
    addTearDown(worker.stop);

    final completed = tasks.watchAll().firstWhere((queue) => queue.isEmpty);
    final processing = worker.startProcessing();
    await completed.timeout(const Duration(seconds: 10));
    await worker.stop();
    await processing;

    expect(youtube.attempts, 1);
    expect(spotify.searchedTrackIds, ['spotify-track']);
    expect(soundcloud.downloadedIds, ['42']);
    final track = await database.select(database.trackTable).getSingle();
    expect(track.pathToFile, '/downloaded/42.mp3');
    expect(track.sourceType, SourceType.spotify.name);
    expect(track.mediaSourceType, SourceType.soundcloud.name);
    expect(track.mediaSourceId, '42');
    expect(track.mediaSourceUri, 'https://soundcloud.com/artist/song');
    expect(track.contentIdentity, 'soundcloud:42');
    expect(analytics.events, ['offline_download_completed']);
    expect(await local.getAll(), isEmpty);
  });

  test('without a SoundCloud match the YouTube failure remains', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final local = DownloadTaskDriftLocalSource(database);
    final tasks = DownloadTaskRepositoryImpl(localDataSource: local);
    await database
        .into(database.trackTable)
        .insert(
          TrackTableCompanion.insert(
            id: 'spotify-track',
            title: 'Song',
            sourceType: SourceType.spotify.name,
            sourceUri: 'https://open.spotify.com/track/spotify-track',
            mediaSourceType: Value(SourceType.youtube.name),
            mediaSourceId: const Value('D8byISljNdE'),
            mediaSourceUri: const Value(_videoUrl),
          ),
        );
    await tasks.enqueue('spotify-track', _videoUrl);
    final spotify = _FakeSpotifyFallback()..candidate = null;
    final soundcloud = _FakeSoundcloudSource();
    final analytics = _RecordingAnalytics();
    final worker = DownloadWorker(
      downloadRepository: tasks,
      analytics: analytics,
      trackResolver: TrackSourceResolver([
        _BlockedYoutubeSource(),
        spotify,
        soundcloud,
      ]),
      completeDownload: CompleteTrackDownloadUseCase(
        TrackDownloadCompletionRepositoryImpl(database),
      ),
      trackRepository: TrackRepositoryImpl(
        localDataSource: TrackDriftLocalSource(database),
      ),
    );
    addTearDown(worker.stop);

    final failed = tasks.watchAll().firstWhere(
      (queue) => queue.single.status == DownloadStatus.failed,
    );
    final processing = worker.startProcessing();
    final queue = await failed.timeout(const Duration(seconds: 10));
    await worker.stop();
    await processing;

    expect(queue.single.failure?.code, DownloadFailureCodes.botCheck);
    expect(spotify.searchedTrackIds, ['spotify-track']);
    expect(soundcloud.downloadedIds, isEmpty);
    final track = await database.select(database.trackTable).getSingle();
    expect(track.pathToFile, isNull);
    expect(analytics.events, isEmpty);
    expect(track.mediaSourceType, SourceType.youtube.name);
    expect(track.mediaSourceId, 'D8byISljNdE');
  });
}

class _BlockedYoutubeSource extends YoutubeTrackSource {
  int attempts = 0;

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async {
    attempts++;
    throw const YouTubeFailure(botCheck: true);
  }
}

class _FakeSpotifyFallback implements TrackSource, TrackAudioFallback {
  final searchedTrackIds = <String>[];
  TrackPreview? candidate = const TrackPreview(
    id: '42',
    title: 'Song',
    artist: 'Artist',
    duration: Duration(minutes: 3),
    source: SourceType.soundcloud,
    originalUrl: 'https://soundcloud.com/artist/song',
    urlFile: '',
  );

  @override
  SourceType get sourceType => SourceType.spotify;

  @override
  bool canHandle(String input) => input.contains('open.spotify.com');

  @override
  Future<TrackPreview?> findFallback(Track track) async {
    searchedTrackIds.add(track.id);
    return candidate;
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) =>
      throw UnimplementedError();

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) => throw UnimplementedError();
}

class _FakeSoundcloudSource implements TrackSource {
  final downloadedIds = <String>[];

  @override
  SourceType get sourceType => SourceType.soundcloud;

  @override
  bool canHandle(String input) => input.contains('soundcloud.com');

  @override
  Future<ResolvedTrackInput> resolve(String input) =>
      throw UnimplementedError();

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async {
    downloadedIds.add(track.id);
    return '/downloaded/${track.id}.mp3';
  }
}

class _FakeYoutubeSource extends YoutubeTrackSource {
  final resolvedUrls = <String>[];
  final downloadedIds = <String>[];

  @override
  Future<ResolvedTrackInput> resolve(String input) async {
    resolvedUrls.add(input);
    return ResolvedTrackInput.single(_preview);
  }

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    downloadedIds.add(track.id);
    return '/downloaded/${track.id}.m4a';
  }
}

final class _RecordingAnalytics implements AnalyticsTracker {
  final events = <String>[];
  @override
  bool get isAvailable => true;
  @override
  bool get isEnabled => true;
  @override
  Future<void> setEnabled(bool enabled) async {}
  @override
  Future<void> logEvent(String name, {Map<String, Object>? properties}) async {
    events.add(name);
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {}
}
