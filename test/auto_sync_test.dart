import 'dart:async';

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_service.dart';
import 'package:owlsonic/core/services/cloud/auto_sync_settings.dart';
import 'package:owlsonic/core/services/cloud/cloud_playlist_sync.dart';
import 'package:owlsonic/core/services/cloud/local_library_migration.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_aware_repositories.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/domain/repositories/playlist_repository.dart';

import 'support/fake_owlsonic_backend.dart';

const _p1 = '0190a000-0000-7000-8000-000000000001';

/// In-memory OwlSonic playlists.
class _Remote implements CloudPlaylistRepository {
  final playlists = <String, List<String>>{}; // id -> track ids in order
  final names = <String, String>{};
  final calls = <String>[];
  Object? failWith;
  var _item = 0;
  final _itemIds = <String, List<String>>{};

  CloudPlaylist _detail(String id) => CloudPlaylist(
    id: id,
    name: names[id]!,
    createdAt: fakeNow,
    updatedAt: fakeNow,
    items: [
      for (var i = 0; i < playlists[id]!.length; i++)
        CloudPlaylistItem(
          id: _itemIds[id]![i],
          trackId: playlists[id]![i],
          position: i,
          title: 't',
          artistName: null,
          albumTitle: null,
          trackAvailable: true,
        ),
    ],
  );

  void _maybeFail() {
    if (failWith != null) throw failWith!;
  }

  @override
  Future<CloudPlaylist> create({
    required String id,
    required String name,
  }) async {
    calls.add('create $id');
    _maybeFail();
    names[id] = name;
    playlists[id] = [];
    _itemIds[id] = [];
    return _detail(id);
  }

  @override
  Future<CloudPlaylist> get(String playlistId) async {
    _maybeFail();
    if (!playlists.containsKey(playlistId)) {
      throw const OwlSonicApiException(
        kind: OwlSonicApiErrorKind.server,
        code: 'PLAYLIST_NOT_FOUND',
        message: 'missing',
        retryable: false,
        statusCode: 404,
      );
    }
    return _detail(playlistId);
  }

  @override
  Future<CloudPlaylistItem> addItem(
    String playlistId, {
    required String itemId,
    required String trackId,
    int? index,
  }) async {
    calls.add('add $trackId');
    _maybeFail();
    playlists[playlistId]!.add(trackId);
    _itemIds[playlistId]!.add('item-${_item++}');
    return _detail(playlistId).items.last;
  }

  @override
  Future<void> removeItem(String playlistId, String itemId) async {
    calls.add('remove $itemId');
  }

  @override
  Future<CloudPage<CloudPlaylistSummary>> list({String? cursor, int? limit}) =>
      throw UnimplementedError();
  @override
  Future<CloudPlaylist> rename(String playlistId, String name) =>
      throw UnimplementedError();
  @override
  Future<void> delete(String playlistId) => throw UnimplementedError();
  @override
  Future<CloudPlaylist> reorder(String playlistId, List<String> itemIds) =>
      throw UnimplementedError();
}

