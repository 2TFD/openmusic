import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/download/download_failure_classifier.dart';
import 'package:openmusic/core/services/download/download_worker.dart';
import 'package:openmusic/core/services/spotify/spotify_auth_service.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/download_task/drift/download_task_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/remote/spotify_track_source.dart';
import 'package:openmusic/layers/data/datasources/remote/youtube_track_source.dart';
import 'package:openmusic/layers/data/repositories/download_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_download_completion_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/usecases/complete_track_download_use_case.dart';
import 'package:openmusic/layers/domain/usecases/retry_track_download_use_case.dart';

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
    expect(getIt<SpotifyAuthService>(), isA<SpotifyAuthService>());
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

        expect(source.resolvedUrls, [_videoUrl]);
        expect(source.downloadedIds, [_preview.id]);
        final track = await database.select(database.trackTable).getSingle();
        expect(track.pathToFile, '/downloaded/D8byISljNdE.m4a');
        expect(await local.getAll(), isEmpty);
      },
    );
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
