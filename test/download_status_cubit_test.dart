import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/download_task_repository.dart';
import 'package:openmusic/layers/domain/usecases/retry_track_download_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/download_status/download_status_cubit.dart';

void main() {
  test('publishes tasks by track id and retries downloads', () async {
    final stream = StreamController<List<DownloadTrackTask>>();
    final repository = _FakeDownloadTaskRepository(stream.stream);
    final cubit = DownloadStatusCubit(
      tasks: repository.watchAll(),
      retryDownload: RetryTrackDownloadUseCase(repository),
    );
    addTearDown(() async {
      await cubit.close();
      await stream.close();
    });

    stream.add([
      DownloadTrackTask(
        trackId: 'track-1',
        originalUrl: 'https://example.com/track',
        createdAt: DateTime.utc(2026, 8, 18),
        status: DownloadStatus.failed,
      ),
    ]);
    await pumpEventQueue();

    expect(cubit.state['track-1']?.status, DownloadStatus.failed);

    await cubit.retry(_track());

    expect(repository.enqueued, [('track-1', 'https://example.com/track')]);
  });
}

Track _track() => Track(
  id: 'track-1',
  title: 'Track',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.soundcloud,
    originalUrl: 'https://example.com/track',
  ),
  addedAt: DateTime.utc(2026, 8, 18),
);

class _FakeDownloadTaskRepository implements DownloadTaskRepository {
  _FakeDownloadTaskRepository(this._tasks);

  final Stream<List<DownloadTrackTask>> _tasks;
  final enqueued = <(String, String)>[];

  @override
  Future<void> enqueue(String trackId, String originalUrl) async {
    enqueued.add((trackId, originalUrl));
  }

  @override
  Stream<List<DownloadTrackTask>> watchAll() => _tasks;

  @override
  Future<DownloadTrackTask?> claimNext({required String ownerId}) async => null;

  @override
  Future<bool> markFailed({
    required String trackId,
    required String ownerId,
    required DownloadFailureInfo failure,
  }) async => false;

  @override
  Future<bool> releaseLease({
    required String trackId,
    required String ownerId,
  }) async => false;

  @override
  Future<bool> renewLease({
    required String trackId,
    required String ownerId,
  }) async => false;
}
