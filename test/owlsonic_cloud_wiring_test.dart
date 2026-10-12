import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/infrastructure/mappers/track_audio_mapper.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/audio_player/cloud_stream_audio_source.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/core/services/cloud/play_event_queue.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/listening_summary/drift/listening_summary_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:owlsonic/layers/data/repositories/cloud_aware_repositories.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/data/repositories/listening_summary_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_duplicate_lookup_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_repository_impl.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/entities/import_candidate.dart';
import 'package:owlsonic/layers/domain/entities/listening_summary.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';
import 'package:owlsonic/layers/domain/repositories/local_file_scanner.dart';
import 'package:owlsonic/layers/domain/repositories/local_track_picker.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/pick_local_tracks_use_case.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_music/import_music_cubit.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';
import 'package:owlsonic/layers/domain/repositories/track_removal_repository.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_track_item_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/scan_local_import_use_case.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_workspace/import_workspace_cubit.dart';
import 'package:path/path.dart' as p;

import 'owlsonic_sync_apply_test.dart' as sync;
import 'support/fake_owlsonic_backend.dart';

void main() {
  late AppDatabase db;
  late CloudLocalStore store;
  late Directory dir;
  var syncRequests = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    store = CloudLocalStore(db);
    dir = await Directory.systemTemp.createTemp('owl-wiring');
    syncRequests = 0;
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  CloudMutationContext context({bool enabled = true}) => CloudMutationContext(
    store: store,
    isEnabled: () => enabled,
    requestSync: () => syncRequests++,
  );

  Future<void> seedCloudTrack(String id) => store.apply(
    sync.page([
      sync.ev('library.upsert', 2, sync.libraryV2(trackId: id), entity: id),
    ]),
  );

  Future<AuthSession> signedIn() async {
    final session = AuthSession(
      store: MemoryTokenStore()..tokens = tokens(),
      now: () => fakeNow,
    );
    await session.restore();
    return session;
  }

  test('successful cloud import from the review appears in Library', () async {
    final file = File(p.join(dir.path, 'song.mp3'))..writeAsStringSync('x');
    final local = TrackDriftLocalSource(db);
    final tracks = TrackRepositoryImpl(localDataSource: local);
    var localImports = 0;
    final cubit = ImportWorkspaceCubit(
      scan: ScanLocalImportUseCase(
        scanner: _Scanner(),
        identity: const Sha256TrackContentIdentityService(),
        duplicates: TrackDuplicateLookupImpl(
          database: db,
          trackLocalDataSource: local,
        ),
        tracks: tracks,
      ),
      importItem: ImportLocalTrackItemUseCase((_) async {
        localImports++;
        throw StateError('local import must not run while signed in');
      }),
      cloudImport: CloudImportService(
        session: await signedIn(),
        configured: true,
        uploader: _Uploader(),
        uploads: CloudUploadStore(db),
        local: store,
        onLibraryChanged: () => syncRequests++,
        delay: (_) async {},
      ),
    );
    addTearDown(cubit.close);

    await cubit.addPaths([file.path]);
    await cubit.startImport();

    expect(cubit.state.items.single.status, ImportItemStatus.imported);
    expect(localImports, 0);
    final library = await tracks.getTracks();
    expect(library.single.title, 'song');
    expect(library.single.isCloudTrack, isTrue);
    expect(syncRequests, 1);
  });

  test('cloud import failure keeps the backend code for the row', () async {
    final file = File(p.join(dir.path, 'full.mp3'))..writeAsStringSync('x');
    final local = TrackDriftLocalSource(db);
    final cubit = ImportWorkspaceCubit(
      scan: ScanLocalImportUseCase(
        scanner: _Scanner(),
        identity: const Sha256TrackContentIdentityService(),
        duplicates: TrackDuplicateLookupImpl(
          database: db,
          trackLocalDataSource: local,
        ),
        tracks: TrackRepositoryImpl(localDataSource: local),
      ),
      importItem: ImportLocalTrackItemUseCase((_) => throw StateError('no')),
      cloudImport: CloudImportService(
        session: await signedIn(),
        configured: true,
        uploader: _Uploader(
          error: const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.server,
            statusCode: 403,
            code: 'STORAGE_QUOTA_EXCEEDED',
            message: 'quota',
            retryable: false,
          ),
        ),
        uploads: CloudUploadStore(db),
        local: store,
        delay: (_) async {},
      ),
    );
    addTearDown(cubit.close);

    await cubit.addPaths([file.path]);
    await cubit.startImport();

    final item = cubit.state.items.single;
    expect(item.status, ImportItemStatus.failed);
    final failure = item.failure as CloudUploadFailure;
    expect(failure.code, 'STORAGE_QUOTA_EXCEEDED');
    expect(failure.toLocaleKey(), 'cloud.upload.quotaExceeded');
  });

  group('playlists reach the backend and converge through sync', () {
    late _PlaylistRemote remote;
    late CloudAwarePlaylistRepository repo;
    const playlistId = '018f2c3a-0000-7000-8000-0000000000a9';

    setUp(() async {
      remote = _PlaylistRemote();
      repo = CloudAwarePlaylistRepository(
        local: PlaylistRepositoryImpl(
          localDataSource: PlaylistDriftLocalSource(db),
        ),
        remote: remote,
        cloud: context(),
        newItemId: () => _itemId(remote.items.length + 1),
      );
      await seedCloudTrack(sync.t1);
      await seedCloudTrack(sync.t2);
    });

    test('create / add / reorder / remove / rename / delete', () async {
      await repo.createPlaylist(
        Playlist(
          id: playlistId,
          name: 'Night',
          trackIds: const [],
          createdAt: fakeNow,
        ),
      );
      await repo.addTrackToPlaylist(playlistId, sync.t1);
      await repo.addTrackToPlaylist(playlistId, sync.t2);
      var local = await repo.getPlaylistById(playlistId);
      expect(local!.trackIds, [sync.t1, sync.t2]);

      await repo.reorderTracks(playlistId, [
        sync.t2,
        sync.t1,
      ], expectedRevision: local.revision);
      expect(remote.calls, contains('reorder ${_itemId(2)},${_itemId(1)}'));
      local = await repo.getPlaylistById(playlistId);
      expect(local!.trackIds, [sync.t2, sync.t1]);

      await repo.removeTrackFromPlaylist(
        playlistId,
        sync.t2,
        expectedRevision: local.revision,
      );
      await repo.updateMetadata(local.copyWith(name: 'Late'));
      local = await repo.getPlaylistById(playlistId);
      expect(local!.trackIds, [sync.t1]);
      expect(local.name, 'Late');

      // The same state arriving later through sync does not duplicate rows.
      await store.apply(
        sync.page([
          sync.ev('playlist.items', 1, {
            'playlist_id': playlistId,
            'updated_at': '2026-10-07T12:00:00Z',
            'items': [
              {
                'item_id': remote.items.keys.first,
                'track_id': sync.t1,
                'position': 0,
              },
            ],
          }),
        ]),
      );
      expect((await repo.getPlaylistById(playlistId))!.trackIds, [sync.t1]);

      await repo.deletePlaylist(playlistId);
      expect(await repo.getPlaylistById(playlistId), isNull);
      expect(remote.calls, [
        'create Night',
        'add ${_itemId(1)} ${sync.t1}',
        'add ${_itemId(2)} ${sync.t2}',
        'reorder ${_itemId(2)},${_itemId(1)}',
        'remove ${_itemId(2)}',
        'rename Late',
        'delete',
      ]);
      expect(syncRequests, greaterThan(0));
    });

    Future<void> insertLocal(String id) => db
        .into(db.trackTable)
        .insert(
          TrackTableCompanion.insert(
            id: id,
            title: 'L',
            sourceType: 'localFile',
            sourceUri: '/$id.mp3',
          ),
        );

    test('cloud tracks create a cloud playlist', () async {
      await repo.createPlaylist(
        Playlist(
          id: playlistId,
          name: 'Cloud',
          trackIds: const [sync.t1, sync.t2],
          createdAt: fakeNow,
        ),
      );
      expect(remote.calls.first, 'create Cloud');
      expect(remote.items.values, [sync.t1, sync.t2]);
      expect(await store.isCloudPlaylist(playlistId), isTrue);
    });

    test('local-only tracks never create a remote playlist', () async {
      await insertLocal('local01');
      await repo.createPlaylist(
        Playlist(
          id: playlistId,
          name: 'Mixed',
          trackIds: const [sync.t1, 'local01'],
          createdAt: fakeNow,
        ),
      );
      // Validation happens first: the backend was never called.
      expect(remote.calls, isEmpty);
      expect(await store.isCloudPlaylist(playlistId), isFalse);
      // The playlist stays usable on this device.
      final local = await repo.getPlaylistById(playlistId);
      expect(local!.trackIds, [sync.t1, 'local01']);
      await repo.addTrackToPlaylist(playlistId, sync.t2);
      expect(remote.calls, isEmpty);
      expect((await repo.getPlaylistById(playlistId))!.trackIds, [
        sync.t1,
        'local01',
        sync.t2,
      ]);
    });

    test('a failure while building a cloud playlist is rolled back', () async {
      remote.failAddItem = true;
      await expectLater(
        repo.createPlaylist(
          Playlist(
            id: playlistId,
            name: 'Flaky',
            trackIds: const [sync.t1],
            createdAt: fakeNow,
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(remote.calls, contains('delete'));
      expect(await repo.getPlaylistById(playlistId), isNull);
    });

    test('a local-only track can be put in a cloud playlist; the server is not '
        'asked and the song is marked not synced', () async {
      await insertLocal('local02');
      await repo.createPlaylist(
        Playlist(
          id: playlistId,
          name: 'Cloud',
          trackIds: const [],
          createdAt: fakeNow,
        ),
      );
      remote.calls.clear();

      await repo.addTrackToPlaylist(playlistId, 'local02');

      expect(remote.calls, isEmpty);
      expect(remote.items, isEmpty);
      final playlist = (await repo.getPlaylistById(playlistId))!;
      expect(playlist.trackIds, ['local02']);
      expect(playlist.unsyncedTrackIds, {'local02'});
    });
  });

  group('mobile file import', () {
    Future<(ImportMusicCubit, List<String>)> mobile({
      required bool signedInUser,
      _RecordingUploader? uploader,
      bool configured = true,
    }) async {
      final localImports = <String>[];
      final session = signedInUser
          ? await signedIn()
          : (AuthSession(store: MemoryTokenStore())..restore());
      await session.restore();
      final cubit = ImportMusicCubit(
        pickLocalTracks: PickLocalTracksUseCase(_Picker(const [])),
        importLocalTracks: ImportLocalTracksUseCase((input) async {
          localImports.add(input.toString());
        }),
        cloudImport: CloudImportService(
          session: session,
          configured: configured,
          uploader: uploader ?? _RecordingUploader(),
          uploads: CloudUploadStore(db),
          local: store,
          onLibraryChanged: () => syncRequests++,
          delay: (_) async {},
        ),
        identity: const Sha256TrackContentIdentityService(),
      );
      addTearDown(cubit.close);
      return (cubit, localImports);
    }

    TrackPreview preview(String name) {
      final file = File(p.join(dir.path, '$name.mp3'))..writeAsStringSync(name);
      return TrackPreview(
        id: 'local-$name',
        title: name,
        artist: 'Artist',
        source: SourceType.localFile,
        originalUrl: file.path,
        urlFile: file.path,
      );
    }

    test('signed out stays local-only and is marked as not synced', () async {
      final uploader = _RecordingUploader();
      final (cubit, localImports) = await mobile(
        signedInUser: false,
        uploader: uploader,
      );
      await cubit.importLocalTracks([preview('a')]);

      final result = (cubit.state as LocalTracksImported).result;
      expect(localImports, hasLength(1));
      expect(uploader.requests, isEmpty);
      expect(result.added, 1);
      expect(result.localOnly, isTrue);
    });

    test('unconfigured backend is local-only without a sync hint', () async {
      final (cubit, _) = await mobile(signedInUser: false, configured: false);
      await cubit.importLocalTracks([preview('a')]);
      expect((cubit.state as LocalTracksImported).result.localOnly, isFalse);
    });

    test('signed in uploads through CloudImportService', () async {
      final uploader = _RecordingUploader();
      final (cubit, localImports) = await mobile(
        signedInUser: true,
        uploader: uploader,
      );
      await cubit.importLocalTracks([preview('song')]);

      final result = (cubit.state as LocalTracksImported).result;
      expect(localImports, isEmpty);
      expect(result.added, 1);
      expect(result.failed, 0);
      expect(result.localOnly, isFalse);

      final request = uploader.requests.single;
      expect(isUuidV7(request.trackId), isTrue);
      expect(request.idempotencyKey, startsWith('owlsonic-upload:'));

      // 201 → visible at once, analysis pending, sync requested.
      final library = await TrackRepositoryImpl(
        localDataSource: TrackDriftLocalSource(db),
      ).getTracks();
      expect(library.single.id, request.trackId);
      expect(library.single.isCloudTrack, isTrue);
      final item = await (db.select(
        db.cloudLibraryItemTable,
      )..where((t) => t.trackId.equals(request.trackId))).getSingle();
      expect(item.analysisStatus, CloudAnalysisStatus.pending.name);
      expect(syncRequests, 1);
    });

    test('permanent backend error is reported with its category', () async {
      final (cubit, _) = await mobile(
        signedInUser: true,
        uploader: _RecordingUploader(
          error: const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.server,
            statusCode: 403,
            code: 'STORAGE_QUOTA_EXCEEDED',
            message: 'quota',
            retryable: false,
          ),
        ),
      );
      await cubit.importLocalTracks([preview('big')]);

      final result = (cubit.state as LocalTracksImported).result;
      expect(result.added, 0);
      expect(result.failed, 1);
      final failure = result.failures.single as CloudUploadFailure;
      expect(failure.code, 'STORAGE_QUOTA_EXCEEDED');
      expect(failure.toLocaleKey(), 'cloud.upload.quotaExceeded');
    });

    test(
      'retry after a network failure reuses id and Idempotency-Key',
      () async {
        final song = preview('retry');
        final failing = _RecordingUploader(
          error: const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.network,
            code: 'network_unavailable',
            message: 'offline',
            retryable: true,
          ),
        );
        final (first, _) = await mobile(signedInUser: true, uploader: failing);
        await first.importLocalTracks([song]);
        final firstResult = (first.state as LocalTracksImported).result;
        expect(firstResult.failed, 1);
        expect(
          (firstResult.failures.single as CloudUploadFailure).toLocaleKey(),
          'cloud.upload.network',
        );
        final firstRequest = failing.requests.last;

        final working = _RecordingUploader();
        final (second, _) = await mobile(signedInUser: true, uploader: working);
        await second.importLocalTracks([song]);

        expect((second.state as LocalTracksImported).result.added, 1);
        expect(working.requests.single.trackId, firstRequest.trackId);
        expect(
          working.requests.single.idempotencyKey,
          firstRequest.idempotencyKey,
        );
      },
    );
  });

  test('history: local play and its sync echo are one entry', () async {
    await seedCloudTrack(sync.t1);
    final queueStore = _MemoryPlayEvents();
    final history = _History();
    final repo = CloudAwareListeningSummaryRepository(
      local: ListeningSummaryRepositoryImpl(
        localDataSource: ListeningSummaryDriftLocalSource(db),
      ),
      queue: PlayEventQueue(store: queueStore, history: history),
      isEnabled: () => true,
    );

    await repo.save(
      ListeningSummary(
        id: sync.e1,
        trackId: sync.t1,
        trackTitle: 'Canon',
        artistName: 'Artist',
        sourceType: SourceType.owlsonic,
        listenedDuration: const Duration(minutes: 2),
        playedAt: fakeNow,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(history.submitted.single.single.id, sync.e1);

    await store.apply(
      sync.page([
        sync.ev('history.append', 1, {
          'event_id': sync.e1,
          'track_id': sync.t1,
          'played_at': '2026-10-07T12:00:00Z',
          'listened_ms': 120000,
          'play_count': 1,
          'last_played_at': '2026-10-07T12:00:00Z',
        }),
      ]),
    );
    expect(await db.select(db.listeningSummaryTable).get(), hasLength(1));
  });

  test(
    'deleting a cloud track calls the backend and never deletes the file',
    () async {
      final file = File(p.join(dir.path, 'mine.mp3'))..writeAsStringSync('x');
      await seedCloudTrack(sync.t1);
      await (db.update(db.trackTable)..where((t) => t.id.equals(sync.t1)))
          .write(TrackTableCompanion(pathToFile: Value(file.path)));
      final remote = _LibraryRemote();
      final localRemoval = _LocalRemoval();

      await CloudAwareTrackRemovalRepository(
        local: localRemoval,
        remote: remote,
        cloud: context(),
      ).removeTrack(sync.t1);

      expect(remote.calls, ['delete ${sync.t1}']);
      expect(localRemoval.calls, isEmpty);
      expect(await db.select(db.trackTable).get(), isEmpty);
      expect(file.existsSync(), isTrue);
    },
  );

  test('Mood Map edit becomes a personal override, canonical intact', () async {
    await store.apply(
      sync.page([
        sync.ev('library.upsert', 2, sync.libraryV2()),
        sync.ev('analysis.upsert', 1, sync.analysisReady(valence: 0.3)),
      ]),
    );
    final remote = _LibraryRemote();
    await CloudAwareMoodMapRepository(
      local: _UnusedMoodMap(),
      remote: remote,
      cloud: context(),
    ).savePersonalPosition(
      PersonalMoodAdjustment(
        trackId: sync.t1,
        valence: 0.8,
        arousal: 0.1,
        updatedAt: fakeNow,
      ),
    );
    expect(remote.patches.single, {
      'custom_valence': 0.8,
      'custom_arousal': 0.1,
    });
    final canonical = await db.select(db.cloudAnalysisTable).getSingle();
    expect(canonical.valence, 0.3);
    final personal = await db
        .select(db.personalMoodAdjustmentTable)
        .getSingle();
    expect(personal.valence, 0.8);
  });

  group('sync coordinator', () {
    test(
      'sign-out purges account data; another account never inherits it',
      () async {
        final session = await signedIn();
        final owner = _Owner();
        final cursors = <String, _Cursors>{};
        final account = _Account('user-a');
        final remote = _Remote({
          null: sync.page(
            [sync.ev('library.upsert', 2, sync.libraryV2())],
            mode: SyncMode.snapshot,
            next: 'delta-1',
          ),
        });
        var cleanups = 0;
        final coordinator = CloudSyncCoordinator(
          session: session,
          configured: true,
          account: account,
          remote: remote,
          local: store,
          owner: owner,
          cursorsFor: (id) => cursors.putIfAbsent(id, _Cursors.new),
          afterPurge: [() async => cleanups++],
        );
        addTearDown(coordinator.dispose);

        await coordinator.start();
        await coordinator.requestSync();
        expect(await db.select(db.trackTable).get(), hasLength(1));
        expect(owner.value, 'user-a');
        expect(cursors['user-a']!.value, 'delta-1');
        expect(cleanups, 0, reason: 'signed in: nothing is removed');

        await session.signOut();
        await Future<void>.delayed(Duration.zero);
        expect(cleanups, 1, reason: 'downloaded audio is cleaned up too');
        expect(await db.select(db.trackTable).get(), isEmpty);
        expect(owner.value, isNull);
        expect(cursors['user-a']!.value, isNull);
      },
    );

    test(
      'stale owner from a previous account is purged before applying',
      () async {
        await seedCloudTrack(sync.t2);
        final session = await signedIn();
        final owner = _Owner()..value = 'user-a';
        var cleanups = 0;
        final coordinator = CloudSyncCoordinator(
          session: session,
          configured: true,
          account: _Account('user-b'),
          remote: _Remote({
            null: sync.page(const [], mode: SyncMode.snapshot, next: 'd'),
          }),
          local: store,
          owner: owner,
          cursorsFor: (_) => _Cursors(),
          afterPurge: [
            () async => throw StateError('cleanup must not break sync'),
            () async => cleanups++,
          ],
        );
        addTearDown(coordinator.dispose);

        await coordinator.requestSync();

        expect(cleanups, 1, reason: 'a failing hook does not skip the rest');
        expect(await db.select(db.trackTable).get(), isEmpty);
        expect(owner.value, 'user-b');
      },
    );

    test('INVALID_SYNC_CURSOR restarts bootstrap without cursor', () async {
      final session = await signedIn();
      final cursor = _Cursors()..value = 'forged';
      final remote = _Remote(
        {
          null: sync.page(
            [sync.ev('library.upsert', 2, sync.libraryV2())],
            mode: SyncMode.snapshot,
            next: 'fresh',
          ),
        },
        invalid: {'forged'},
      );
      final coordinator = CloudSyncCoordinator(
        session: session,
        configured: true,
        account: _Account('user-a'),
        remote: remote,
        local: store,
        owner: _Owner(),
        cursorsFor: (_) => cursor,
      );
      addTearDown(coordinator.dispose);

      await coordinator.requestSync();

      expect(cursor.value, 'fresh');
      expect(remote.requested, ['forged', null]);
      expect(await db.select(db.trackTable).get(), hasLength(1));
    });

    test('offline sync keeps library and cursor', () async {
      await seedCloudTrack(sync.t1);
      final session = await signedIn();
      final cursor = _Cursors()..value = 'c9';
      final analytics = _RecordingAnalytics();
      final coordinator = CloudSyncCoordinator(
        session: session,
        analytics: analytics,
        configured: true,
        account: _Account('user-a'),
        remote: _Remote(const {}, offline: true),
        local: store,
        owner: _Owner()..value = 'user-a',
        cursorsFor: (_) => cursor,
      );
      addTearDown(coordinator.dispose);

      await coordinator.requestSync();

      expect(coordinator.status.phase, CloudSyncPhase.failed);
      expect(cursor.value, 'c9');
      expect(await db.select(db.trackTable).get(), hasLength(1));
      expect(analytics.events, isEmpty);
    });

    test(
      'persistent sync failures are counted once per failed episode',
      () async {
        final session = await signedIn();
        final analytics = _RecordingAnalytics();
        final remote = _Remote(
          {},
          error: const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.server,
            code: 'bad_sync',
            message: 'server rejected sync',
            retryable: false,
            statusCode: 400,
          ),
        );
        final coordinator = CloudSyncCoordinator(
          session: session,
          analytics: analytics,
          configured: true,
          account: _Account('user-a'),
          remote: remote,
          local: store,
          owner: _Owner(),
          cursorsFor: (_) => _Cursors(),
        );
        addTearDown(coordinator.dispose);
        await coordinator.requestSync();
        await coordinator.requestSync();
        expect(analytics.events, ['sync_failed']);
        expect(analytics.properties.single, {'error_category': 'server'});
      },
    );
  });

  group('player fallback', () {
    late HttpServer server;
    final hits = <String>[];

    setUp(() async {
      hits.clear();
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        hits.add(request.uri.path);
        if (request.uri.path == '/expired') {
          request.response.statusCode = 403;
        } else {
          request.response.headers.contentType = ContentType('audio', 'mpeg');
          request.response.add([1, 2, 3, 4]);
        }
        request.response.close();
      });
    });
    tearDown(() => server.close(force: true));

    test(
      'cloud track: signed URL reaches the player; rejection re-acquires',
      () async {
        await seedCloudTrack(sync.t1);
        final track = (await TrackRepositoryImpl(
          localDataSource: TrackDriftLocalSource(db),
        ).getTracks()).single;
        var fetches = 0;
        final selector = CloudPlaybackSourceSelector(
          playbackUrls: SignedUrlCache(
            fetch: (_) async => SignedUrl(
              url: Uri.parse(
                'http://127.0.0.1:${server.port}/${fetches++ == 0 ? 'expired' : 'fresh'}',
              ),
              expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
            ),
          ),
        );

        final source = track.toAudioSource(dir.path, cloud: selector);
        expect(source, isA<CloudStreamAudioSource>());
        final response = await (source as CloudStreamAudioSource).request();
        final bytes = await response.stream.expand((chunk) => chunk).toList();

        expect(bytes, [1, 2, 3, 4]);
        expect(hits, ['/expired', '/fresh']);
        expect(fetches, 2);
      },
    );

    test('a valid local file wins over the backend', () async {
      final file = File(p.join(dir.path, 'local.mp3'))
        ..writeAsBytesSync([9, 9]);
      final source = CloudStreamAudioSource(
        trackId: sync.t1,
        localPath: file.path,
        selector: CloudPlaybackSourceSelector(
          playbackUrls: SignedUrlCache(
            fetch: (_) => throw StateError('must not request a signed URL'),
          ),
        ),
      );
      final response = await source.request();
      expect(await response.stream.expand((c) => c).toList(), [9, 9]);
    });
  });
}

