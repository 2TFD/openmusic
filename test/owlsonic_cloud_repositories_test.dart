import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';

import 'support/fake_owlsonic_backend.dart';

const _track = '00000000-0000-0000-0000-000000000001';

Map<String, Object?> _playlist({List<Map<String, Object?>> items = const []}) =>
    {
      'id': 'p1',
      'name': 'Night',
      'created_at': '2026-10-01T00:00:00Z',
      'updated_at': '2026-10-02T00:00:00Z',
      'items': items,
    };

Map<String, Object?> _item(String id, int position) => {
  'id': id,
  'track_id': _track,
  'position': position,
  'title': 'Song',
  'artist_name': null,
  'album_title': null,
  'track_available': true,
};

void main() {
  late FakeCloud cloud;
  setUp(() => cloud = FakeCloud(initialTokens: tokens()));

  group('library', () {
    test('list maps LibraryItem and passes cursor/limit', () async {
      cloud.backend.on(
        'GET /v1/library',
        (_) => FakeReply(200, {
          'items': [libraryItemJson(customTitle: 'Mine')],
          'next_cursor': 'c2',
        }),
      );

      final page = await OwlSonicLibraryRepository(
        cloud.client,
      ).list(cursor: 'c1', limit: 20);

      final request = cloud.backend.requests.single;
      expect(request.query, {'cursor': 'c1', 'limit': 20});
      expect(request.bearer, 'access-1');
      final item = page.items.single;
      expect(item.id, _track);
      expect(item.effectiveTitle, 'Mine');
      expect(item.effectiveArtistName, 'Artist');
      expect(item.analysisStatus, CloudAnalysisStatus.pending);
      expect(item.duration, const Duration(minutes: 3));
      expect(item.customArousal, 0.4);
      expect(item.customValence, isNull);
      expect(page.nextCursor, 'c2');
      expect(page.hasMore, isTrue);
    });

    test('patch distinguishes absent, cleared and set fields', () async {
      cloud.backend.on(
        'PATCH /v1/library/$_track',
        (_) => FakeReply(200, libraryItemJson(favorite: true)),
      );

      final item = await OwlSonicLibraryRepository(cloud.client).patch(
        _track,
        const LibraryItemPatch(
          favorite: PatchValue.set(true),
          customTitle: PatchValue.clear(),
          customValence: PatchValue.set(0.25),
        ),
      );

      expect(cloud.backend.requests.single.json, {
        'favorite': true,
        'custom_title': null,
        'custom_valence': 0.25,
      });
      expect(item.favorite, isTrue);
    });

    test('delete calls DELETE and accepts 204', () async {
      cloud.backend.on(
        'DELETE /v1/library/$_track',
        (_) => const FakeReply(204),
      );

      await OwlSonicLibraryRepository(cloud.client).delete(_track);

      expect(cloud.backend.to('DELETE /v1/library/$_track'), hasLength(1));
    });

    test(
      'ready/failed analysis statuses map; unknown values do not crash',
      () async {
        cloud.backend.on(
          'GET /v1/library/$_track',
          (_) => FakeReply(200, libraryItemJson(analysisStatus: 'ready')),
        );
        final ready = await OwlSonicLibraryRepository(cloud.client).get(_track);
        expect(ready.analysisStatus, CloudAnalysisStatus.ready);
        expect(CloudAnalysisStatus.parse('failed'), CloudAnalysisStatus.failed);
        expect(CloudAnalysisStatus.parse('later'), CloudAnalysisStatus.unknown);
      },
    );

    test('malformed payload becomes invalid_response', () async {
      cloud.backend.on(
        'GET /v1/library/$_track',
        (_) => const FakeReply(200, {'id': 1}),
      );
      await expectLater(
        OwlSonicLibraryRepository(cloud.client).get(_track),
        throwsA(
          isA<OwlSonicApiException>().having(
            (e) => e.kind,
            'kind',
            OwlSonicApiErrorKind.invalidResponse,
          ),
        ),
      );
    });

    test(
      'playback and artwork return signed URLs without leaking them',
      () async {
        cloud.backend.on(
          'POST /v1/library/$_track/playback',
          (_) => const FakeReply(200, {
            'url': 'https://cdn.test/a?sig=secret',
            'expires_at': '2026-10-07T12:05:00Z',
            'expires_in': 300,
          }),
        );
        cloud.backend.on(
          'GET /v1/library/$_track/artwork',
          (_) => const FakeReply(200, {
            'url': 'https://cdn.test/art?sig=secret',
            'expires_at': '2026-10-07T12:05:00Z',
            'expires_in': 300,
          }),
        );
        final repo = OwlSonicLibraryRepository(cloud.client);

        final playback = await repo.playbackUrl(_track);
        final artwork = await repo.artworkUrl(_track);

        expect(playback.url.host, 'cdn.test');
        expect(artwork.url.path, '/art');
        expect(playback.toString(), isNot(contains('secret')));
      },
    );
  });

  group('playlists', () {
    test('create sends client UUID and name', () async {
      cloud.backend.on(
        'POST /v1/playlists',
        (_) => FakeReply(201, _playlist()),
      );

      final playlist = await OwlSonicPlaylistRepository(
        cloud.client,
      ).create(id: 'p1', name: 'Night');

      expect(cloud.backend.requests.single.json, {'id': 'p1', 'name': 'Night'});
      expect(playlist.name, 'Night');
    });

    test('list, get, rename and delete', () async {
      cloud.backend.on(
        'GET /v1/playlists',
        (_) => const FakeReply(200, {
          'items': [
            {
              'id': 'p1',
              'name': 'Night',
              'item_count': 2,
              'created_at': '2026-10-01T00:00:00Z',
              'updated_at': '2026-10-02T00:00:00Z',
            },
          ],
          'next_cursor': null,
        }),
      );
      cloud.backend.on(
        'GET /v1/playlists/p1',
        (_) => FakeReply(200, _playlist(items: [_item('i1', 0)])),
      );
      cloud.backend.on(
        'PATCH /v1/playlists/p1',
        (_) => FakeReply(200, _playlist()),
      );
      cloud.backend.on('DELETE /v1/playlists/p1', (_) => const FakeReply(204));
      final repo = OwlSonicPlaylistRepository(cloud.client);

      final page = await repo.list();
      final detail = await repo.get('p1');
      await repo.rename('p1', 'Late night');
      await repo.delete('p1');

      expect(page.items.single.itemCount, 2);
      expect(page.hasMore, isFalse);
      expect(detail.items.single.trackAvailable, isTrue);
      expect(cloud.backend.to('PATCH /v1/playlists/p1').single.json, {
        'name': 'Late night',
      });
      expect(cloud.backend.to('DELETE /v1/playlists/p1'), hasLength(1));
    });

    test('item add / reorder / remove', () async {
      cloud.backend.on(
        'POST /v1/playlists/p1/items',
        (_) => FakeReply(201, _item('i2', 1)),
      );
      cloud.backend.on(
        'PUT /v1/playlists/p1/items/order',
        (_) =>
            FakeReply(200, _playlist(items: [_item('i2', 0), _item('i1', 1)])),
      );
      cloud.backend.on(
        'DELETE /v1/playlists/p1/items/i1',
        (_) => const FakeReply(204),
      );
      final repo = OwlSonicPlaylistRepository(cloud.client);

      final added = await repo.addItem('p1', itemId: 'i2', trackId: _track);
      final reordered = await repo.reorder('p1', ['i2', 'i1']);
      await repo.removeItem('p1', 'i1');

      expect(cloud.backend.to('POST /v1/playlists/p1/items').single.json, {
        'id': 'i2',
        'track_id': _track,
      });
      expect(added.position, 1);
      expect(cloud.backend.to('PUT /v1/playlists/p1/items/order').single.json, {
        'item_ids': ['i2', 'i1'],
      });
      expect(reordered.items.map((i) => i.id), ['i2', 'i1']);
      expect(
        cloud.backend.to('DELETE /v1/playlists/p1/items/i1'),
        hasLength(1),
      );
    });

    test('add with explicit index sends it', () async {
      cloud.backend.on(
        'POST /v1/playlists/p1/items',
        (_) => FakeReply(201, _item('i3', 0)),
      );
      await OwlSonicPlaylistRepository(
        cloud.client,
      ).addItem('p1', itemId: 'i3', trackId: _track, index: 0);
      expect(cloud.backend.requests.single.json['index'], 0);
    });
  });

  group('history', () {
    test('submit encodes PlayEventIn and list maps HistoryItem', () async {
      cloud.backend.on(
        'POST /v1/history/events',
        (_) => const FakeReply(200, {'accepted': 1, 'duplicates': 0}),
      );
      cloud.backend.on(
        'GET /v1/history',
        (_) => const FakeReply(200, {
          'items': [
            {
              'event_id': 'e1',
              'track_id': _track,
              'played_at': '2026-10-07T11:00:00Z',
              'listened_ms': 1000,
              'title': 'Song',
              'artist_name': null,
              'album_title': null,
            },
          ],
          'next_cursor': null,
        }),
      );
      final repo = OwlSonicHistoryRepository(cloud.client);

      final result = await repo.submit([
        PlayEvent(
          id: 'e1',
          trackId: _track,
          playedAt: fakeNow,
          listenedMs: 1000,
        ),
      ]);
      final page = await repo.list();

      expect(cloud.backend.to('POST /v1/history/events').single.json, {
        'events': [
          {
            'id': 'e1',
            'track_id': _track,
            'played_at': '2026-10-07T12:00:00.000Z',
            'listened_ms': 1000,
          },
        ],
      });
      expect(result.accepted, 1);
      expect(page.items.single.eventId, 'e1');
    });
  });

  group('discover', () {
    test('candidate and analysis mapping', () async {
      cloud.backend.on(
        'GET /v1/discover/candidates',
        (_) => const FakeReply(200, {
          'items': [
            {
              'track_id': 't9',
              'title': 'Other',
              'artist_name': 'B',
              'album_title': null,
              'album_artist': null,
              'track_number': null,
              'disc_number': null,
              'year': null,
              'genres': [],
              'duration_ms': 1000,
              'has_artwork': false,
              'analysis': {
                'embedding': [1, 0.5],
                'embedding_dimension': 2,
                'embedding_model': 'clap',
                'embedding_version': 'v1',
                'analysis_version': 3,
                'valence': 0.1,
                'arousal': -0.2,
                'emotion_version': 'e1',
              },
            },
          ],
          'next_cursor': 'n',
          'has_more': true,
        }),
      );

      final page = await OwlSonicDiscoverRepository(
        cloud.client,
      ).candidates(limit: 50);

      final analysis = page.items.single.analysis;
      expect(analysis.embedding, [1.0, 0.5]);
      expect(analysis.embeddingDimension, 2);
      expect(analysis.analysisVersion, 3);
      expect(analysis.valence, 0.1);
      expect(analysis.arousal, -0.2);
      expect(page.hasMore, isTrue);
      expect(cloud.backend.requests.single.query, {'limit': 50});
    });

    test('add to library returns the LibraryItem', () async {
      cloud.backend.on(
        'POST /v1/discover/t9/add',
        (_) => FakeReply(200, libraryItemJson()),
      );
      final item = await OwlSonicDiscoverRepository(
        cloud.client,
      ).addToLibrary('t9');
      expect(item.analysisStatus, CloudAnalysisStatus.pending);
    });
  });

  group('account', () {
    test('devices expose current flag; revoke and delete account', () async {
      cloud.backend.on(
        'GET /v1/devices',
        (_) => const FakeReply(200, {
          'items': [
            {
              'id': 'd1',
              'platform': 'macos',
              'device_name': null,
              'app_version': null,
              'created_at': '2026-10-01T00:00:00Z',
              'last_seen_at': '2026-10-07T00:00:00Z',
              'current': true,
            },
          ],
        }),
      );
      cloud.backend.on('DELETE /v1/devices/d2', (_) => const FakeReply(204));
      cloud.backend.on(
        'DELETE /v1/me',
        (_) => const FakeReply(202, {'status': 'deletion_pending'}),
      );
      final repo = OwlSonicAccountRepository(cloud.client);

      final devices = await repo.devices();
      await repo.revokeDevice('d2');
      final status = await repo.deleteAccount(password: 'pw');

      expect(devices.single.current, isTrue);
      expect(cloud.backend.to('DELETE /v1/me').single.json, {'password': 'pw'});
      expect(status, 'deletion_pending');
      expect(cloud.store.tokens, isNull);
    });
  });
}
