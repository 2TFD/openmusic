// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/audio_metadata/audio_metadata_writer.dart';
import 'package:owlsonic/core/services/audio_player/cloud_stream_audio_source.dart';
import 'package:owlsonic/core/services/cloud/cloud_audio_cache.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/services/storage/free_space_probe.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';
import 'package:path/path.dart' as p;

/// A stalled connection must fail within the timeout instead of hanging an
/// offline pass, a cache download or playback.
void main() {
  late HttpServer server;
  late Directory root;
  final held = <HttpResponse>[];

  Uri url(String path) =>
      Uri.parse('http://${server.address.host}:${server.port}$path');

  setUp(() async {
    root = await Directory.systemTemp.createTemp('owl-timeouts');
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final path = request.uri.path;
      if (path.startsWith('/stall-headers')) {
        held.add(request.response); // never answered
        return;
      }
      if (path.startsWith('/stall-body')) {
        request.response
          ..headers.contentType = ContentType('audio', 'mpeg')
          ..contentLength = 1000
          ..add(List<int>.filled(10, 1));
        await request.response.flush();
        held.add(request.response); // body never completes
        return;
      }
      request.response
        ..headers.contentType = ContentType('audio', 'mpeg')
        ..add(List<int>.filled(100, 7));
      await request.response.close();
    });
  });

  tearDown(() async {
    held.clear();
    await server.close(force: true);
    await root.delete(recursive: true);
  });

  Dio shortDio() => cloudDownloadDio(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(milliseconds: 300),
  );

  test('download Dio has connect and stall timeouts by default', () {
    final options = cloudDownloadDio().options;
    expect(options.connectTimeout, const Duration(seconds: 15));
    expect(options.receiveTimeout, const Duration(seconds: 30));
  });

  for (final stall in ['/stall-headers', '/stall-body']) {
    test(
      'stream cache gives up on $stall and leaves no partial file',
      () async {
        final cache = CloudAudioCache(
          directory: () async => Directory(p.join(root.path, 'cache')),
          playbackUrl: (id) async => url('$stall/$id'),
          dio: shortDio(),
        );

        await cache
            .cache('t1')
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => fail('hung'),
            );

        expect(await cache.lookup('t1'), isNull);
        final leftovers = Directory(p.join(root.path, 'cache')).listSync();
        expect(leftovers, isEmpty);
      },
    );
  }

  test('a stalled track does not freeze the offline pass', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = CloudLocalStore(db);
    for (final id in ['a-stalled', 'b-ok']) {
      await db
          .into(db.trackTable)
          .insert(
            TrackTableCompanion.insert(
              id: id,
              title: 'Song $id',
              sourceType: SourceType.owlsonic.name,
              sourceUri: 'owlsonic:track/$id',
              addedAt: Value(DateTime.utc(2026, 1, id == 'a-stalled' ? 1 : 2)),
            ),
          );
    }
    final mode = DeviceStorageModeStore()
      ..current.value = DeviceStorageMode.offline;
    final library = CloudOfflineLibrary(
      store: store,
      tracks: _Tracks(),
      mode: mode,
      isEnabled: () => true,
      playbackUrl: (id) async =>
          url(id == 'a-stalled' ? '/stall-body/$id' : '/ok/$id'),
      artworkUrl: (id) async => url('/ok/cover'),
      cache: CloudAudioCache(
        directory: () async => Directory(p.join(root.path, 'cache')),
        playbackUrl: (id) async => url('/ok/$id'),
        dio: shortDio(),
      ),
      appDir: root.path,
      metadata: const _NoMetadata(),
      space: const _PlentyOfSpace(),
      dio: shortDio(),
    );

    await library.run().timeout(
      const Duration(seconds: 10),
      onTimeout: () => fail('offline pass hung on a stalled connection'),
    );

    final rows = {
      for (final row in await db.select(db.trackTable).get())
        row.id: row.pathToFile,
    };
    expect(rows['a-stalled'], isNull, reason: 'retried on the next pass');
    expect(rows['b-ok'], startsWith('offline/'));
    expect(library.progress.value.phase, OfflinePhase.interrupted);
    final partials = Directory(
      p.join(root.path, CloudLocalStore.offlineFolder),
    ).listSync().where((f) => f.path.endsWith('.part'));
    expect(partials, isEmpty);
  });

  test('playback fails fast when the server never answers', () async {
    final source = CloudStreamAudioSource(
      trackId: 't1',
      localPath: null,
      responseTimeout: const Duration(milliseconds: 300),
      selector: CloudPlaybackSourceSelector(
        playbackUrls: SignedUrlCache(
          fetch: (id) async => SignedUrl(
            url: url('/stall-headers/$id'),
            expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          ),
        ),
        audioCache: CloudAudioCache(
          directory: () async => Directory(p.join(root.path, 'cache')),
          playbackUrl: (id) async => url('/ok/$id'),
        ),
        cacheStreamed: () => false,
      ),
    );

    await expectLater(
      source.request(0).timeout(const Duration(seconds: 10)),
      throwsA(
        isA<PlaybackUnavailable>().having((e) => e.reason, 'reason', 'timeout'),
      ),
    );
  });
}

class _Tracks extends Fake implements TrackRepository {
  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => [
    for (final id in ids)
      Track(
        id: id,
        title: 'Song $id',
        artists: const [],
        duration: const Duration(minutes: 3),
        addedAt: DateTime.utc(2026),
        source: Source(type: SourceType.owlsonic, originalUrl: 'owlsonic:$id'),
      ),
  ];
}

class _NoMetadata implements AudioMetadataWriter {
  const _NoMetadata();
  @override
  Future<bool> write(String audioPath, AudioMetadata metadata) async => true;
}

class _PlentyOfSpace implements FreeSpaceProbe {
  const _PlentyOfSpace();
  @override
  Future<int?> freeBytes(String path) async => null;
}
