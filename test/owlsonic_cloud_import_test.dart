import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_batch.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_track_upload_repository.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

import 'support/fake_owlsonic_backend.dart';

const _uuid = '018f2c3a-0000-7000-8000-000000000001';

Map<String, Object?> _trackJson(String id) => {
  'id': id,
  'title': 'Song',
  'artist_name': 'Artist',
  'album_title': null,
  'album_artist': null,
  'track_number': null,
  'disc_number': null,
  'year': null,
  'genres': [],
  'duration_ms': 1000,
  'has_artwork': false,
  'added_at': '2026-10-07T12:00:00Z',
  'created_at': '2026-10-07T12:00:00Z',
};

OwlSonicApiException _error(
  String code, {
  int status = 400,
  bool retryable = false,
  Duration? retryAfter,
}) => OwlSonicApiException(
  kind: OwlSonicApiErrorKind.server,
  statusCode: status,
  code: code,
  message: code,
  retryable: retryable,
  requestId: 'req-$code',
  retryAfter: retryAfter,
);

CloudUploadRequest _request(String id) => CloudUploadRequest(
  localId: id,
  audioPath: '/music/$id.mp3',
  idempotencyKey: 'owlsonic-upload:key-$id-000000',
  manifest: TrackManifest(trackId: 'track-$id', title: id),
);

CloudTrack _cloudTrack(CloudUploadRequest request) => CloudTrack(
  id: request.trackId,
  title: request.manifest.title,
  artistName: request.manifest.artistName,
  albumTitle: request.manifest.albumTitle,
  duration: const Duration(seconds: 1),
  hasArtwork: false,
  addedAt: DateTime.utc(2026, 10, 7),
);

/// Scripted uploader: per localId, the outcome of each attempt.
class _Uploader implements CloudTrackUploadRepository {
  _Uploader([this.script = const {}]);

  final Map<String, List<Exception>> script;
  final calls = <CloudUploadRequest>[];
  int active = 0;
  int maxActive = 0;

  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) async {
    calls.add(request);
    active++;
    maxActive = active > maxActive ? active : maxActive;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1));
      onProgress?.call(5, 10);
      final steps = script[request.localId] ?? const [];
      final attempt =
          calls.where((call) => call.localId == request.localId).length - 1;
      if (attempt < steps.length) throw steps[attempt];
      return _cloudTrack(request);
    } finally {
      active--;
    }
  }
}

/// Fails by audio path (for service tests where record ids are generated).
class _PathUploader implements CloudTrackUploadRepository {
  _PathUploader([this.failures = const {}]);
  final Map<String, Exception> failures;
  final calls = <CloudUploadRequest>[];

  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) async {
    calls.add(request);
    final error = failures[request.audioPath];
    if (error != null) throw error;
    return _cloudTrack(request);
  }
}

class _ConflictOnceUploader implements CloudTrackUploadRepository {
  final calls = <CloudUploadRequest>[];

  @override
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  }) async {
    calls.add(request);
    if (calls.length == 1) throw _error('TRACK_ID_CONFLICT', status: 409);
    return _cloudTrack(request);
  }
}