String _itemId(int n) =>
    '018f2c3a-0000-7000-8000-${n.toString().padLeft(12, '0')}';

// ── fakes ───────────────────────────────────────────────────────────────────

class _Scanner implements LocalFileScanner {
  @override
  Future<List<String>> expandPaths(List<String> paths) async => paths;
  @override
  bool isSupportedPath(String path) => path.endsWith('.mp3');
  @override
  Future<List<String>> pickFiles() async => const [];
  @override
  Future<List<String>> pickFolder() async => const [];
  @override
  Future<TrackPreview> readPreview(String path) async => TrackPreview(
    id: 'local-${p.basenameWithoutExtension(path)}',
    title: p.basenameWithoutExtension(path),
    artist: 'Artist',
    source: SourceType.localFile,
    originalUrl: path,
    urlFile: path,
  );
}

class _RecordingUploader extends _Uploader {
  _RecordingUploader({super.error});
  final requests = <CloudUploadRequest>[];

  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) {
    requests.add(request);
    return super.upload(request, onProgress: onProgress, cancelled: cancelled);
  }
}

class _Picker implements LocalTrackPicker {
  @override
  Future<void> clearPickedCache() async {}

  _Picker(this.previews);
  final List<TrackPreview> previews;
  @override
  Future<List<TrackPreview>> pickTracks() async => previews;
}

