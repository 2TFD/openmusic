import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

class _Cursors implements SyncCursorStore {
  String? value;
  final writes = <String>[];
  @override
  Future<void> clear() async => value = null;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String cursor) async {
    writes.add(cursor);
    value = cursor;
  }
}

class _Remote implements CloudSyncRepository {
  _Remote(this.pages);
  final Map<String?, SyncPage> pages;
  final requested = <String?>[];
  @override
  Future<SyncPage> pull({String? cursor, int? limit}) async {
    requested.add(cursor);
    return pages[cursor]!;
  }
}

/// Idempotent: keyed by event id, like a transactional upsert would be.
class _Applier implements SyncEventApplier {
  final applied = <String, SyncEvent>{};
  int failOnPage = -1;
  int pagesSeen = 0;
  @override
  Future<void> apply(SyncPage page) async {
    if (pagesSeen++ == failOnPage) throw StateError('db busy');
    for (final event in page.events) {
      applied[event.id!] = event;
    }
  }
}

SyncEvent _event(String id) => SyncEvent(
  id: id,
  type: 'opaque',
  version: 1,
  entityId: 'e-$id',
  payload: const {},
  createdAt: null,
);

SyncPage _page(SyncMode mode, List<String> ids, String next, bool more) =>
    SyncPage(
      mode: mode,
      events: ids.map(_event).toList(),
      nextCursor: next,
      hasMore: more,
    );

void main() {
  group('playback source', () {
    late int fetches;
    late DateTime now;
    late SignedUrlCache cache;
    late CloudPlaybackSourceSelector selector;

    setUp(() {
      fetches = 0;
      now = DateTime.utc(2026, 10, 7, 12);
      cache = SignedUrlCache(
        now: () => now,
        fetch: (id) async => SignedUrl(
          url: Uri.parse('https://cdn.test/$id?v=${++fetches}'),
          expiresAt: now.add(const Duration(minutes: 5)),
        ),
      );
      selector = CloudPlaybackSourceSelector(
        playbackUrls: cache,
        fileExists: (path) async => path.startsWith('/exists'),
      );
    });

    test('valid local file wins over cache and cloud', () async {
      final source = await selector.resolve(
        localPath: '/exists/a.mp3',
        cachedPath: '/exists/cache.mp3',
        cloudTrackId: 't1',
      );
      expect(
        source,
        isA<LocalPlaybackSource>().having((s) => s.cached, 'cached', isFalse),
      );
      expect(fetches, 0);
    });

    test('cached file is used when the local file is gone', () async {
      final source = await selector.resolve(
        localPath: '/missing/a.mp3',
        cachedPath: '/exists/cache.mp3',
        cloudTrackId: 't1',
      );
      expect(
        source,
        isA<LocalPlaybackSource>().having((s) => s.cached, 'cached', isTrue),
      );
    });

    test('falls back to a backend signed URL, reused until expiry', () async {
      final first = await selector.resolve(cloudTrackId: 't1');
      final second = await selector.resolve(cloudTrackId: 't1');
      expect((first as RemotePlaybackSource).uri.queryParameters['v'], '1');
      expect((second as RemotePlaybackSource).uri.queryParameters['v'], '1');
      expect(fetches, 1);
    });

    test('expired URL is reacquired', () async {
      await selector.resolve(cloudTrackId: 't1');
      now = now.add(const Duration(minutes: 5));
      final next = await selector.resolve(cloudTrackId: 't1');
      expect((next as RemotePlaybackSource).uri.queryParameters['v'], '2');
    });

    test('rejected stream invalidates the cached URL', () async {
      await selector.resolve(cloudTrackId: 't1');
      selector.reportRemoteFailure('t1');
      await selector.resolve(cloudTrackId: 't1');
      expect(fetches, 2);
    });

    test('no local file and no cloud id is unavailable', () async {
      await expectLater(
        selector.resolve(localPath: '/missing/a.mp3'),
        throwsA(isA<PlaybackUnavailable>()),
      );
    });
  });

  group('sync engine', () {
    test(
      'bootstrap pages until has_more is false, persisting each cursor',
      () async {
        final remote = _Remote({
          null: _page(SyncMode.snapshot, ['1', '2'], 'c1', true),
          'c1': _page(SyncMode.snapshot, ['3'], 'c2', false),
        });
        final cursors = _Cursors();
        final applier = _Applier();

        final result = await SyncEngine(
          remote: remote,
          cursors: cursors,
          applier: applier,
        ).run();

        expect(remote.requested, [null, 'c1']);
        expect(cursors.writes, ['c1', 'c2']);
        expect(applier.applied.keys, ['1', '2', '3']);
        expect(result.pages, 2);
      },
    );

    test('delta pagination resumes from the persisted cursor', () async {
      final remote = _Remote({
        'c2': _page(SyncMode.delta, ['4'], 'c3', true),
        'c3': _page(SyncMode.delta, [], 'c3', false),
      });
      final cursors = _Cursors()..value = 'c2';

      await SyncEngine(
        remote: remote,
        cursors: cursors,
        applier: _Applier(),
      ).run();

      expect(remote.requested, ['c2', 'c3']);
      expect(cursors.value, 'c3');
    });

    test(
      'interrupted apply does not advance the cursor; restart replays safely',
      () async {
        final pages = {
          null: _page(SyncMode.snapshot, ['1'], 'c1', true),
          'c1': _page(SyncMode.snapshot, ['2'], 'c2', false),
        };
        final cursors = _Cursors();
        final applier = _Applier()..failOnPage = 1;

        await expectLater(
          SyncEngine(
            remote: _Remote(pages),
            cursors: cursors,
            applier: applier,
          ).run(),
          throwsStateError,
        );
        expect(cursors.value, 'c1');

        applier.failOnPage = -1;
        await SyncEngine(
          remote: _Remote(pages),
          cursors: cursors,
          applier: applier,
        ).run();
        expect(cursors.value, 'c2');
        expect(applier.applied.keys, ['1', '2']);
      },
    );

    test('replaying an applied page is idempotent', () async {
      final page = _page(SyncMode.delta, ['1', '2'], 'c1', false);
      final applier = _Applier();
      await applier.apply(page);
      await applier.apply(page);
      expect(applier.applied, hasLength(2));
    });
  });
}
