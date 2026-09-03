import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/lyrics_resolution_task_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/lyrics_resolution_task.dart';

void main() {
  late AppDatabase database;
  late LyricsResolutionTaskRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = LyricsResolutionTaskRepositoryImpl(database);
    await _insertTrack(database, 'track-1');
  });

  tearDown(() => database.close());

  test(
    'enqueue is idempotent and claim increments the attempt count',
    () async {
      await Future.wait([
        repository.enqueue('track-1'),
        repository.enqueue('track-1'),
      ]);

      expect(
        await database.select(database.lyricsResolutionTaskTable).get(),
        hasLength(1),
      );
      final claimed = await repository.claimNext();
      expect(claimed?.trackId, 'track-1');
      expect(claimed?.status, LyricsResolutionTaskStatus.running);
      expect(claimed?.attemptCount, 1);
      expect(await repository.claimNext(), isNull);
    },
  );

  test('retryAt prevents an early claim and permits a due retry', () async {
    await repository.enqueue('track-1');
    final first = (await repository.claimNext())!;
    await repository.fail(
      first.id,
      errorCode: 'rateLimited',
      errorMessage: 'Retry later',
      requeue: true,
      retryAt: DateTime.now().add(const Duration(hours: 1)),
    );

    expect(await repository.claimNext(), isNull);
    await repository.fail(
      first.id,
      errorCode: 'rateLimited',
      requeue: true,
      retryAt: DateTime.now().subtract(const Duration(seconds: 1)),
    );

    final retried = await repository.claimNext();
    expect(retried?.id, first.id);
    expect(retried?.attemptCount, 2);
  });

  test(
    'completed and terminal failed tasks can be explicitly re-enqueued',
    () async {
      await repository.enqueue('track-1');
      final completed = (await repository.claimNext())!;
      await repository.complete(completed.id);
      await repository.enqueue('track-1');
      final afterCompletion = (await repository.claimNext())!;
      expect(afterCompletion.attemptCount, 1);

      await repository.fail(
        afterCompletion.id,
        errorCode: 'invalidMetadata',
        requeue: false,
      );
      await repository.enqueue('track-1');
      final afterFailure = (await repository.claimNext())!;
      expect(afterFailure.id, completed.id);
      expect(afterFailure.attemptCount, 1);
    },
  );

  test('resetRunning makes interrupted work claimable again', () async {
    await repository.enqueue('track-1');
    final first = (await repository.claimNext())!;

    await repository.resetRunning();

    final reset = await repository.claimNext();
    expect(reset?.id, first.id);
    expect(reset?.attemptCount, 2);
  });

  test('track deletion cascades to the durable task', () async {
    await repository.enqueue('track-1');

    await database.customStatement(
      "DELETE FROM track_table WHERE id = 'track-1'",
    );

    expect(
      await database.select(database.lyricsResolutionTaskTable).get(),
      isEmpty,
    );
  });
}

Future<void> _insertTrack(AppDatabase database, String id) =>
    database.customStatement(
      'INSERT INTO track_table (id, title, source_type, source_uri) '
      'VALUES (?, ?, ?, ?)',
      [id, id, 'localFile', '/$id.mp3'],
    );
