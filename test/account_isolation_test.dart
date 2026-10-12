import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/auth_token_store.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/core/services/cloud/play_event_queue.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_track_upload_repository.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:path/path.dart' as p;

import 'owlsonic_sync_apply_test.dart' as sync;
import 'support/fake_owlsonic_backend.dart';

const downloaded = '018f2c3a-0000-7000-8000-000000000003';

/// Account A → B → A switching while sync, refresh, import and history flush
/// are in flight, and what survives a sign-out on this device.
void main() {
  late AppDatabase db;
  late CloudLocalStore store;
  late Directory dir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    store = CloudLocalStore(db);
    dir = await Directory.systemTemp.createTemp('owl-isolation');
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<AuthSession> signedIn() async {
    final session = AuthSession(
      store: MemoryTokenStore()..tokens = tokens(),
      now: () => fakeNow,
    );
    await session.restore();
    return session;
  }

  AuthTokens accountB() => tokens(access: 'access-B', refresh: 'refresh-B');

  Future<File> userFile(String name) async {
    final file = File(p.join(dir.path, name));
    await file.writeAsString('audio bytes');
    return file;
  }

  Future<void> insertLocalTrack(String id, String path) => db
      .into(db.trackTable)
      .insert(
        TrackTableCompanion.insert(
          id: id,
          title: 'Local $id',
          sourceType: SourceType.localFile.name,
          sourceUri: path,
          pathToFile: Value(path),
        ),
      );

  Future<void> seedCloudTrack(String id) => store.apply(
    sync.page([
      sync.ev('library.upsert', 2, sync.libraryV2(trackId: id), entity: id),
    ]),
  );

  CloudTrack uploaded(String id) => CloudTrack(
    id: id,
    title: 'Uploaded $id',
    artistName: 'Artist',
    albumTitle: null,
    duration: const Duration(minutes: 3),
    hasArtwork: false,
    addedAt: fakeNow,
  );

  Future<void> devicePlaylist(String id, List<String> trackIds) async {
    await db
        .into(db.playlistTable)
        .insert(
          PlaylistTableCompanion.insert(
            id: id,
            name: 'Device $id',
            createdAt: fakeNow,
          ),
        );
    for (var i = 0; i < trackIds.length; i++) {
      await db
          .into(db.playlistTrackTable)
          .insert(
            PlaylistTrackTableCompanion.insert(
              playlistId: id,
              trackId: trackIds[i],
              position: i,
            ),
          );
    }
  }

  Future<List<String>> playlistTracks(String id) async => [
    for (final row
        in await (db.select(db.playlistTrackTable)
              ..where((t) => t.playlistId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get())
      row.trackId,
  ];

  group('sign-out purge keeps the device library intact', () {
    test(
      'local-only, uploaded, migrated, downloaded and cloud-only tracks',
      () async {
        final localFile = await userFile('local.mp3');
        final importFile = await userFile('import.flac');
        final migratedFile = await userFile('migrated.m4a');

        // Local-only track, never uploaded.
        await insertLocalTrack('local-1', localFile.path);
        // Imported while signed in: a cloud track backed by the user's file.
        await store.insertUploadedTrack(
          uploaded(sync.t1),
          localAudioPath: importFile.path,
        );
        // Local track migrated to the cloud: re-keyed to its cloud id.
        await insertLocalTrack('local-2', migratedFile.path);
        // Cloud-only track (streams) and a cloud track with an offline copy.
        await seedCloudTrack(sync.t2);
        await seedCloudTrack(downloaded);
        await store.attachOfflineAudio(downloaded, 'offline/downloaded.mp3');
        await devicePlaylist('device', [
          'local-1',
          sync.t1,
          'local-2',
          sync.t2,
          downloaded,
        ]);
        await store.adoptMigratedTrack(
          localTrackId: 'local-2',
          uploaded: uploaded('cloud-migrated'),
        );
        // A cloud playlist of the account.
        await store.applyPlaylistDetail(
          CloudPlaylist(
            id: sync.p1,
            name: 'Cloud',
            createdAt: fakeNow,
            updatedAt: fakeNow,
            items: [
              const CloudPlaylistItem(
                id: sync.i1,
                trackId: sync.t2,
                position: 0,
                title: 'Cloud song',
                artistName: null,
                albumTitle: null,
                trackAvailable: true,
              ),
            ],
          ),
        );
        expect(await playlistTracks('device'), [
          'local-1',
          sync.t1,
          'cloud-migrated',
          sync.t2,
          downloaded,
        ]);

        await store.purgeCloudData();

        final tracks = {
          for (final row in await db.select(db.trackTable).get()) row.id: row,
        };
        expect(
          tracks.keys,
          unorderedEquals(['local-1', sync.t1, 'cloud-migrated']),
        );
        for (final id in [sync.t1, 'cloud-migrated']) {
          expect(tracks[id]!.sourceType, SourceType.localFile.name);
          expect(tracks[id]!.sourceUri, tracks[id]!.pathToFile);
        }
        expect(tracks[sync.t1]!.pathToFile, importFile.path);
        expect(tracks['cloud-migrated']!.pathToFile, migratedFile.path);
        // The device-only playlist keeps every track the device still has.
        expect(await playlistTracks('device'), [
          'local-1',
          sync.t1,
          'cloud-migrated',
        ]);
        // No cloud state of the account remains.
        expect(
          await (db.select(
            db.playlistTable,
          )..where((t) => t.id.equals(sync.p1))).get(),
          isEmpty,
        );
        expect(await db.select(db.cloudLibraryItemTable).get(), isEmpty);
        expect(await db.select(db.cloudPlaylistTable).get(), isEmpty);
        expect(await db.select(db.cloudUploadTable).get(), isEmpty);
        // The user's files are untouched.
        for (final file in [localFile, importFile, migratedFile]) {
          expect(await file.exists(), isTrue, reason: file.path);
        }
      },
    );

    test('the same account signing in again re-attaches by id', () async {
      final importFile = await userFile('import.flac');
      await store.insertUploadedTrack(
        uploaded(sync.t1),
        localAudioPath: importFile.path,
      );
      await store.purgeCloudData();
      await seedCloudTrack(sync.t1);

      final row = await (db.select(
        db.trackTable,
      )..where((t) => t.id.equals(sync.t1))).getSingle();
      expect(row.sourceType, SourceType.owlsonic.name);
      expect(row.pathToFile, importFile.path);
      expect(await db.select(db.trackTable).get(), hasLength(1));
    });

    test(
      'purges 40,000+ cloud tracks without exceeding SQLite limits',
      () async {
        const count = 40500;
        await db.batch((batch) {
          batch.insertAll(db.trackTable, [
            for (var i = 0; i < count; i++)
              TrackTableCompanion.insert(
                id: 'cloud-$i',
                title: 'Track $i',
                sourceType: SourceType.owlsonic.name,
                sourceUri: 'owlsonic:track/cloud-$i',
                pathToFile: Value(i.isEven ? null : 'offline/cloud-$i.mp3'),
              ),
            for (var i = 0; i < 1200; i++)
              TrackTableCompanion.insert(
                id: 'own-$i',
                title: 'Own $i',
                sourceType: SourceType.owlsonic.name,
                sourceUri: 'owlsonic:track/own-$i',
                pathToFile: Value('/music/own-$i.mp3'),
              ),
            for (var i = 0; i < 300; i++)
              TrackTableCompanion.insert(
                id: 'local-$i',
                title: 'Local $i',
                sourceType: SourceType.localFile.name,
                sourceUri: '/music/local-$i.mp3',
                pathToFile: Value('/music/local-$i.mp3'),
              ),
          ]);
          batch.insertAll(db.cloudLibraryItemTable, [
            for (var i = 0; i < count; i++)
              CloudLibraryItemTableCompanion.insert(
                trackId: 'cloud-$i',
                canonicalTitle: 'Track $i',
                durationMs: 1000,
                hasArtwork: false,
                analysisStatus: 'ready',
                addedAt: fakeNow,
                updatedAt: fakeNow,
              ),
            for (var i = 0; i < 1200; i++)
              CloudLibraryItemTableCompanion.insert(
                trackId: 'own-$i',
                canonicalTitle: 'Own $i',
                durationMs: 1000,
                hasArtwork: false,
                analysisStatus: 'ready',
                addedAt: fakeNow,
                updatedAt: fakeNow,
              ),
          ]);
        });

        await store.purgeCloudData();

        final remaining = await db.select(db.trackTable).get();
        expect(remaining, hasLength(1500));
        expect(
          remaining.every((row) => row.sourceType == SourceType.localFile.name),
          isTrue,
        );
        expect(await db.select(db.cloudLibraryItemTable).get(), isEmpty);
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test('a small library purges too', () async {
      await seedCloudTrack(sync.t1);
      await store.purgeCloudData();
      expect(await db.select(db.trackTable).get(), isEmpty);
    });
  });

  group('sync coordinator never mixes accounts', () {
    test('a stale /v1/me answer does not tag the new account', () async {
      final session = await signedIn();
      final owner = _Owner();
      final cursors = <String, _Cursors>{};
      final account = _GatedAccount();
      final remote = _Remote(
        sync.page(
          [sync.ev('library.upsert', 2, sync.libraryV2())],
          mode: SyncMode.snapshot,
          next: 'delta-1',
        ),
      );
      final coordinator = CloudSyncCoordinator(
        session: session,
        configured: true,
        account: account,
        remote: remote,
        local: store,
        owner: owner,
        cursorsFor: (id) => cursors.putIfAbsent(id, _Cursors.new),
      );
      addTearDown(coordinator.dispose);

      final pass = coordinator.requestSync();
      await pumpEventQueue();
      expect(account.pending, hasLength(1));
      // A signs out, B signs in while A's /v1/me is still in flight.
      await session.signOut();
      await session.signIn(accountB());
      account.pending.single.complete('user-a');
      await pass;

      expect(owner.value, isNot('user-a'));
      expect(cursors['user-a']?.value, isNull);
      expect(coordinator.verifiedAccountId, isNot('user-a'));

      // B's own pass then completes normally.
      final next = coordinator.requestSync();
      await pumpEventQueue();
      for (final gate in account.pending.where((g) => !g.isCompleted)) {
        gate.complete('user-b');
      }
      await next;
      expect(owner.value, 'user-b');
      expect(cursors['user-b']!.value, 'delta-1');
      expect(coordinator.verifiedAccountId, 'user-b');
    });

    test(
      'a page pulled for A is not applied or committed after a switch',
      () async {
        final session = await signedIn();
        final owner = _Owner();
        final cursors = <String, _Cursors>{};
        final gate = Completer<void>();
        final remote = _Remote(
          sync.page(
            [sync.ev('library.upsert', 2, sync.libraryV2())],
            mode: SyncMode.snapshot,
            next: 'delta-1',
          ),
          gate: gate,
        );
        final coordinator = CloudSyncCoordinator(
          session: session,
          configured: true,
          account: _FixedAccount('user-a'),
          remote: remote,
          local: store,
          owner: owner,
          cursorsFor: (id) => cursors.putIfAbsent(id, _Cursors.new),
        );
        addTearDown(coordinator.dispose);

        final pass = coordinator.requestSync();
        await pumpEventQueue();
        await session.signIn(accountB());
        gate.complete();
        await pass;

        expect(await db.select(db.trackTable).get(), isEmpty);
        expect(cursors['user-a']!.value, isNull);
      },
    );

    test('purge cleanup runs even when the database purge fails', () async {
      final session = await signedIn();
      final owner = _Owner()..value = 'user-a';
      final cursor = _Cursors()..value = 'c1';
      var cleanups = 0;
      final coordinator = CloudSyncCoordinator(
        session: session,
        configured: true,
        account: _FixedAccount('user-a'),
        remote: _Remote(sync.page(const [])),
        local: _FailingPurgeStore(db),
        owner: owner,
        cursorsFor: (_) => cursor,
        afterPurge: [() async => cleanups++],
      );
      addTearDown(coordinator.dispose);
      await coordinator.start();

      await session.signOut();
      await pumpEventQueue();

      expect(cleanups, 1, reason: 'queued plays and caches are still cleared');
      expect(cursor.value, isNull);
      // Rows may remain, so the owner stays: the next sign-in purges again.
      expect(owner.value, 'user-a');
    });
  });

  group('imports stop at sign-out', () {
    test('an upload in flight is cancelled and never resumes for B', () async {
      final session = await signedIn();
      final file = await userFile('song.mp3');
      final uploader = _GatedUploader();
      final uploads = CloudUploadStore(db);
      final service = CloudImportService(
        session: session,
        configured: true,
        uploader: uploader,
        uploads: uploads,
        local: store,
        delay: (_) async {},
      );

      final run = service.importAll([
        CloudImportSource(key: 'k', audioPath: file.path, title: 'Song'),
      ]);
      await pumpEventQueue();
      expect(uploader.calls, 1);

      await session.signOut();
      final result = await run;

      expect(uploader.cancelled, isTrue);
      expect(result['k']!.phase, CloudUploadPhase.failed);
      expect(result['k']!.failureKind, CloudUploadFailureKind.cancelled);
      expect(await uploads.pending(), isEmpty, reason: 'nothing to resume');
      expect(await db.select(db.trackTable).get(), isEmpty);
      expect(await file.exists(), isTrue);

      await session.signIn(accountB());
      await service.resumePending();
      expect(uploader.calls, 1, reason: "A's file is never sent for B");
    });

    test('a result arriving after an account switch is not written', () async {
      final session = await signedIn();
      final file = await userFile('song.mp3');
      final uploader = _GatedUploader(ignoreCancel: true);
      final service = CloudImportService(
        session: session,
        configured: true,
        uploader: uploader,
        uploads: CloudUploadStore(db),
        local: store,
        delay: (_) async {},
      );

      final run = service.importAll([
        CloudImportSource(key: 'k', audioPath: file.path, title: 'Song'),
      ]);
      await pumpEventQueue();
      await session.signIn(accountB());
      uploader.finish(uploaded(sync.t1));
      await run;

      expect(await db.select(db.trackTable).get(), isEmpty);
      expect(await file.exists(), isTrue);
    });

    test('uploads through the API are never sent with B\'s token', () async {
      final cloud = FakeCloud(initialTokens: tokens());
      await cloud.session.restore();
      final gate = Completer<void>();
      cloud.backend.on('POST /v1/tracks', (request) async {
        await gate.future;
        return FakeReply.error(401, 'token_expired');
      });
      cloud.backend.on(
        'POST /v1/auth/refresh',
        (_) => FakeReply(200, credentials(access: 'refreshed-A')),
      );
      final file = await userFile('song.mp3');
      final service = CloudImportService(
        session: cloud.session,
        configured: true,
        uploader: OwlSonicTrackUploadRepository(cloud.client),
        uploads: CloudUploadStore(db),
        local: store,
        delay: (_) async {},
      );

      final run = service.importAll([
        CloudImportSource(key: 'k', audioPath: file.path, title: 'Song'),
      ]);
      await pumpEventQueue(times: 50);
      await cloud.session.signIn(accountB());
      gate.complete();
      await run;

      final bearers = cloud.backend.to('POST /v1/tracks').map((r) => r.bearer);
      expect(bearers, isNotEmpty);
      expect(bearers, everyElement('access-1'));
      expect(cloud.store.tokens!.accessToken, 'access-B');
    });
  });

  group('history queue stays with its account', () {
    test(
      'A → B → A: events flush only under the account that played them',
      () async {
        final cloud = FakeCloud(initialTokens: tokens());
        await cloud.session.restore();
        String? account = 'user-a';
        final gate = Completer<void>();
        var holdFirst = true;
        cloud.backend.on('POST /v1/history/events', (_) async {
          if (holdFirst) {
            holdFirst = false;
            await gate.future;
          }
          return const FakeReply(200, {'accepted': 1, 'duplicates': 0});
        });
        final queue = PlayEventQueue(
          store: _MemoryEvents(),
          history: OwlSonicHistoryRepository(cloud.client),
          session: cloud.session,
          accountId: () => account,
        );

        await queue.record(
          id: 'play-a',
          trackId: sync.t1,
          playedAt: fakeNow,
          listened: const Duration(seconds: 40),
        );
        final flush = queue.flush();
        await pumpEventQueue(times: 50);
        // Switch to B while A's flush is in flight.
        await cloud.session.signOut();
        await cloud.session.signIn(accountB());
        account = null; // B not verified yet
        gate.complete();
        expect(await flush, 0, reason: "A's response is discarded");
        expect((await queue.pending()).single.accountId, 'user-a');

        account = 'user-b';
        await queue.record(
          id: 'play-b',
          trackId: sync.t2,
          playedAt: fakeNow,
          listened: const Duration(seconds: 40),
        );
        expect(await queue.flush(), 1);
        final sent = cloud.backend.to('POST /v1/history/events');
        expect(sent.last.bearer, 'access-B');
        expect(
          (sent.last.json['events'] as List).map((e) => (e as Map)['id']),
          ['play-b'],
        );
        expect((await queue.pending()).map((e) => e.id), ['play-a']);

        // Back to A: A's event is delivered with A's token.
        await cloud.session.signIn(tokens(access: 'access-A2'));
        account = 'user-a';
        expect(await queue.flush(), 1);
        expect(
          cloud.backend.to('POST /v1/history/events').last.bearer,
          'access-A2',
        );
        expect(await queue.pending(), isEmpty);
      },
    );

    test('transient server failures keep events queued', () async {
      final cloud = FakeCloud(initialTokens: tokens());
      await cloud.session.restore();
      var fail = true;
      cloud.backend.on(
        'POST /v1/history/events',
        (_) => fail
            ? FakeReply.error(503, 'SERVICE_UNAVAILABLE', retryable: true)
            : const FakeReply(200, {'accepted': 1, 'duplicates': 0}),
      );
      final queue = PlayEventQueue(
        store: _MemoryEvents(),
        history: OwlSonicHistoryRepository(cloud.client),
        session: cloud.session,
        accountId: () => 'user-a',
      );
      await queue.record(
        trackId: sync.t1,
        playedAt: fakeNow,
        listened: const Duration(seconds: 40),
      );
      expect(await queue.flush(), 0);
      expect(await queue.pending(), hasLength(1));
      fail = false;
      expect(await queue.flush(), 1);
    });

    test('nothing is sent while the account is unknown', () async {
      final cloud = FakeCloud(initialTokens: tokens());
      await cloud.session.restore();
      final queue = PlayEventQueue(
        store: _MemoryEvents(),
        history: OwlSonicHistoryRepository(cloud.client),
        session: cloud.session,
        accountId: () => null,
      );
      await queue.record(
        trackId: sync.t1,
        playedAt: fakeNow,
        listened: const Duration(seconds: 40),
      );
      expect(await queue.flush(), 0);
      expect(cloud.backend.requests, isEmpty);
    });

    test('the stored outbox keeps the account but never sends it', () {
      final event = PlayEvent(
        id: 'e',
        trackId: 't',
        playedAt: fakeNow,
        listenedMs: 1,
        accountId: 'user-a',
      );
      expect(event.toJson().containsKey('account_id'), isFalse);
      expect(
        PlayEvent.fromJson(
          Map<String, dynamic>.from(event.toStoredJson()),
        ).accountId,
        'user-a',
      );
    });
  });
}

class _Owner implements CloudAccountOwnerStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String? accountId) async => value = accountId;
}

class _Cursors implements SyncCursorStore {
  String? value;
  @override
  Future<void> clear() async => value = null;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String cursor) async => value = cursor;
}

class _GatedAccount extends Fake implements CloudAccountRepository {
  final pending = <Completer<String>>[];
  @override
  Future<CloudUser> me() async {
    final gate = Completer<String>();
    pending.add(gate);
    final id = await gate.future;
    return CloudUser(id: id, email: '$id@example.com', createdAt: fakeNow);
  }
}

class _FixedAccount extends Fake implements CloudAccountRepository {
  _FixedAccount(this.id);
  final String id;
  @override
  Future<CloudUser> me() async =>
      CloudUser(id: id, email: '$id@example.com', createdAt: fakeNow);
}

class _Remote implements CloudSyncRepository {
  _Remote(this.page, {this.gate});
  final SyncPage page;
  final Completer<void>? gate;

  @override
  Future<SyncPage> pull({String? cursor, int? limit}) async {
    await gate?.future;
    return page;
  }
}

class _FailingPurgeStore extends CloudLocalStore {
  _FailingPurgeStore(super.db);
  @override
  Future<void> purgeCloudData() async => throw StateError('disk I/O error');
}

class _GatedUploader implements CloudTrackUploadRepository {
  _GatedUploader({this.ignoreCancel = false});
  final bool ignoreCancel;
  var calls = 0;
  var cancelled = false;
  final _result = Completer<CloudTrack>();

  void finish(CloudTrack track) => _result.complete(track);

  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) {
    calls++;
    if (ignoreCancel) return _result.future;
    final aborted = Completer<CloudTrack>();
    cancelled?.then((_) {
      this.cancelled = true;
      if (!aborted.isCompleted) {
        aborted.completeError(
          const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.cancelled,
            code: 'cancelled',
            message: 'Request cancelled',
            retryable: false,
          ),
        );
      }
    });
    return aborted.future;
  }
}

class _MemoryEvents implements PlayEventStore {
  List<PlayEvent> events = [];
  @override
  Future<List<PlayEvent>> load() async => List.of(events);
  @override
  Future<void> save(List<PlayEvent> next) async => events = List.of(next);
}
