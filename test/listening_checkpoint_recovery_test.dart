import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/play_record/drift/play_record_drift_local_source.dart';
import 'package:openmusic/layers/data/repositories/listening_checkpoint_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/play_record_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/recover_listening_checkpoint_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';

void main() {
  test('checkpoint keeps maximum duration and recovery is durable', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final checkpoints = ListeningCheckpointRepositoryImpl(database);
    final first = await checkpoints.save(_track(), const Duration(seconds: 35));
    final second = await checkpoints.save(
      _track(),
      const Duration(seconds: 30),
    );
    expect(second.id, first.id);
    expect(second.listenedDuration, const Duration(seconds: 35));

    final records = PlayRecordRepositoryImpl(
      localDataSource: PlayRecordDriftLocalSource(database),
    );
    final recover = RecoverListeningCheckpointUseCase(
      checkpoints: checkpoints,
      saveRecord: SaveRecordPlayUseCase(repo: records),
    );
    await recover();
    await recover();

    final stored = await database.select(database.playRecordTable).get();
    expect(stored, hasLength(1));
    expect(stored.single.id, first.id);
    expect(stored.single.listenedDurationMilliseconds, 35000);
    expect(await checkpoints.load(), isNull);
  });
}

Track _track() => Track(
  id: 'track-1',
  title: 'Track',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.localFile,
    originalUrl: '/music/track.mp3',
  ),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
);