void main() {
  group('TrackManifest', () {
    test('required fields, LOCAL_UPLOAD and no technical fields', () {
      final json = TrackManifest(
        trackId: _uuid,
        title: '  Song  ',
        artistName: 'Artist',
        year: 2024,
      ).toJson();

      expect(json, {
        'track_id': _uuid,
        'title': 'Song',
        'source_type': 'LOCAL_UPLOAD',
        'artist_name': 'Artist',
        'year': 2024,
      });
      const forbidden = {
        'duration',
        'duration_ms',
        'mime_type',
        'codec',
        'container',
        'path',
        'file_path',
        'sample_rate',
        'size',
        'file_size',
        'hash',
        'sha256',
        'user_id',
        'custom_title',
        'source_provider',
      };
      expect(json.keys.toSet().intersection(forbidden), isEmpty);
    });

    test(
      'link imports are COMMUNITY_IMPORT with a provider and survive JSON',
      () {
        final manifest = TrackManifest(
          trackId: _uuid,
          title: 'Song',
          sourceProvider: communityProviderFor(SourceType.spotify),
        );
        final json = manifest.toJson();
        expect(json['source_type'], 'COMMUNITY_IMPORT');
        expect(json['source_provider'], 'spotify_match');

        final restored = TrackManifest.fromJson(json);
        expect(restored.sourceType, TrackSourceKind.communityImport);
        expect(restored.sourceProvider, 'spotify_match');
        expect(communityProviderFor(SourceType.localFile), isNull);
      },
    );

    test('control characters are removed and text limits enforced', () {
      final manifest = TrackManifest(
        trackId: _uuid,
        title: 'A\u0000B${'x' * 400}',
        artistName: '\n\t',
        genres: ['rock', '  ', 'jazz\u0007'],
      );
      expect(manifest.title.length, TrackManifest.maxTitleLength);
      expect(manifest.title.startsWith('A B'), isTrue);
      expect(manifest.artistName, isNull);
      expect(manifest.genres, ['rock', 'jazz']);
    });
  });

  group('multipart contract', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('owl-up'));
    tearDown(() => dir.delete(recursive: true));

    test('POST /v1/tracks: parts, manifest JSON, Idempotency-Key', () async {
      final audio = File('${dir.path}/song.flac')..writeAsBytesSync([1, 2]);
      final art = File('${dir.path}/cover.jpg')..writeAsBytesSync([3]);
      final cloud = FakeCloud(initialTokens: tokens());
      cloud.backend.on(
        'POST /v1/tracks',
        (_) => FakeReply(201, _trackJson(_uuid)),
      );
      final request = CloudUploadRequest(
        localId: 'l1',
        audioPath: audio.path,
        artworkPath: art.path,
        idempotencyKey: 'owlsonic-upload:0123456789abcdef',
        manifest: TrackManifest(trackId: _uuid, title: 'Song'),
      );

      final track = await OwlSonicTrackUploadRepository(
        cloud.client,
      ).upload(request);

      final recorded = cloud.backend.requests.single;
      expect(recorded.headers['Idempotency-Key'], request.idempotencyKey);
      expect(idempotencyKeyPattern.hasMatch(request.idempotencyKey), isTrue);
      expect(recorded.json['files'], {
        'manifest': {
          'filename': 'manifest.json',
          'contentType': 'application/json',
        },
        'audio': {'filename': 'song.flac', 'contentType': 'audio/flac'},
        'artwork': {'filename': 'cover.jpg', 'contentType': 'image/jpeg'},
      });
      final form = await OwlSonicTrackUploadRepository.buildForm(request);
      final bytes = await form.files
          .firstWhere((file) => file.key == 'manifest')
          .value
          .finalize()
          .expand((chunk) => chunk)
          .toList();
      expect(jsonDecode(utf8.decode(bytes)), {
        'track_id': _uuid,
        'title': 'Song',
        'source_type': 'LOCAL_UPLOAD',
      });
      expect(track.id, _uuid);
    });

    test('retry after a 401 refresh reuses the same Idempotency-Key', () async {
      final audio = File('${dir.path}/a.mp3')..writeAsBytesSync([1]);
      final cloud = FakeCloud(initialTokens: tokens());
      cloud.backend.on(
        'POST /v1/auth/refresh',
        (_) => FakeReply(200, credentials()),
      );
      cloud.backend.on(
        'POST /v1/tracks',
        (request) => request.bearer == 'access-2'
            ? FakeReply(201, _trackJson(_uuid))
            : FakeReply.error(401, 'UNAUTHORIZED'),
      );

      await OwlSonicTrackUploadRepository(cloud.client).upload(
        CloudUploadRequest(
          localId: 'l',
          audioPath: audio.path,
          idempotencyKey: 'owlsonic-upload:same-key-0001',
          manifest: TrackManifest(trackId: _uuid, title: 'a'),
        ),
      );

      expect(
        cloud.backend
            .to('POST /v1/tracks')
            .map((r) => r.headers['Idempotency-Key']),
        ['owlsonic-upload:same-key-0001', 'owlsonic-upload:same-key-0001'],
      );
    });
  });

  group('error codes', () {
    test('permanent codes fail per item with their own kind', () async {
      final codes = {
        'quota': (
          _error('STORAGE_QUOTA_EXCEEDED', status: 403),
          CloudUploadFailureKind.quotaExceeded,
        ),
        'big': (
          _error('AUDIO_TOO_LARGE', status: 413),
          CloudUploadFailureKind.audioTooLarge,
        ),
        'long': (
          _error('AUDIO_TOO_LONG', status: 422),
          CloudUploadFailureKind.audioTooLong,
        ),
        'bad': (
          _error('INVALID_AUDIO', status: 422),
          CloudUploadFailureKind.invalidAudio,
        ),
        'fmt': (
          _error('UNSUPPORTED_AUDIO_FORMAT', status: 415),
          CloudUploadFailureKind.unsupportedFormat,
        ),
        'art': (
          _error('INVALID_ARTWORK', status: 422),
          CloudUploadFailureKind.invalidArtwork,
        ),
        'key': (
          _error('IDEMPOTENCY_KEY_REUSED', status: 409),
          CloudUploadFailureKind.idempotencyKeyReused,
        ),
        'id': (
          _error('TRACK_ID_CONFLICT', status: 409),
          CloudUploadFailureKind.trackIdConflict,
        ),
      };
      final uploader = _Uploader({
        for (final entry in codes.entries) entry.key: [entry.value.$1],
      });

      final states = await CloudImportBatch(
        uploader: uploader,
        delay: (_) async {},
      ).run([for (final id in codes.keys) _request(id), _request('ok')]);

      for (final entry in codes.entries) {
        final state = states[entry.key]!;
        expect(state.phase, CloudUploadPhase.failed, reason: entry.key);
        expect(state.failureKind, entry.value.$2, reason: entry.key);
        expect(state.errorCode, entry.value.$1.code);
        expect(
          uploader.calls.where((c) => c.localId == entry.key),
          hasLength(1),
          reason: 'permanent ${entry.key} must not be retried',
        );
      }
      expect(states['ok']!.phase, CloudUploadPhase.succeeded);
    });

    test('retryable codes re-send the SAME request and key', () async {
      final delays = <Duration>[];
      final ids = ['busy', 'store', 'svc', 'rate', 'net'];
      final uploader = _Uploader({
        'busy': [_error('INGESTION_IN_PROGRESS', status: 409, retryable: true)],
        'store': [_error('STORAGE_UNAVAILABLE', status: 503, retryable: true)],
        'svc': [_error('SERVICE_UNAVAILABLE', status: 503, retryable: true)],
        'rate': [
          _error(
            'RATE_LIMITED',
            status: 429,
            retryable: true,
            retryAfter: const Duration(seconds: 7),
          ),
        ],
        'net': [
          const OwlSonicApiException(
            kind: OwlSonicApiErrorKind.network,
            code: 'timeout',
            message: 'timeout',
            retryable: true,
          ),
        ],
      });

      final states = await CloudImportBatch(
        uploader: uploader,
        delay: (d) async => delays.add(d),
      ).run([for (final id in ids) _request(id)]);

      for (final id in ids) {
        expect(states[id]!.phase, CloudUploadPhase.succeeded, reason: id);
        final attempts = uploader.calls.where((c) => c.localId == id).toList();
        expect(attempts, hasLength(2), reason: id);
        expect(attempts.map((c) => c.idempotencyKey).toSet(), hasLength(1));
        expect(attempts.map((c) => c.trackId).toSet(), hasLength(1));
      }
      expect(delays, contains(const Duration(seconds: 7)));
    });

    test('non-retryable SANITIZATION_FAILED is not retried', () async {
      final uploader = _Uploader({
        's': [_error('SANITIZATION_FAILED', status: 500)],
      });
      final states = await CloudImportBatch(
        uploader: uploader,
        delay: (_) async {},
      ).run([_request('s')]);
      expect(
        states['s']!.failureKind,
        CloudUploadFailureKind.sanitizationFailed,
      );
      expect(uploader.calls, hasLength(1));
    });

    test('concurrency is bounded; stop keeps completed uploads', () async {
      final uploader = _Uploader();
      late CloudImportBatch batch;
      batch = CloudImportBatch(
        uploader: uploader,
        concurrency: 2,
        delay: (_) async {},
        onUploaded: (track) {
          if (track.id == 'track-t1') batch.stop();
        },
      );
      final states = await batch.run([
        for (var i = 0; i < 6; i++) _request('t$i'),
      ]);
      expect(uploader.maxActive, 2);
      expect(states['t0']!.phase, CloudUploadPhase.succeeded);
      expect(
        states.values.where((s) => s.phase == CloudUploadPhase.skipped),
        isNotEmpty,
      );
    });
  });

  group('import service with local database', () {
    late AppDatabase db;
    late CloudUploadStore uploads;
    late CloudLocalStore local;
    late AuthSession session;
    late Directory dir;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      uploads = CloudUploadStore(db);
      local = CloudLocalStore(db);
      session = AuthSession(
        store: MemoryTokenStore()..tokens = tokens(),
        now: () => fakeNow,
      );
      await session.restore();
      dir = await Directory.systemTemp.createTemp('owl-import');
    });
    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    CloudImportService service(
      CloudTrackUploadRepository uploader, {
      void Function()? onChanged,
    }) => CloudImportService(
      session: session,
      configured: true,
      uploader: uploader,
      uploads: uploads,
      local: local,
      onLibraryChanged: onChanged,
      delay: (_) async {},
    );

    CloudImportSource source(String name) {
      final file = File('${dir.path}/$name.mp3')..writeAsBytesSync([1]);
      return CloudImportSource(
        key: file.path,
        audioPath: file.path,
        title: name,
        artistName: 'Unknown Artist',
        contentIdentity: 'sha256:$name',
      );
    }

    test('201: visible at once, analysis pending, sync requested', () async {
      var syncRequests = 0;
      final results = await service(
        _PathUploader(),
        onChanged: () => syncRequests++,
      ).importAll([source('song')]);

      expect(results.values.single.phase, CloudUploadPhase.succeeded);
      final track = await db.select(db.trackTable).getSingle();
      expect(track.sourceType, 'owlsonic');
      expect(track.title, 'song');
      expect(track.pathToFile, endsWith('song.mp3'));
      expect(track.id[14], '7', reason: 'UUIDv7 version nibble');
      final cloudRow = await db.select(db.cloudLibraryItemTable).getSingle();
      expect(cloudRow.analysisStatus, 'pending');
      expect(syncRequests, 1);
      final record = await db.select(db.cloudUploadTable).getSingle();
      expect(record.status, 'succeeded');
      expect(record.trackId, track.id);
      // The scanner's placeholder artist is not real catalog metadata.
      expect(
        (jsonDecode(record.manifestJson) as Map).containsKey('artist_name'),
        isFalse,
      );
    });

    test('same file keeps track id + key; another file gets new ones; '
        'pending uploads resume with the persisted key', () async {
      final a = source('a');
      final first = await uploads.createOrReuse(
        audioPath: a.audioPath,
        manifestFor: (id) => TrackManifest(trackId: id, title: 'a'),
      );
      await uploads.markFailed(
        first.id,
        code: 'STORAGE_UNAVAILABLE',
        message: null,
        retryable: true,
        attempts: 5,
      );
      final again = await uploads.createOrReuse(
        audioPath: a.audioPath,
        manifestFor: (id) => TrackManifest(trackId: id, title: 'a'),
      );
      final other = await uploads.createOrReuse(
        audioPath: source('b').audioPath,
        manifestFor: (id) => TrackManifest(trackId: id, title: 'b'),
      );

      expect(again.request.idempotencyKey, first.request.idempotencyKey);
      expect(again.request.trackId, first.request.trackId);
      expect(other.request.idempotencyKey, isNot(first.request.idempotencyKey));
      expect(other.request.trackId, isNot(first.request.trackId));

      final resumed = _PathUploader();
      await service(resumed).resumePending();
      expect(
        resumed.calls.map((c) => c.idempotencyKey),
        contains(first.request.idempotencyKey),
      );
    });

    test('TRACK_ID_CONFLICT retries once as a new logical upload', () async {
      final src = source('c');
      final uploader = _ConflictOnceUploader();

      final results = await service(uploader).importAll([src]);

      expect(results[src.key]!.phase, CloudUploadPhase.succeeded);
      expect(uploader.calls, hasLength(2));
      expect(uploader.calls[0].trackId, isNot(uploader.calls[1].trackId));
      expect(
        uploader.calls[0].idempotencyKey,
        isNot(uploader.calls[1].idempotencyKey),
      );
    });

    test('retryable failure stays resumable; quota failure is final', () async {
      final quota = source('q');
      final busy = source('busy');

      await service(
        _PathUploader({
          quota.audioPath: _error('STORAGE_QUOTA_EXCEEDED', status: 403),
          busy.audioPath: _error(
            'STORAGE_UNAVAILABLE',
            status: 503,
            retryable: true,
          ),
        }),
      ).importAll([quota, busy]);

      final statuses = {
        for (final row in await db.select(db.cloudUploadTable).get())
          row.audioPath: row.status,
      };
      expect(statuses[quota.audioPath], 'failed');
      expect(statuses[busy.audioPath], 'pending');
    });

    test('migration re-keys the local track and keeps the file', () async {
      final file = File('${dir.path}/old.mp3')..writeAsBytesSync([1]);
      await db
          .into(db.trackTable)
          .insert(
            TrackTableCompanion.insert(
              id: 'abcd1234',
              title: 'Old',
              sourceType: 'localFile',
              sourceUri: file.path,
              pathToFile: Value(file.path),
            ),
          );
      await db
          .into(db.playlistTable)
          .insert(
            PlaylistTableCompanion.insert(
              id: 'p',
              name: 'Mine',
              createdAt: fakeNow,
            ),
          );
      await db
          .into(db.playlistTrackTable)
          .insert(
            PlaylistTrackTableCompanion.insert(
              playlistId: 'p',
              trackId: 'abcd1234',
              position: 0,
            ),
          );
      expect(await uploads.migrationCandidates(), hasLength(1));

      await service(_PathUploader()).importAll([
        CloudImportSource(
          key: 'abcd1234',
          audioPath: file.path,
          title: 'Old',
          sourceTrackId: 'abcd1234',
        ),
      ]);

      final track = await db.select(db.trackTable).getSingle();
      expect(track.id, isNot('abcd1234'));
      expect(track.sourceType, 'owlsonic');
      expect(track.pathToFile, file.path);
      expect(file.existsSync(), isTrue);
      final ref = await db.select(db.playlistTrackTable).getSingle();
      expect(ref.trackId, track.id);
      expect(await uploads.migrationCandidates(), isEmpty);
    });

    test(
      'downloaded link imports are migration candidates and re-key',
      () async {
        final file = File('${dir.path}/soundcloud_1.mp3')
          ..writeAsBytesSync([1]);
        Future<void> insert(String id, String sourceType, String? path) => db
            .into(db.trackTable)
            .insert(
              TrackTableCompanion.insert(
                id: id,
                title: id,
                sourceType: sourceType,
                sourceUri: 'https://soundcloud.com/a/$id',
                pathToFile: Value(path),
              ),
            );
        await insert('sc1', 'soundcloud', file.path);
        await insert('pending', 'soundcloud', null); // not downloaded yet
        await insert('cloud', 'owlsonic', file.path); // already in the cloud

        expect((await uploads.migrationCandidates()).map((row) => row.id), [
          'sc1',
        ]);

        await service(_PathUploader()).importAll([
          CloudImportSource(
            key: 'sc1',
            audioPath: file.path,
            title: 'sc1',
            sourceTrackId: 'sc1',
          ),
        ]);

        final ids = (await db.select(db.trackTable).get()).map((t) => t.id);
        expect(ids, isNot(contains('sc1')));
        expect(ids, containsAll(['pending', 'cloud']));
        expect(await uploads.migrationCandidates(), isEmpty);
      },
    );
  });
}
