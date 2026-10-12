// Real-backend smoke test. Opt-in only; never runs in the normal suite:
//
//   flutter test test/smoke/owlsonic_backend_smoke_test.dart \
//     --dart-define=OWLSONIC_SMOKE_BASE_URL=https://api.example
//
// Registers a throwaway account, exercises the real client pipeline and
// deletes the account at the end. Never prints tokens or signed URLs.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/config/owlsonic_api_config.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_client.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/audio_player/cloud_stream_audio_source.dart';
import 'package:owlsonic/core/services/cloud/cloud_import_service.dart';
import 'package:owlsonic/core/services/cloud/cloud_playback_source.dart';
import 'package:owlsonic/core/services/cloud/play_event_queue.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/cloud_upload_store.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_cloud_repositories.dart';
import 'package:owlsonic/layers/data/repositories/owlsonic_track_upload_repository.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:uuid/uuid.dart';

import '../support/fake_owlsonic_backend.dart'
    show
        MemoryInstallationIdStorage,
        MemoryPendingVerificationStore,
        MemoryTokenStore;

const _baseUrl = String.fromEnvironment('OWLSONIC_SMOKE_BASE_URL');
const _analysisWait = Duration(
  seconds: int.fromEnvironment(
    'OWLSONIC_SMOKE_ANALYSIS_SECONDS',
    defaultValue: 240,
  ),
);

final _started = DateTime.now();
void step(String message) {
  final t = DateTime.now().difference(_started).inMilliseconds / 1000;
  // ignore: avoid_print
  print('[smoke ${t.toStringAsFixed(1)}s] $message');
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

class _PlayEvents implements PlayEventStore {
  List<PlayEvent> events = [];
  @override
  Future<List<PlayEvent>> load() async => List.of(events);
  @override
  Future<void> save(List<PlayEvent> next) async => events = List.of(next);
}

/// 3 s, 440 Hz, 16-bit mono WAV.
Uint8List _wav() {
  const rate = 22050;
  const seconds = 3;
  const samples = rate * seconds;
  final data = ByteData(44 + samples * 2);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, samples * 2, Endian.little);
  for (var i = 0; i < samples; i++) {
    final v = (math.sin(2 * math.pi * 440 * i / rate) * 12000).round();
    data.setInt16(44 + i * 2, v, Endian.little);
  }
  return data.buffer.asUint8List();
}

