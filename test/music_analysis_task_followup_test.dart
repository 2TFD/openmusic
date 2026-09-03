import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/music_analysis_task_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/music_analysis.dart';
import 'package:openmusic/layers/domain/entities/music_analysis_task.dart';

void main() {
  test('enqueue while running keeps a distinct follow-up task', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.customStatement(
      'INSERT INTO track_table (id, title, source_type, source_uri) '
      'VALUES (?, ?, ?, ?)',
      ['track-1', 'Track', 'localFile', '/track-1.mp3'],
    );
    final repository = MusicAnalysisTaskRepositoryImpl(database);
    await repository.enqueue(
      trackId: 'track-1',
      audioRevision: 1,
      representations: const {MusicAnalysisRepresentation.audioGlobal},
    );
    final running = (await repository.claimNext())!;

    await repository.enqueue(
      trackId: 'track-1',
      audioRevision: 1,
      representations: const {MusicAnalysisRepresentation.lyricsGlobal},
    );

    final tasks = await repository.getAll();
    expect(tasks, hasLength(2));
    expect(
      tasks.where((task) => task.status == MusicAnalysisTaskStatus.running),
      hasLength(1),
    );
    final followUp = tasks.singleWhere(
      (task) => task.status == MusicAnalysisTaskStatus.queued,
    );
    expect(followUp.id, isNot(running.id));
    expect(followUp.requestedRepresentations, {
      MusicAnalysisRepresentation.lyricsGlobal,
    });

    await repository.complete(running.id);
    expect((await repository.claimNext())?.id, followUp.id);
  });

  test(
    'enqueue merges representations into an existing queued follow-up',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.customStatement(
        'INSERT INTO track_table (id, title, source_type, source_uri) '
        'VALUES (?, ?, ?, ?)',
        ['track-1', 'Track', 'localFile', '/track-1.mp3'],
      );
      final repository = MusicAnalysisTaskRepositoryImpl(database);

      await repository.enqueue(
        trackId: 'track-1',
        audioRevision: 1,
        representations: const {MusicAnalysisRepresentation.audioGlobal},
      );
      await repository.enqueue(
        trackId: 'track-1',
        audioRevision: 1,
        representations: const {
          MusicAnalysisRepresentation.audioTemporal,
          MusicAnalysisRepresentation.lyricsGlobal,
        },
      );

      final task = (await repository.getAll()).single;
      expect(task.requestedRepresentations, {
        MusicAnalysisRepresentation.audioGlobal,
        MusicAnalysisRepresentation.audioTemporal,
        MusicAnalysisRepresentation.lyricsGlobal,
      });
    },
  );
}
