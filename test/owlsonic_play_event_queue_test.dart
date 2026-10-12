import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/data/repositories/cloud_aware_repositories.dart';
import 'package:owlsonic/core/services/cloud/play_event_queue.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

class _Store implements PlayEventStore {
  List<PlayEvent> events = [];
  @override
  Future<List<PlayEvent>> load() async => List.of(events);
  @override
  Future<void> save(List<PlayEvent> next) async => events = List.of(next);
}

class _History implements CloudHistoryRepository {
  final submitted = <List<String>>[];
  OwlSonicApiException? Function(List<PlayEvent>)? failWith;

  @override
  Future<PlayEventsResult> submit(List<PlayEvent> events) async {
    submitted.add(events.map((e) => e.id).toList());
    final error = failWith?.call(events);
    if (error != null) throw error;
    return PlayEventsResult(accepted: events.length, duplicates: 0);
  }

  @override
  Future<CloudPage<CloudHistoryItem>> list({String? cursor, int? limit}) =>
      throw UnimplementedError();
}

const _offline = OwlSonicApiException(
  kind: OwlSonicApiErrorKind.network,
  code: 'network_unavailable',
  message: 'offline',
  retryable: true,
);

void main() {
  test('event id is generated once and reused across retries', () async {
    final store = _Store();
    final history = _History()..failWith = (_) => _offline;
    var ids = 0;
    final queue = PlayEventQueue(
      store: store,
      history: history,
      newId: () => 'event-${++ids}',
    );

    await queue.record(
      trackId: 't1',
      playedAt: DateTime.utc(2026),
      listened: const Duration(seconds: 30),
    );
    expect(await queue.flush(), 0);
    expect(await queue.flush(), 0);
    history.failWith = null;
    expect(await queue.flush(), 1);

    expect(history.submitted, [
      ['event-1'],
      ['event-1'],
      ['event-1'],
    ]);
    expect(ids, 1);
    expect(store.events, isEmpty);
  });

  test('queued events survive a new queue instance (app restart)', () async {
    final store = _Store();
    await PlayEventQueue(
      store: store,
      history: _History(),
      newId: () => 'e1',
    ).record(
      trackId: 't',
      playedAt: DateTime.utc(2026),
      listened: Duration.zero,
    );

    final restarted = PlayEventQueue(store: store, history: _History());
    expect((await restarted.pending()).single.id, 'e1');
  });

  test('a permanently rejected event is isolated and dropped', () async {
    final store = _Store();
    final history = _History()
      ..failWith = (events) => events.any((e) => e.trackId == 'gone')
          ? const OwlSonicApiException(
              kind: OwlSonicApiErrorKind.server,
              code: 'track_not_found',
              message: 'missing',
              retryable: false,
              statusCode: 404,
            )
          : null;
    var ids = 0;
    final queue = PlayEventQueue(
      store: store,
      history: history,
      newId: () => 'e${++ids}',
    );
    for (final track in ['a', 'gone', 'b']) {
      await queue.record(
        trackId: track,
        playedAt: DateTime.utc(2026),
        listened: Duration.zero,
      );
    }

    expect(await queue.flush(), 3);
    expect(store.events, isEmpty);
    expect(history.submitted.first, ['e1', 'e2', 'e3']);
  });

  // The deployed backend rejects non-v7 ids for play events (422 value_error
  // on events[].id), playlists and playlist items; found by the smoke test.
  test('backend-bound ids are UUIDv7', () async {
    final queue = PlayEventQueue(store: _Store(), history: _History());
    final event = await queue.record(
      trackId: 't',
      playedAt: DateTime.utc(2026),
      listened: Duration.zero,
    );
    expect(isUuidV7(event.id), isTrue);
    expect(isUuidV7('018f2c3a-0000-7000-8000-000000000001'), isTrue);
    expect(isUuidV7('2c1f5f3e-8a4b-4c1d-9e2f-1a2b3c4d5e6f'), isFalse);
  });
}