/// Minimal valid 1x1 PNG.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB0, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  test(
    'OwlSonic backend smoke',
    () async {
      final dir = await Directory.systemTemp.createTemp('owl-smoke');
      final db = AppDatabase(NativeDatabase.memory());
      final session = AuthSession(store: MemoryTokenStore());
      await session.restore();
      final client = OwlSonicApiClient(
        config: OwlSonicApiConfig(
          environment: OwlSonicEnvironment.production,
          baseUrl: _baseUrl,
        ),
        session: session,
      );
      final auth = OwlSonicAuthRepository(
        client: client,
        identity: InstallationIdentity(storage: MemoryInstallationIdStorage()),
        pending: MemoryPendingVerificationStore(),
        appVersion: 'smoke-test',
      );
      final account = OwlSonicAccountRepository(client);
      final library = OwlSonicLibraryRepository(client);
      final store = CloudLocalStore(db);
      final cursors = _Cursors();
      final engine = SyncEngine(
        remote: OwlSonicSyncRepository(client),
        cursors: cursors,
        applier: store,
      );
      var accountCreated = false;
      String? password;

      try {
        // ── auth ──
        final email =
            'owlsonic-smoke+${DateTime.now().millisecondsSinceEpoch}@example.com';
        password = 'Smoke-${const Uuid().v4()}';
        await auth.register(email: email, password: password);
        step('register 201: signed in = ${session.isSignedIn}');
        // Registration now needs an emailed code, which a smoke run cannot
        // read. The unverified throwaway account is left to server cleanup.
        if (!session.isSignedIn) {
          markTestSkipped('register requires e-mail verification');
          return;
        }
        accountCreated = true;
        final me = await account.me();
        step('GET /v1/me: id=${me.id}');
        final usage = await account.usage();
        step(
          'GET /v1/me/usage: used=${usage.usedBytes} '
          'limit=${usage.limitBytes} unlimited=${usage.unlimited}',
        );
        final devices = await account.devices();
        step(
          'GET /v1/devices: ${devices.length} device(s), '
          'current=${devices.where((d) => d.current).length}',
        );

        // ── bootstrap ──
        store.beginSnapshot();
        final boot = await engine.run();
        step(
          'GET /v1/sync bootstrap: pages=${boot.pages} events=${boot.events} '
          'cursor persisted=${cursors.value != null}',
        );

        // ── import ──
        final audio = File('${dir.path}/owlsonic-smoke.wav')
          ..writeAsBytesSync(_wav());
        final artwork = File('${dir.path}/cover.png')..writeAsBytesSync(_png);
        final importer = CloudImportService(
          session: session,
          configured: true,
          uploader: OwlSonicTrackUploadRepository(client),
          uploads: CloudUploadStore(db),
          local: store,
        );
        final results = await importer.importAll([
          CloudImportSource(
            key: 'smoke',
            audioPath: audio.path,
            title: 'OwlSonic smoke test tone',
            artistName: 'OwlSonic Smoke',
            artworkPath: artwork.path,
          ),
        ]);
        final upload = results['smoke']!;
        step(
          'POST /v1/tracks: ${upload.phase.name} attempt=${upload.attempt} '
          'code=${upload.errorCode} request_id=${upload.requestId}',
        );
        expect(upload.phase, CloudUploadPhase.succeeded);
        final trackId = upload.track!.id;
        step(
          'TrackResponse: id=$trackId duration=${upload.track!.duration} '
          'has_artwork=${upload.track!.hasArtwork}',
        );
        final localRow = await db.select(db.trackTable).getSingle();
        step(
          'local library after 201: ${localRow.title} (${localRow.sourceType})',
        );

        // Idempotent replay: same key + same content → original 201.
        final record = await CloudUploadStore(db).byTrackId(trackId);
        final replay = await OwlSonicTrackUploadRepository(
          client,
        ).upload(record!.request);
        step('replay with same Idempotency-Key: id=${replay.id}');
        expect(replay.id, trackId);

        // ── delta: library.upsert / pending ──
        final delta = await engine.run();
        final cloudRow = await (db.select(
          db.cloudLibraryItemTable,
        )..where((t) => t.trackId.equals(trackId))).getSingle();
        step(
          'GET /v1/sync delta: events=${delta.events}, '
          'analysis_status=${cloudRow.analysisStatus}',
        );

        // ── analysis.upsert (async ML) ──
        final deadline = DateTime.now().add(_analysisWait);
        var status = cloudRow.analysisStatus;
        while (status == 'pending' && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(seconds: 10));
          await engine.run();
          status =
              (await (db.select(
                    db.cloudLibraryItemTable,
                  )..where((t) => t.trackId.equals(trackId))).getSingle())
                  .analysisStatus;
        }
        final analysis = await (db.select(
          db.cloudAnalysisTable,
        )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
        step(
          'analysis after ${DateTime.now().difference(_started).inSeconds}s: '
          'status=$status'
          '${analysis == null ? '' : ' model=${analysis.embeddingModel} '
                    'dim=${analysis.embeddingDimension} '
                    'v=${analysis.analysisVersion} '
                    'valence=${analysis.valence.toStringAsFixed(3)} '
                    'arousal=${analysis.arousal.toStringAsFixed(3)}'}',
        );
        final models = await store.cloudModels();
        step(
          'registry from synced analysis: ${models?.models.length ?? 0} model(s)',
        );

        // ── playback ──
        final selector = CloudPlaybackSourceSelector(
          playbackUrls: SignedUrlCache(fetch: library.playbackUrl),
        );
        final signed = await library.playbackUrl(trackId);
        step(
          'POST /v1/library/{id}/playback: host=${signed.url.host} '
          'expires_at=${signed.expiresAt.toIso8601String()}',
        );
        final source = CloudStreamAudioSource(
          trackId: trackId,
          localPath: null,
          selector: selector,
        );
        final head = await source.request(0, 4096);
        final bytes = await head.stream.expand((c) => c).toList();
        step(
          'stream through player source: ${bytes.length} bytes, '
          'content-type=${head.contentType}, total=${head.sourceLength}',
        );
        expect(bytes, isNotEmpty);

        // ── artwork ──
        try {
          final art = await library.artworkUrl(trackId);
          final response = await Dio().get<List<int>>(
            art.url.toString(),
            options: Options(responseType: ResponseType.bytes),
          );
          step(
            'GET /v1/library/{id}/artwork: ${response.statusCode}, '
            '${response.data?.length} bytes',
          );
        } on OwlSonicApiException catch (error) {
          step('artwork: ${error.code} (${error.statusCode})');
        }

        // ── history ──
        final queue = PlayEventQueue(
          store: _PlayEvents(),
          history: OwlSonicHistoryRepository(client),
        );
        final event = await queue.record(
          trackId: trackId,
          playedAt: DateTime.now().toUtc(),
          listened: const Duration(seconds: 3),
        );
        final flushed = await queue.flush();
        final again = await OwlSonicHistoryRepository(client).submit([event]);
        step(
          'POST /v1/history/events: flushed=$flushed, '
          'resubmit accepted=${again.accepted} duplicates=${again.duplicates}',
        );
        await engine.run();
        final plays = await db.select(db.listeningSummaryTable).get();
        step('history.append via sync: local rows=${plays.length}');

        // ── playlist ──
        final playlists = OwlSonicPlaylistRepository(client);
        final playlistId = const Uuid().v7();
        await playlists.create(id: playlistId, name: 'Smoke');
        await playlists.addItem(
          playlistId,
          itemId: const Uuid().v7(),
          trackId: trackId,
        );
        await engine.run();
        final refs = await db.select(db.playlistTrackTable).get();
        step('playlist create + item via sync: local refs=${refs.length}');
        await playlists.delete(playlistId);

        // ── library delete ──
        await library.delete(trackId);
        await engine.run();
        step(
          'DELETE /v1/library/{id} + library.delete via sync: '
          'local tracks=${(await db.select(db.trackTable).get()).length}',
        );
      } on OwlSonicApiException catch (error) {
        step(
          'FAILED: ${error.code} HTTP ${error.statusCode} '
          'request_id=${error.requestId}: ${error.message} '
          'details=${error.details}',
        );
        rethrow;
      } finally {
        // Always remove the throwaway account, also after a failure.
        if (accountCreated && password != null) {
          try {
            final deleted = await account.deleteAccount(password: password);
            accountCreated = false;
            step('DELETE /v1/me: $deleted');
          } catch (error) {
            step('WARNING: smoke account cleanup failed: $error');
          }
        }
        await db.close();
        await dir.delete(recursive: true);
      }
    },
    skip: _baseUrl.isEmpty ? 'set OWLSONIC_SMOKE_BASE_URL to run' : false,
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