class _Uploader implements CloudTrackUploadRepository {
  _Uploader({this.error});
  final Exception? error;
  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) async {
    if (error != null) throw error!;
    return CloudTrack(
      id: request.trackId,
      title: request.manifest.title,
      artistName: request.manifest.artistName,
      albumTitle: null,
      duration: const Duration(seconds: 1),
      hasArtwork: false,
      addedAt: fakeNow,
    );
  }
}

class _PlaylistRemote implements CloudPlaylistRepository {
  bool failAddItem = false;
  final calls = <String>[];
  final items = <String, String>{}; // itemId -> trackId, ordered
  String name = '';

  CloudPlaylist _detail(String id) => CloudPlaylist(
    id: id,
    name: name,
    createdAt: fakeNow,
    updatedAt: fakeNow,
    items: [
      for (final (index, entry) in items.entries.indexed)
        CloudPlaylistItem(
          id: entry.key,
          trackId: entry.value,
          position: index,
          title: '',
          artistName: null,
          albumTitle: null,
          trackAvailable: true,
        ),
    ],
  );

  @override
  Future<CloudPlaylist> create({
    required String id,
    required String name,
  }) async {
    calls.add('create $name');
    this.name = name;
    return _detail(id);
  }

  @override
  Future<CloudPlaylistItem> addItem(
    String playlistId, {
    required String itemId,
    required String trackId,
    int? index,
  }) async {
    if (failAddItem) throw StateError('network');
    calls.add('add $itemId $trackId');
    items[itemId] = trackId;
    return _detail(playlistId).items.last;
  }

