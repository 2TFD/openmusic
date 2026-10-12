import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/audio_metadata/audio_metadata_writer.dart';
import 'package:owlsonic/core/services/cloud/cloud_audio_cache.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/services/storage/free_space_probe.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:path/path.dart' as p;

/// Serves `/audio/<id>` as MP3 bytes and `/cover/<id>` as a JPEG.
class _FakeHttp implements HttpClientAdapter {
  final paths = <String>[];

  /// Track ids whose audio request fails like a dropped connection.
  final failing = <String>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    paths.add(path);
    if (failing.contains(path.split('/').last)) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final isCover = path.startsWith('/cover/');
    return ResponseBody.fromBytes(
      isCover ? [0xFF, 0xD8, 0xFF] : List<int>.filled(100, 7),
      200,
      headers: {
        Headers.contentTypeHeader: [isCover ? 'image/jpeg' : 'audio/mpeg'],
        Headers.contentLengthHeader: [isCover ? '3' : '100'],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  int count(String prefix) => paths.where((p) => p.startsWith(prefix)).length;
}

class _RecordingMetadata implements AudioMetadataWriter {
  final written = <String, AudioMetadata>{};
  final coverExisted = <String, bool>{};

  @override
  Future<bool> write(String audioPath, AudioMetadata metadata) async {
    written[audioPath] = metadata;
    final cover = metadata.coverPath;
    coverExisted[audioPath] = cover != null && File(cover).existsSync();
    return true;
  }
}

class _Space implements FreeSpaceProbe {
  int? free;

  @override
  Future<int?> freeBytes(String path) async => free;
}

class _Tracks extends Fake implements TrackRepository {
  _Tracks(this.byId);
  final Map<String, Track> byId;

  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => [
    for (final id in ids) ?byId[id],
  ];
}

void main() {
  late Directory root;
  late _FakeHttp http;
  late Dio dio;

  Uri audioUrl(String id) => Uri.parse('https://cdn.test/audio/$id');

  CloudAudioCache cache({int maxBytes = CloudAudioCache.defaultMaxBytes}) =>
      CloudAudioCache(
        directory: () async => Directory(p.join(root.path, 'cache')),
        playbackUrl: (id) async => audioUrl(id),
        dio: dio,
        maxBytes: maxBytes,
      );

  setUp(() {
    root = Directory.systemTemp.createTempSync('storage_modes');
    http = _FakeHttp();
    dio = Dio()..httpClientAdapter = http;
  });

  tearDown(() => root.deleteSync(recursive: true));

  group('stream mode cache', () {
    test('a cached track is found again, with the right extension', () async {
      final c = cache();
      expect(await c.lookup('t1'), isNull);

      await c.cache('t1');

      final path = await c.lookup('t1');
      expect(path, endsWith('t1.mp3'));
      expect(File(path!).lengthSync(), 100);
      // A fresh instance rebuilds its index from disk.
      expect(await cache().lookup('t1'), path);
    });

    test('least recently played tracks are evicted past the limit', () async {
      final c = cache(maxBytes: 250); // room for two 100-byte tracks
      await c.cache('a');
      await c.cache('b');
      File((await c.lookup('a'))!).setLastModifiedSync(DateTime(2020));
      File((await c.lookup('b'))!).setLastModifiedSync(DateTime(2021));

      await c.cache('c');

      expect(await c.lookup('a'), isNull, reason: 'oldest is evicted');
      expect(await c.lookup('b'), isNotNull);
      expect(await c.lookup('c'), isNotNull);
    });

    test('streaming fills the cache and the next playback is local', () async {
      final c = cache();
      var streamMode = true;
      final selector = CloudPlaybackSourceSelector(
        playbackUrls: SignedUrlCache(
          fetch: (id) async => SignedUrl(
            url: audioUrl(id),
            expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          ),
        ),
        audioCache: c,
        cacheStreamed: () => streamMode,
      );

      expect(
        await selector.resolve(cloudTrackId: 't1'),
        isA<RemotePlaybackSource>(),
      );
      await c.cache('t1'); // joins the background download
      final next = await selector.resolve(cloudTrackId: 't1');
      expect(next, isA<LocalPlaybackSource>());
      expect((next as LocalPlaybackSource).cached, isTrue);

      streamMode = false;
      await selector.resolve(cloudTrackId: 't2');
      expect(await c.lookup('t2'), isNull, reason: 'offline mode: no cache');
    });
  });

  test('the stream cache skips caching while space is low', () async {
    final c = CloudAudioCache(
      directory: () async => Directory(p.join(root.path, 'cache')),
      playbackUrl: (id) async => audioUrl(id),
      dio: dio,
      space: _Space()..free = 10,
    );

    await c.cache('t1');

    expect(await c.lookup('t1'), isNull);
    expect(http.count('/audio/'), 0);
  });

  test('out-of-space errors are recognised, wrapped or not', () {
    const noSpace = FileSystemException(
      'write failed',
      '/x',
      OSError('No space left on device', 28),
    );
    expect(isOutOfSpace(noSpace), Platform.isWindows ? isFalse : isTrue);
    expect(
      isOutOfSpace(
        DioException(requestOptions: RequestOptions(), error: noSpace),
      ),
      Platform.isWindows ? isFalse : isTrue,
    );
    expect(
      isOutOfSpace(const FileSystemException('x', '/x', OSError('denied', 13))),
      isFalse,
    );
    expect(isOutOfSpace(StateError('x')), isFalse);
  });

  group('offline mode', () {
    late AppDatabase db;
    late CloudLocalStore store;
    late DeviceStorageModeStore mode;
    late _RecordingMetadata metadata;
    late CloudAudioCache audioCache;
    late _Space space;

    Track track(String id) => Track(
      id: id,
      title: 'Song $id',
      artists: const [Artist(id: 'x', name: 'Artist')],
      album: 'Album',
      duration: const Duration(minutes: 3),
      source: Source(type: SourceType.owlsonic, originalUrl: 'owlsonic:$id'),
      imageUrl: cloudArtworkUri(id),
      addedAt: DateTime.utc(2026),
    );

    Future<void> insertCloudTrack(String id, {String? path}) => db
        .into(db.trackTable)
        .insert(
          TrackTableCompanion.insert(
            id: id,
            title: 'Song $id',
            sourceType: SourceType.owlsonic.name,
            sourceUri: 'owlsonic:track/$id',
            pathToFile: Value(path),
          ),
        );

    Future<String?> pathOf(String id) async => (await (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(id))).getSingle()).pathToFile;

    CloudOfflineLibrary library(Map<String, Track> tracks) =>
        CloudOfflineLibrary(
          store: store,
          tracks: _Tracks(tracks),
          mode: mode,
          isEnabled: () => true,
          playbackUrl: (id) async => audioUrl(id),
          artworkUrl: (id) async => Uri.parse('https://cdn.test/cover/$id'),
          cache: audioCache,
          appDir: root.path,
          metadata: metadata,
          space: space,
          dio: dio,
        );

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      store = CloudLocalStore(db);
      mode = DeviceStorageModeStore()
        ..current.value = DeviceStorageMode.offline;
      metadata = _RecordingMetadata();
      audioCache = cache();
      space = _Space();
    });

    tearDown(() => db.close());

    test('downloads missing cloud tracks and tags them', () async {
      await insertCloudTrack('a');
      await insertCloudTrack('b');
      await insertCloudTrack('mine', path: '/Users/me/original.mp3');

      await library({'a': track('a'), 'b': track('b')}).run();

      expect(await pathOf('a'), 'offline/Artist - Song a - owlsonic - a.mp3');
      expect(await pathOf('b'), 'offline/Artist - Song b - owlsonic - b.mp3');
      expect(await pathOf('mine'), '/Users/me/original.mp3');
      expect(
        File(
          p.join(root.path, 'offline/Artist - Song a - owlsonic - a.mp3'),
        ).existsSync(),
        isTrue,
      );
      final tags =
          metadata.written[p.join(
            root.path,
            'offline/Artist - Song a - owlsonic - a.mp3',
          )]!;
      expect(tags.title, 'Song a');
      expect(tags.artist, 'Artist');
      expect(tags.album, 'Album');
      expect(
        metadata.coverExisted[p.join(
          root.path,
          'offline/Artist - Song a - owlsonic - a.mp3',
        )],
        isTrue,
      );
      expect(http.count('/audio/'), 2);
      // Temporary cover files are cleaned up.
      expect(
        Directory(
          p.join(root.path, 'offline'),
        ).listSync().map((e) => p.basename(e.path)),
        unorderedEquals([
          'Artist - Song a - owlsonic - a.mp3',
          'Artist - Song b - owlsonic - b.mp3',
        ]),
      );
    });

    test('a track already in the stream cache is moved, not fetched', () async {
      await insertCloudTrack('a');
      await audioCache.cache('a');
      final fetched = http.count('/audio/');

      await library({'a': track('a')}).run();

      expect(await pathOf('a'), 'offline/Artist - Song a - owlsonic - a.mp3');
      expect(http.count('/audio/'), fetched);
      expect(await audioCache.lookup('a'), isNull);
    });

    test('one track can be saved and removed in stream mode', () async {
      mode.current.value = DeviceStorageMode.stream;
      await insertCloudTrack('a');
      await insertCloudTrack('b');
      await insertCloudTrack('mine', path: '/Users/me/original.mp3');
      final offline = library({
        'a': track('a'),
        'b': track('b'),
        'mine': track('mine'),
      });

      await offline.downloadTrack('a');

      const relative = 'offline/Artist - Song a - owlsonic - a.mp3';
      expect(await pathOf('a'), relative);
      expect(await pathOf('b'), isNull);
      expect(http.count('/audio/'), 1);

      await offline.removeDownload('a');
      await offline.removeDownload('mine');

      expect(await pathOf('a'), isNull);
      expect(File(p.join(root.path, relative)).existsSync(), isFalse);
      expect(await pathOf('mine'), '/Users/me/original.mp3');
    });

    test('stream mode downloads nothing', () async {
      mode.current.value = DeviceStorageMode.stream;
      await insertCloudTrack('a');

      await library({'a': track('a')}).run();

      expect(await pathOf('a'), isNull);
      expect(http.count('/audio/'), 0);
    });

    test('switching to stream hands the copies to the cache', () async {
      await insertCloudTrack('a');
      final lib = library({'a': track('a')});
      await lib.run();

      mode.current.value = DeviceStorageMode.stream;
      await lib.onModeChanged(DeviceStorageMode.stream);

      expect(await pathOf('a'), isNull);
      expect(
        File(
          p.join(root.path, 'offline/Artist - Song a - owlsonic - a.mp3'),
        ).existsSync(),
        isFalse,
      );
      expect(await audioCache.lookup('a'), isNotNull);
    });

    test('progress reports how much of the library is on the device', () async {
      await insertCloudTrack('a');
      await insertCloudTrack('b');
      final lib = library({'a': track('a'), 'b': track('b')});

      await lib.run();

      final progress = lib.progress.value;
      expect(progress.phase, OfflinePhase.complete);
      expect(progress.total, 2);
      expect(progress.onDevice, 2);
      expect(progress.fraction, 1);
    });

    test('does not start when the device is below the free reserve', () async {
      await insertCloudTrack('a');
      space.free = CloudOfflineLibrary.minFreeBytes - 1;
      final lib = library({'a': track('a')});

      await lib.run();

      expect(lib.progress.value.phase, OfflinePhase.lowSpace);
      expect(
        lib.progress.value.freeBytes,
        CloudOfflineLibrary.minFreeBytes - 1,
      );
      expect(await pathOf('a'), isNull);
      expect(http.count('/audio/'), 0);
    });

    test('a track that would eat into the reserve is not written', () async {
      await insertCloudTrack('a');
      // Above the reserve, but not by the 100 bytes the track needs.
      space.free = CloudOfflineLibrary.minFreeBytes + 50;
      final lib = library({'a': track('a')});

      await lib.run();

      expect(lib.progress.value.phase, OfflinePhase.lowSpace);
      expect(
        lib.progress.value.neededBytes,
        100 + CloudOfflineLibrary.minFreeBytes,
      );
      expect(await pathOf('a'), isNull);
      expect(
        Directory(p.join(root.path, 'offline')).listSync(),
        isEmpty,
        reason: 'no partial file is left behind',
      );
    });

    group('reliability', () {
      Future<List<String>> offlineFiles() async {
        final dir = Directory(p.join(root.path, 'offline'));
        return dir.existsSync()
            ? [for (final e in dir.listSync()) p.basename(e.path)]
            : <String>[];
      }

      test('one failing track does not stop the others, and the next pass '
          'finishes the job', () async {
        for (final id in ['a', 'b', 'c']) {
          await insertCloudTrack(id);
        }
        final lib = library({
          for (final id in ['a', 'b', 'c']) id: track(id),
        });
        http.failing.add('b');

        await lib.run();

        expect(await pathOf('a'), isNotNull);
        expect(await pathOf('b'), isNull);
        expect(await pathOf('c'), isNotNull);
        expect(lib.progress.value.phase, OfflinePhase.interrupted);
        expect(lib.progress.value.onDevice, 2);
        expect(lib.progress.value.total, 3);
        expect(await offlineFiles(), hasLength(2), reason: 'no .part left');

        http.failing.clear(); // connection is back; next sync runs again
        await lib.run();

        expect(await pathOf('b'), isNotNull);
        expect(lib.progress.value.phase, OfflinePhase.complete);
        expect(lib.progress.value.onDevice, 3);
      });

      test('a dead connection ends the pass after three failures', () async {
        final ids = ['1', '2', '3', '4', '5'];
        for (final id in ids) {
          await insertCloudTrack(id);
        }
        http.failing.addAll(ids);
        final lib = library({for (final id in ids) id: track(id)});

        await lib.run();

        expect(http.count('/audio/'), 3, reason: 'does not hammer the server');
        expect(lib.progress.value.phase, OfflinePhase.interrupted);
        expect(lib.progress.value.onDevice, 0);
        expect(await offlineFiles(), isEmpty);
      });

      test('after a restart it resumes with what is missing and clears '
          'leftovers of an interrupted download', () async {
        await insertCloudTrack('a');
        await library({'a': track('a')}).run();
        expect(http.count('/audio/'), 1);

        await insertCloudTrack('b');
        final offline = Directory(p.join(root.path, 'offline'));
        File(p.join(offline.path, 'b.part')).writeAsBytesSync([1, 2, 3]);

        // A new instance, as after an app restart (nothing in memory).
        final restarted = library({'a': track('a'), 'b': track('b')});
        await restarted.run();

        expect(http.count('/audio/'), 2, reason: 'only b was fetched');
        expect(await pathOf('b'), isNotNull);
        expect(restarted.progress.value.phase, OfflinePhase.complete);
        expect(await offlineFiles(), hasLength(2));
      });

      test('signing out deletes the downloaded copies', () async {
        await insertCloudTrack('a');
        final lib = library({'a': track('a')});
        await lib.run();
        expect(await offlineFiles(), hasLength(1));

        await store.purgeCloudData(); // what the sync coordinator does
        await lib.onSignedOut();

        expect(await offlineFiles(), isEmpty);
        expect(lib.progress.value.phase, OfflinePhase.idle);
        expect(lib.progress.value.total, 0);
      });

      test(
        'a copy the user already owns is never touched by cleanup',
        () async {
          final mine = File(p.join(root.path, 'my-own.mp3'))
            ..writeAsBytesSync([1]);
          await insertCloudTrack('a', path: mine.path);
          final lib = library({'a': track('a')});

          await lib.onSignedOut();

          expect(mine.existsSync(), isTrue);
        },
      );
    });

    test('downloaded music plays with no connection at all', () async {
      await insertCloudTrack('a');
      await library({'a': track('a')}).run();
      final relative = (await pathOf('a'))!;
      var requested = 0;
      final selector = CloudPlaybackSourceSelector(
        playbackUrls: SignedUrlCache(
          fetch: (id) async {
            requested++;
            throw const SocketException('offline');
          },
        ),
      );

      final source = await selector.resolve(
        localPath: p.join(root.path, relative),
        cloudTrackId: 'a',
      );

      expect(source, isA<LocalPlaybackSource>());
      expect((source as LocalPlaybackSource).cached, isFalse);
      expect(requested, 0, reason: 'no signed URL is needed');
    });

    test('a track that was never downloaded is unavailable offline', () async {
      final selector = CloudPlaybackSourceSelector(
        playbackUrls: SignedUrlCache(
          fetch: (id) async => throw const SocketException('offline'),
        ),
      );
      await expectLater(
        selector.resolve(cloudTrackId: 'never-downloaded'),
        throwsA(isA<PlaybackUnavailable>()),
      );
    });

    test('copies of tracks that left the library are removed', () async {
      final offline = Directory(p.join(root.path, 'offline'))..createSync();
      final orphan = File(p.join(offline.path, 'gone.mp3'))
        ..writeAsBytesSync([1]);

      await library({}).run();

      expect(orphan.existsSync(), isFalse);
    });
  });
}