void main() {
  late AppDatabase db;
  late CloudLocalStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = CloudLocalStore(db);
  });
  tearDown(() => db.close());

  Future<void> track(String id, {required bool cloud}) => db
      .into(db.trackTable)
      .insert(
        TrackTableCompanion.insert(
          id: id,
          title: 'Song $id',
          sourceType: cloud ? 'owlsonic' : 'localFile',
          sourceUri: '/$id.mp3',
          pathToFile: Value('/$id.mp3'),
        ),
      );

  Future<void> playlist(String id, List<String> tracks) async {
    await db
        .into(db.playlistTable)
        .insert(
          PlaylistTableCompanion.insert(
            id: id,
            name: 'Mix',
            createdAt: fakeNow,
          ),
        );
    for (var i = 0; i < tracks.length; i++) {
      await db
          .into(db.playlistTrackTable)
          .insert(
            PlaylistTrackTableCompanion.insert(
              playlistId: id,
              trackId: tracks[i],
              position: i,
            ),
          );
    }
  }

  Future<List<String>> shown(String id) async =>
      (await (db.select(db.playlistTrackTable)
                ..where((t) => t.playlistId.equals(id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get())
          .map((r) => r.trackId)
          .toList();

  group('auto-sync settings and policy', () {
    test('on by default, anywhere', () async {
      final policy = AutoSyncPolicy(
        settings: AutoSyncSettings(),
        network: _Network(unmetered: false),
      );
      expect(policy.prefs.enabled, isTrue);
      expect(policy.prefs.wifiOnly, isFalse);
      expect(await policy.allowsUploadNow(), isTrue);
    });

    test('switched off, nothing is allowed', () async {
      final settings = AutoSyncSettings();
      settings.current.value = const AutoSyncPrefs(enabled: false);
      final policy = AutoSyncPolicy(
        settings: settings,
        network: _Network(unmetered: true),
      );
      expect(await policy.allowsUploadNow(), isFalse);
    });

    test('Wi-Fi only follows the connection', () async {
      final settings = AutoSyncSettings();
      settings.current.value = const AutoSyncPrefs(wifiOnly: true);
      final network = _Network(unmetered: false);
      final policy = AutoSyncPolicy(settings: settings, network: network);
      expect(await policy.allowsUploadNow(), isFalse);
      network.unmetered = true;
      expect(await policy.allowsUploadNow(), isTrue);
    });
  });

  group('playlist view keeps songs the server does not have', () {
    test('a synced list does not drop an unsynced local song', () async {
      await track('c1', cloud: true);
      await track('c2', cloud: true);
      await track('local', cloud: false);
      await playlist(_p1, ['c1', 'local', 'c2']);
      await store.applyPlaylistDetail(
        _detail(_p1, ['c1', 'c2']), // the server has two of the three
      );

      expect(await shown(_p1), ['c1', 'local', 'c2'], reason: 'order kept');
      expect(await store.unsyncedPlaylistTracks(_p1), ['local']);
    });

    test('a song removed on another device does leave this one', () async {
      await track('c1', cloud: true);
      await track('c2', cloud: true);
      await playlist(_p1, ['c1', 'c2']);
      await store.applyPlaylistDetail(_detail(_p1, ['c1', 'c2']));
      expect(await store.unsyncedPlaylistTracks(_p1), isEmpty);

      await store.applyPlaylistDetail(_detail(_p1, ['c1'])); // c2 removed

      expect(await shown(_p1), ['c1']);
    });

    test('device-only playlists report nothing unsynced', () async {
      await track('local', cloud: false);
      await playlist(_p1, ['local']);
      expect(await store.unsyncedPlaylistTracks(_p1), isEmpty);
      expect((await store.localOnlyPlaylists()).single.id, _p1);
    });
  });

  group('playlist sync', () {
    late _Remote remote;
    late CloudPlaylistSync sync;

    setUp(() {
      remote = _Remote();
      sync = CloudPlaylistSync(store: store, remote: remote);
    });

    test('a device playlist is sent without the songs that are not in the '
        'cloud, which stay here marked not synced', () async {
      await track('c1', cloud: true);
      await track('local', cloud: false);
      await track('c2', cloud: true);
      await playlist(_p1, ['c1', 'local', 'c2']);

      await sync.reconcile();

      expect(remote.playlists[_p1], ['c1', 'c2'], reason: 'order kept');
      expect(remote.names[_p1], 'Mix');
      expect(await shown(_p1), ['c1', 'local', 'c2']);
      expect(await store.unsyncedPlaylistTracks(_p1), ['local']);
      expect(await store.isCloudPlaylist(_p1), isTrue);
      expect(await store.localOnlyPlaylists(), isEmpty);
    });

    test('running again changes nothing', () async {
      await track('c1', cloud: true);
      await playlist(_p1, ['c1']);
      await sync.reconcile();
      remote.calls.clear();

      await sync.reconcile();

      expect(remote.calls, isEmpty);
    });

    test('a song joins the server playlist once it is uploaded', () async {
      await track('local', cloud: false);
      await playlist(_p1, ['local']);
      await sync.reconcile();
      expect(remote.playlists[_p1], isEmpty);

      // The upload re-keys the local song to its cloud id (see
      // adoptMigratedTrack): the playlist row follows it.
      await track('cloud-1', cloud: true);
      await (db.update(db.playlistTrackTable)
            ..where((t) => t.trackId.equals('local')))
          .write(const PlaylistTrackTableCompanion(trackId: Value('cloud-1')));
      await (db.delete(db.trackTable)..where((t) => t.id.equals('local'))).go();
      expect(await store.unsyncedPlaylistTracks(_p1), ['cloud-1']);

      await sync.reconcile();

      expect(remote.playlists[_p1], ['cloud-1']);
      expect(await store.unsyncedPlaylistTracks(_p1), isEmpty);
      expect(await shown(_p1), ['cloud-1']);
    });

    test('an interrupted first attempt is finished, not duplicated', () async {
      await track('c1', cloud: true);
      await track('c2', cloud: true);
      await playlist(_p1, ['c1', 'c2']);
      // A previous pass created the playlist and added one song, then died.
      await remote.create(id: _p1, name: 'Mix');
      await remote.addItem(_p1, itemId: 'x', trackId: 'c1');
      remote.calls.clear();

      await sync.reconcile();

      expect(remote.calls, ['add c2'], reason: 'no second create, no repeat');
      expect(remote.playlists[_p1], ['c1', 'c2']);
    });

    test(
      'playlists with ids the server cannot accept stay on the device',
      () async {
        await track('c1', cloud: true);
        await playlist('legacy-id', ['c1']);
        await sync.reconcile();
        expect(remote.calls, isEmpty);
        expect(await store.isCloudPlaylist('legacy-id'), isFalse);
      },
    );

    test('no connection stops the pass and keeps everything', () async {
      await track('c1', cloud: true);
      await playlist(_p1, ['c1']);
      remote.failWith = const OwlSonicApiException(
        kind: OwlSonicApiErrorKind.network,
        code: 'network_unavailable',
        message: 'offline',
        retryable: true,
      );

      await expectLater(sync.reconcile(), throwsA(isA<OwlSonicApiException>()));

      expect(await store.isCloudPlaylist(_p1), isFalse);
      expect(await shown(_p1), ['c1']);
    });
  });

  group('cloud-aware playlist actions', () {
    late _Remote remote;
    late CloudAwarePlaylistRepository repo;
    late _LocalPlaylists local;
    var syncRequests = 0;
    var autoSync = true;

    setUp(() {
      remote = _Remote();
      local = _LocalPlaylists(db);
      syncRequests = 0;
      autoSync = true;
      repo = CloudAwarePlaylistRepository(
        local: local,
        remote: remote,
        cloud: CloudMutationContext(
          store: store,
          isEnabled: () => true,
          requestSync: () => syncRequests++,
          autoSyncEnabled: () => autoSync,
        ),
      );
    });

    Future<void> cloudPlaylistWith(List<String> cloudTracks) async {
      for (final id in cloudTracks) {
        await track(id, cloud: true);
      }
      await playlist(_p1, cloudTracks);
      await _seedRemote(remote, _p1, cloudTracks);
      await store.applyPlaylistDetail(await remote.get(_p1));
    }

    test('a song that is only on this device can be added, and is marked '
        'not synced', () async {
      await cloudPlaylistWith(['c1']);
      await track('local', cloud: false);

      await repo.addTrackToPlaylist(_p1, 'local');

      expect(await shown(_p1), ['c1', 'local']);
      expect(remote.calls, isEmpty, reason: 'nothing is sent for it');
      expect(syncRequests, 1, reason: 'auto-sync is asked to upload it');
      final loaded = (await repo.getPlaylistById(_p1))!;
      expect(loaded.unsyncedTrackIds, {'local'});
    });

    test(
      'an unsynced song can be removed without touching the server',
      () async {
        await cloudPlaylistWith(['c1']);
        await track('local', cloud: false);
        await repo.addTrackToPlaylist(_p1, 'local');
        final revision = (await repo.getPlaylistById(_p1))!.revision;

        await repo.removeTrackFromPlaylist(
          _p1,
          'local',
          expectedRevision: revision,
        );

        expect(await shown(_p1), ['c1']);
        expect(remote.calls, isEmpty);
      },
    );

    test('a new playlist with device songs stays on the device and asks '
        'auto-sync to take it', () async {
      await track('local', cloud: false);

      await repo.createPlaylist(
        Playlist(
          id: _p1,
          name: 'Mix',
          trackIds: const ['local'],
          createdAt: fakeNow,
        ),
      );

      expect(local.created, [_p1]);
      expect(remote.calls, isEmpty);
      expect(syncRequests, 1);
    });

    test('with auto-sync off nothing new starts in the cloud', () async {
      autoSync = false;
      await track('c1', cloud: true);

      await repo.createPlaylist(
        Playlist(
          id: _p1,
          name: 'Mix',
          trackIds: const ['c1'],
          createdAt: fakeNow,
        ),
      );

      expect(local.created, [_p1]);
      expect(remote.calls, isEmpty);
    });
  });

  group('auto-sync service', () {
    late AuthSession session;
    late AutoSyncSettings settings;
    late _Network network;
    late _Tracks tracks;
    late _Playlists playlists;
    late AutoSyncService service;

    Future<void> build({bool signedIn = true}) async {
      session = AuthSession(store: MemoryTokenStore());
      await session.restore();
      if (signedIn) await session.signIn(tokens());
      settings = AutoSyncSettings();
      network = _Network(unmetered: true);
      tracks = _Tracks();
      playlists = _Playlists(tracks.order);
      service = AutoSyncService(
        session: session,
        policy: AutoSyncPolicy(settings: settings, network: network),
        tracks: tracks,
        playlists: playlists,
        configured: true,
      );
    }

    test('uploads tracks first, then sends playlists', () async {
      await build();
      await service.run();
      expect(tracks.order, ['tracks', 'playlists']);
    });

    test('does nothing when switched off or signed out', () async {
      await build();
      settings.current.value = const AutoSyncPrefs(enabled: false);
      await service.run();
      expect(tracks.order, isEmpty);

      await build(signedIn: false);
      await service.run();
      expect(tracks.order, isEmpty);
    });

    test(
      'Wi-Fi only waits for Wi-Fi, then runs when the network changes',
      () async {
        await build();
        settings.current.value = const AutoSyncPrefs(wifiOnly: true);
        network.unmetered = false;
        service.start();
        addTearDown(service.dispose);

        await service.run();
        expect(tracks.order, isEmpty);

        network.unmetered = true;
        network.notify();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(tracks.order, ['tracks', 'playlists']);
      },
    );

    test('turning auto-sync on starts a pass', () async {
      await build();
      settings.current.value = const AutoSyncPrefs(enabled: false);
      service.start();
      addTearDown(service.dispose);

      settings.current.value = const AutoSyncPrefs();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(tracks.order, ['tracks', 'playlists']);
    });

    test('a request during a pass runs one more, never two at once', () async {
      await build();
      tracks.gate = Completer<void>();
      final first = service.run();
      await Future<void>.delayed(Duration.zero);
      final second = service.run();
      await Future<void>.delayed(Duration.zero);
      expect(tracks.concurrent, 1);
      tracks.gate!.complete();
      await Future.wait([first, second]);
      expect(tracks.order.where((e) => e == 'tracks'), hasLength(2));
      expect(tracks.maxConcurrent, 1);
    });

    test('a failing pass is retried by the next one', () async {
      await build();
      playlists.fail = true;
      await service.run();
      playlists.fail = false;
      tracks.order.clear();
      await service.run();
      expect(tracks.order, ['tracks', 'playlists']);
    });

    test('syncing one song uploads it even with auto-sync off', () async {
      await build();
      settings.current.value = const AutoSyncPrefs(enabled: false);
      await service.syncTrack('t1');
      expect(tracks.uploadedNow, ['t1']);
      expect(playlists.addedUploaded, 1);
    });
  });
}

Future<void> _seedRemote(_Remote remote, String id, List<String> tracks) async {
  await remote.create(id: id, name: 'Mix');
  for (final t in tracks) {
    await remote.addItem(id, itemId: 'i-$t', trackId: t);
  }
  remote.calls.clear();
}

CloudPlaylist _detail(String id, List<String> tracks) => CloudPlaylist(
  id: id,
  name: 'Mix',
  createdAt: fakeNow,
  updatedAt: fakeNow,
  items: [
    for (var i = 0; i < tracks.length; i++)
      CloudPlaylistItem(
        id: 'item-${tracks[i]}',
        trackId: tracks[i],
        position: i,
        title: 't',
        artistName: null,
        albumTitle: null,
        trackAvailable: true,
      ),
  ],
);

class _Network implements NetworkProbe {
  _Network({required this.unmetered});
  bool unmetered;
  final _changes = StreamController<void>.broadcast();

  void notify() => _changes.add(null);

  @override
  Future<bool> isUnmetered() async => unmetered;

  @override
  Stream<void> get changes => _changes.stream;
}

class _Tracks extends Fake implements LocalLibraryMigration {
  final order = <String>[];
  final uploadedNow = <String>[];
  Completer<void>? gate;
  int concurrent = 0;
  int maxConcurrent = 0;

  @override
  bool get available => true;

  @override
  Future<void> uploadWaiting() async {
    concurrent++;
    maxConcurrent = concurrent > maxConcurrent ? concurrent : maxConcurrent;
    order.add('tracks');
    final wait = gate;
    if (wait != null && !wait.isCompleted) await wait.future;
    concurrent--;
  }

  @override
  Future<void> uploadNow(String trackId) async => uploadedNow.add(trackId);
}

class _Playlists extends Fake implements CloudPlaylistSync {
  _Playlists(this.order);
  final List<String> order;
  bool fail = false;
  int addedUploaded = 0;

  @override
  Future<void> reconcile() async {
    if (fail) throw StateError('offline');
    order.add('playlists');
  }

  @override
  Future<void> addUploadedTracks() async => addedUploaded++;
}

/// Local playlist storage that records what it was asked to create.
class _LocalPlaylists implements PlaylistRepository {
  _LocalPlaylists(this.db);
  final AppDatabase db;
  final created = <String>[];

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    created.add(playlist.id);
    await db
        .into(db.playlistTable)
        .insert(
          PlaylistTableCompanion.insert(
            id: playlist.id,
            name: playlist.name,
            createdAt: playlist.createdAt,
          ),
        );
  }

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final count = (await (db.select(
      db.playlistTrackTable,
    )..where((t) => t.playlistId.equals(playlistId))).get()).length;
    await db
        .into(db.playlistTrackTable)
        .insert(
          PlaylistTrackTableCompanion.insert(
            playlistId: playlistId,
            trackId: trackId,
            position: count,
          ),
        );
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId, {
    required int expectedRevision,
  }) =>
      (db.delete(db.playlistTrackTable)..where(
            (t) => t.playlistId.equals(playlistId) & t.trackId.equals(trackId),
          ))
          .go();

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final row = await (db.select(
      db.playlistTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final tracks =
        await (db.select(db.playlistTrackTable)
              ..where((t) => t.playlistId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return Playlist(
      id: id,
      name: row.name,
      trackIds: [for (final t in tracks) t.trackId],
      createdAt: row.createdAt,
      revision: row.revision,
    );
  }

  @override
  Stream<Playlist?> watchPlaylistById(String id) =>
      Stream.fromFuture(getPlaylistById(id));

  @override
  Future<void> deletePlaylist(String playlistId) => throw UnimplementedError();
  @override
  Future<void> reorderTracks(
    String playlistId,
    List<String> trackIds, {
    required int expectedRevision,
  }) => throw UnimplementedError();
  @override
  Future<void> updateMetadata(Playlist playlist) => throw UnimplementedError();
  @override
  Stream<List<PlaylistSummary>> watchPlaylistSummaries() =>
      throw UnimplementedError();
}