  @override
  Future<CloudPlaylist> reorder(String playlistId, List<String> itemIds) async {
    calls.add('reorder ${itemIds.join(',')}');
    final copy = Map.of(items);
    items
      ..clear()
      ..addAll({for (final id in itemIds) id: copy[id]!});
    return _detail(playlistId);
  }

  @override
  Future<void> removeItem(String playlistId, String itemId) async {
    calls.add('remove $itemId');
    items.remove(itemId);
  }

  @override
  Future<CloudPlaylist> rename(String playlistId, String name) async {
    calls.add('rename $name');
    this.name = name;
    return _detail(playlistId);
  }

  @override
  Future<void> delete(String playlistId) async => calls.add('delete');

  @override
  Future<CloudPlaylist> get(String playlistId) async => _detail(playlistId);

  @override
  Future<CloudPage<CloudPlaylistSummary>> list({String? cursor, int? limit}) =>
      throw UnimplementedError();
}

class _LibraryRemote implements CloudLibraryRepository {
  final calls = <String>[];
  final patches = <Map<String, Object?>>[];

  @override
  Future<void> delete(String trackId) async => calls.add('delete $trackId');

  @override
  Future<CloudLibraryItem> patch(String trackId, LibraryItemPatch patch) async {
    patches.add(patch.toJson());
    final json = patch.toJson();
    return CloudLibraryItem(
      id: trackId,
      title: 'Canon',
      artistName: 'Artist',
      albumTitle: 'Album',
      albumArtist: null,
      trackNumber: 1,
      discNumber: null,
      year: 2024,
      genres: const ['ambient'],
      duration: const Duration(seconds: 200),
      hasArtwork: true,
      analysisStatus: CloudAnalysisStatus.ready,
      customTitle: null,
      customArtistName: null,
      customAlbumTitle: null,
      addedAt: fakeNow,
      updatedAt: fakeNow,
      favorite: false,
      customValence: json['custom_valence'] as double?,
      customArousal: json['custom_arousal'] as double?,
      playCount: 0,
      lastPlayedAt: null,
    );
  }

