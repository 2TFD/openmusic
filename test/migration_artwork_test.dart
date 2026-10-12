import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/core/services/cloud/local_library_migration.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_repository.dart';

void main() {
  late Directory appDir;
  late _Importer importer;
  var requests = 0;

  Dio dioReplying(String? contentType, List<int> bytes) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.resolve(
            Response<List<int>>(
              requestOptions: options,
              data: bytes,
              statusCode: 200,
              headers: Headers.fromMap({
                if (contentType != null) 'content-type': [contentType],
              }),
            ),
          );
        },
      ),
    );
    return dio;
  }

  Track track({String? imageUrl}) => Track(
    id: 'sc1',
    title: 'Song',
    artists: const [Artist(id: 'a', name: 'Artist')],
    duration: const Duration(minutes: 3),
    source: const Source(
      type: SourceType.soundcloud,
      originalUrl: 'https://soundcloud.com/a/song',
    ),
    filePath: 'soundcloud_1.mp3',
    imageUrl: imageUrl,
    addedAt: DateTime.utc(2026),
  );

  LocalLibraryMigration migration(Track t, Dio dio) => LocalLibraryMigration(
    tracks: _Tracks(t),
    uploads: _Uploads(),
    importer: importer,
    appDir: appDir.path,
    dio: dio,
  );

  setUp(() {
    requests = 0;
    importer = _Importer();
    appDir = Directory.systemTemp.createTempSync('migration_artwork');
    File('${appDir.path}/soundcloud_1.mp3').writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() => appDir.deleteSync(recursive: true));

  test('an http cover is downloaded and sent as the artwork file', () async {
    final m = migration(
      track(imageUrl: 'https://i1.sndcdn.com/art-t500x500.jpg'),
      dioReplying('image/jpeg', [9, 9, 9, 9]),
    );

    await m.uploadDownloaded('sc1');

    final source = importer.sources.single;
    expect(source.artworkPath, '${appDir.path}/artwork/sc1.jpg');
    expect(File(source.artworkPath!).readAsBytesSync(), [9, 9, 9, 9]);
    expect(source.sourceTrackId, 'sc1');
  });

  test('the downloaded cover is reused, not fetched again', () async {
    final t = track(imageUrl: 'https://i1.sndcdn.com/art.jpg');
    final dio = dioReplying('image/png', [1, 2]);

    await migration(t, dio).uploadDownloaded('sc1');
    await migration(t, dio).uploadDownloaded('sc1');

    expect(requests, 1);
    expect(importer.sources.last.artworkPath, endsWith('sc1.png'));
  });

  test(
    'a non-image answer or a failed download uploads without a cover',
    () async {
      final t = track(imageUrl: 'https://example.com/not-an-image');

      await migration(
        t,
        dioReplying('text/html', [60, 33]),
      ).uploadDownloaded('sc1');
      expect(importer.sources.single.artworkPath, isNull);
      expect(Directory('${appDir.path}/artwork').listSync(), isEmpty);

      final failing = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(requestOptions: options, message: 'offline'),
            ),
          ),
        );
      await migration(t, failing).uploadDownloaded('sc1');
      expect(importer.sources.last.artworkPath, isNull);
    },
  );

  test('with auto-sync off a download stays on the device', () async {
    importer.allowed = false;
    final m = migration(track(imageUrl: null), dioReplying('image/jpeg', [0]));

    await m.uploadDownloaded('sc1');

    expect(importer.sources, isEmpty);
  });

  test('"Sync this song" uploads even when auto-sync is off', () async {
    importer.allowed = false;
    final m = migration(track(imageUrl: null), dioReplying('image/jpeg', [0]));

    await m.uploadNow('sc1');

    expect(importer.sources.single.sourceTrackId, 'sc1');
  });

  test('an existing local cover file is passed through untouched', () async {
    final cover = File('${appDir.path}/local_cover.jpg')..writeAsBytesSync([5]);

    await migration(
      track(imageUrl: cover.path),
      dioReplying('image/jpeg', [0]),
    ).uploadDownloaded('sc1');

    expect(importer.sources.single.artworkPath, cover.path);
    expect(requests, 0);
  });
}

class _Importer extends Fake implements CloudImportService {
  final sources = <CloudImportSource>[];

  @override
  bool get enabled => true;

  bool allowed = true;

  @override
  Future<bool> autoUploadAllowed() async => allowed;

  @override
  Future<Map<String, CloudUploadItemState>> importAll(
    List<CloudImportSource> sources, {
    void Function(String key, CloudUploadItemState state)? onUpdate,
  }) async {
    this.sources.addAll(sources);
    return {};
  }
}

class _Tracks extends Fake implements TrackRepository {
  _Tracks(this.track);
  final Track track;

  @override
  Future<List<Track>> getTracksByIds(List<String> ids) async => [track];
}

class _Uploads extends Fake implements CloudUploadStore {}
