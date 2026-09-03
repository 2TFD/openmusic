import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/listening_event_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/listening_event.dart';
import 'package:openmusic/layers/domain/repositories/listening_event_repository.dart';
import 'package:openmusic/layers/domain/services/listening_tracker.dart';
import 'package:openmusic/layers/domain/usecases/save_listening_event_use_case.dart';

void main() {
  test('Drift repository is append-only and maps all event data', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = ListeningEventRepositoryImpl(database);
    final event = ListeningEvent(
      id: 'event-1',
      sessionId: 'session-1',
      trackId: 'track-1',
      type: ListeningEventType.seekForward,
      occurredAt: DateTime.utc(2026),
      positionMs: 20000,
      listenedMs: 5000,
      durationMs: 180000,
      previousTrackId: 'track-0',
      transitionReason: ListeningTransitionReason.unknown,
    );

    await repository.save(event);
    final stored = (await repository.getForTrack('track-1')).single;
    expect(stored.id, event.id);
    expect(stored.type, event.type);
    expect(stored.occurredAt.isAtSameMomentAs(event.occurredAt), isTrue);
    expect(stored.positionMs, event.positionMs);
    expect(stored.listenedMs, event.listenedMs);
    expect(stored.durationMs, event.durationMs);
    expect(stored.previousTrackId, event.previousTrackId);
    expect(stored.transitionReason, event.transitionReason);
    await expectLater(repository.save(event), throwsA(anything));
    expect(await repository.getAll(), hasLength(1));
  });

  test(
    'confirmed early next persists skip and transition below 30 seconds',
    () async {
      final repository = _MemoryListeningEventRepository();
      final tracker = _tracker(repository);
      tracker.synchronize(
        trackId: 'track-a',
        position: const Duration(seconds: 5),
        listened: const Duration(seconds: 5),
        duration: const Duration(minutes: 3),
        isPlaying: true,
      );
      tracker.navigationRequested(ListeningNavigationIntent.userNext);

      await tracker.trackChanged(
        previousTrackId: 'track-a',
        trackId: 'track-b',
        previousPosition: const Duration(seconds: 5),
        previousListened: const Duration(seconds: 5),
        previousDuration: const Duration(minutes: 3),
        duration: const Duration(minutes: 4),
        isPlaying: true,
      );

      final skip = repository.events.singleWhere(
        (event) => event.type == ListeningEventType.skipNext,
      );
      final changed = repository.events.singleWhere(
        (event) => event.type == ListeningEventType.trackChanged,
      );
      expect(skip.listenedMs, 5000);
      expect(skip.transitionReason, ListeningTransitionReason.userNext);
      expect(changed.previousTrackId, 'track-a');
      expect(changed.transitionReason, ListeningTransitionReason.userNext);
      expect(
        repository.events.where(
          (event) => event.type == ListeningEventType.trackCompleted,
        ),
        isEmpty,
      );
    },
  );

  test(
    'natural completion requires transition evidence beyond position',
    () async {
      final repository = _MemoryListeningEventRepository();
      final tracker = _tracker(repository);
      tracker.synchronize(
        trackId: 'track-a',
        position: const Duration(minutes: 2, seconds: 59),
        listened: const Duration(minutes: 2, seconds: 50),
        duration: const Duration(minutes: 3),
        isPlaying: true,
      );

      await tracker.trackChanged(
        previousTrackId: 'track-a',
        trackId: 'track-b',
        previousPosition: const Duration(minutes: 2, seconds: 59),
        previousListened: const Duration(minutes: 2, seconds: 50),
        previousDuration: const Duration(minutes: 3),
        duration: const Duration(minutes: 3),
        isPlaying: true,
      );

      expect(
        repository.events
            .singleWhere(
              (event) => event.type == ListeningEventType.trackCompleted,
            )
            .transitionReason,
        ListeningTransitionReason.natural,
      );
    },
  );

  test('unexplained early transition is recorded as unknown', () async {
    final repository = _MemoryListeningEventRepository();
    final tracker = _tracker(repository);
    tracker.synchronize(
      trackId: 'track-a',
      position: const Duration(seconds: 20),
      listened: const Duration(seconds: 20),
      duration: const Duration(minutes: 3),
      isPlaying: true,
    );

    await tracker.trackChanged(
      previousTrackId: 'track-a',
      trackId: 'track-b',
      previousPosition: const Duration(seconds: 20),
      previousListened: const Duration(seconds: 20),
      previousDuration: const Duration(minutes: 3),
      duration: const Duration(minutes: 3),
      isPlaying: true,
    );

    final changed = repository.events.singleWhere(
      (event) => event.type == ListeningEventType.trackChanged,
    );
    expect(changed.transitionReason, ListeningTransitionReason.unknown);
    expect(
      repository.events.where(
        (event) => event.type == ListeningEventType.trackCompleted,
      ),
      isEmpty,
    );
  });

  test(
    'play, pause, resume, seeks, replay and processing completion persist',
    () async {
      final repository = _MemoryListeningEventRepository();
      final tracker = _tracker(repository);
      tracker.synchronize(
        trackId: 'track-a',
        position: Duration.zero,
        listened: Duration.zero,
        duration: const Duration(minutes: 3),
        isPlaying: false,
      );
      await tracker.playingChanged(
        trackId: 'track-a',
        isPlaying: true,
        position: Duration.zero,
        listened: Duration.zero,
        duration: const Duration(minutes: 3),
      );
      await tracker.playingChanged(
        trackId: 'track-a',
        isPlaying: false,
        position: const Duration(seconds: 10),
        listened: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
      );
      await tracker.playingChanged(
        trackId: 'track-a',
        isPlaying: true,
        position: const Duration(seconds: 10),
        listened: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
      );
      await tracker.seekConfirmed(
        trackId: 'track-a',
        from: const Duration(seconds: 10),
        to: const Duration(seconds: 30),
        listened: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
      );
      await tracker.seekConfirmed(
        trackId: 'track-a',
        from: const Duration(seconds: 30),
        to: const Duration(seconds: 5),
        listened: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
      );
      await tracker.replayConfirmed(
        trackId: 'track-a',
        listened: const Duration(seconds: 10),
        duration: const Duration(minutes: 3),
      );
      await tracker.processingCompleted(
        trackId: 'track-a',
        position: const Duration(minutes: 2, seconds: 58),
        listened: const Duration(minutes: 2),
        duration: const Duration(minutes: 3),
      );

      expect(repository.events.map((event) => event.type), [
        ListeningEventType.playStarted,
        ListeningEventType.pause,
        ListeningEventType.resume,
        ListeningEventType.seekForward,
        ListeningEventType.seekBackward,
        ListeningEventType.replay,
        ListeningEventType.trackCompleted,
      ]);
    },
  );
}

ListeningTracker _tracker(_MemoryListeningEventRepository repository) {
  var id = 0;
  return ListeningTracker(
    saveEvent: SaveListeningEventUseCase(repository),
    sessionId: 'runtime-session',
    now: () => DateTime.utc(2026),
    createId: () => 'event-${id++}',
  );
}

class _MemoryListeningEventRepository implements ListeningEventRepository {
  final events = <ListeningEvent>[];

  @override
  Future<void> save(ListeningEvent event) async => events.add(event);

  @override
  Future<List<ListeningEvent>> getAll() async => List.of(events);

  @override
  Future<List<ListeningEvent>> getForTrack(String trackId) async =>
      events.where((event) => event.trackId == trackId).toList();
}