  @override
  Future<SignedUrl> artworkUrl(String trackId) => throw UnimplementedError();
  @override
  Future<CloudLibraryItem> get(String trackId) => throw UnimplementedError();
  @override
  Future<CloudPage<CloudLibraryItem>> list({String? cursor, int? limit}) =>
      throw UnimplementedError();
  @override
  Future<SignedUrl> playbackUrl(String trackId) => throw UnimplementedError();
}

class _LocalRemoval implements TrackRemovalRepository {
  final calls = <String>[];
  @override
  Future<void> cleanupPending() async {}
  @override
  Future<void> removeTrack(String trackId) async => calls.add(trackId);
}

class _UnusedMoodMap extends Fake implements MoodMapRepository {}

class _MemoryPlayEvents implements PlayEventStore {
  List<PlayEvent> events = [];
  @override
  Future<List<PlayEvent>> load() async => List.of(events);
  @override
  Future<void> save(List<PlayEvent> next) async => events = List.of(next);
}

class _History implements CloudHistoryRepository {
  final submitted = <List<PlayEvent>>[];
  @override
  Future<PlayEventsResult> submit(List<PlayEvent> events) async {
    submitted.add(events);
    return PlayEventsResult(accepted: events.length, duplicates: 0);
  }

  @override
  Future<CloudPage<CloudHistoryItem>> list({String? cursor, int? limit}) =>
      throw UnimplementedError();
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

class _Account extends Fake implements CloudAccountRepository {
  _Account(this.id);
  final String id;
  @override
  Future<CloudUser> me() async =>
      CloudUser(id: id, email: '$id@example.com', createdAt: fakeNow);
}

class _Remote implements CloudSyncRepository {
  _Remote(
    this.pages, {
    this.invalid = const {},
    this.offline = false,
    this.error,
  });
  final Map<String?, SyncPage> pages;
  final Set<String> invalid;
  final bool offline;
  final Exception? error;
  final requested = <String?>[];

  @override
  Future<SyncPage> pull({String? cursor, int? limit}) async {
    requested.add(cursor);
    if (error != null) throw error!;
    if (offline) {
      throw const OwlSonicApiException(
        kind: OwlSonicApiErrorKind.network,
        code: 'network_unavailable',
        message: 'offline',
        retryable: true,
      );
    }
    if (invalid.contains(cursor)) {
      throw const OwlSonicApiException(
        kind: OwlSonicApiErrorKind.server,
        statusCode: 400,
        code: 'INVALID_SYNC_CURSOR',
        message: 'bad cursor',
        retryable: false,
      );
    }
    return pages[cursor]!;
  }
}

final class _RecordingAnalytics implements AnalyticsTracker {
  final events = <String>[];
  final properties = <Map<String, Object>>[];
  @override
  bool get isAvailable => true;
  @override
  bool get isEnabled => true;
  @override
  Future<void> setEnabled(bool enabled) async {}
  @override
  Future<void> logEvent(String name, {Map<String, Object>? properties}) async {
    events.add(name);
    this.properties.add(Map.of(properties ?? const {}));
  }

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {}
}
