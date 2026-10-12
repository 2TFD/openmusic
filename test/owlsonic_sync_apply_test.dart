import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/cloud/sync_engine.dart';
import 'package:owlsonic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:owlsonic/core/services/recommendation/audio_wave_support.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/remote/owlsonic/owlsonic_sync_parser.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';
import 'package:owlsonic/layers/data/repositories/mood_map_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_embedding_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_emotion_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_temporal_embedding_repository_impl.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_sync_events.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

const t1 = '018f2c3a-0000-7000-8000-000000000001';
const t2 = '018f2c3a-0000-7000-8000-000000000002';
const p1 = '018f2c3a-0000-7000-8000-0000000000a1';
const i1 = '018f2c3a-0000-7000-8000-0000000000b1';
const i2 = '018f2c3a-0000-7000-8000-0000000000b2';
const e1 = '018f2c3a-0000-7000-8000-0000000000c1';

SyncEvent ev(
  String type,
  int version,
  Map<String, dynamic> payload, {
  String? id,
  String entity = t1,
}) => SyncEvent(
  id: id,
  type: type,
  version: version,
  entityId: entity,
  payload: payload,
  createdAt: null,
);

Map<String, dynamic> libraryV1({
  String trackId = t1,
  String status = 'pending',
  String? customTitle,
}) => {
  'track_id': trackId,
  'canonical_title': 'Canon',
  'canonical_artist_name': 'Artist',
  'canonical_album_title': 'Album',
  'album_artist': null,
  'track_number': 1,
  'disc_number': null,
  'year': 2024,
  'genres': ['ambient'],
  'duration_ms': 200000,
  'has_artwork': true,
  'analysis_status': status,
  'custom_title': customTitle,
  'custom_artist_name': null,
  'custom_album_title': null,
  'added_at': '2026-10-01T10:00:00Z',
  'updated_at': '2026-10-01T10:00:00Z',
};

Map<String, dynamic> libraryV2({
  String trackId = t1,
  String status = 'pending',
  String? customTitle,
  bool favorite = false,
  double? customValence,
  double? customArousal,
  int playCount = 0,
}) => {
  ...libraryV1(trackId: trackId, status: status, customTitle: customTitle),
  'favorite': favorite,
  'custom_valence': customValence,
  'custom_arousal': customArousal,
  'play_count': playCount,
  'last_played_at': null,
};

Map<String, dynamic> analysisReady({
  String trackId = t1,
  int version = 1,
  double valence = 0.3,
  double arousal = -0.2,
  List<double> embedding = const [0.6, 0.8],
  String model = 'clap',
  String embeddingVersion = 'v1',
  int? dimension,
}) => {
  'track_id': trackId,
  'analysis_status': 'ready',
  'audio_embedding': embedding,
  'embedding_dimension': dimension ?? embedding.length,
  'embedding_model': model,
  'embedding_version': embeddingVersion,
  'analysis_version': version,
  'valence': valence,
  'arousal': arousal,
  'emotion_version': 'emo-1',
};

SyncPage page(
  List<SyncEvent> events, {
  SyncMode mode = SyncMode.delta,
  String next = 'c',
  bool more = false,
}) => SyncPage(mode: mode, events: events, nextCursor: next, hasMore: more);

void main() {
  const parser = OwlSonicSyncParser();

  group('parser by (type, version)', () {
    test('every published pair parses', () {
      expect(
        parser.parse(ev('library.upsert', 1, libraryV1())),
        isA<LibraryUpsertSyncEvent>().having(
          (e) => e.hasPersonalState,
          'personal',
          isFalse,
        ),
      );
      expect(
        parser.parse(ev('library.upsert', 2, libraryV2(favorite: true))),
        isA<LibraryUpsertSyncEvent>()
            .having((e) => e.hasPersonalState, 'personal', isTrue)
            .having((e) => e.item.favorite, 'favorite', isTrue),
      );
      expect(
        parser.parse(
          ev('library.delete', 1, {
            'track_id': t1,
            'deleted_at': '2026-10-02T00:00:00Z',
          }),
        ),
        isA<LibraryDeleteSyncEvent>(),
      );
      expect(
        parser.parse(ev('analysis.upsert', 1, analysisReady())),
        isA<AnalysisUpsertSyncEvent>().having((e) => e.failed, 'f', isFalse),
      );
      expect(
        parser.parse(
          ev('analysis.upsert', 1, {
            'track_id': t1,
            'analysis_status': 'failed',
          }),
        ),
        isA<AnalysisUpsertSyncEvent>().having((e) => e.failed, 'f', isTrue),
      );
      expect(
        parser.parse(
          ev('playlist.upsert', 1, {
            'playlist_id': p1,
            'name': 'Night',
            'created_at': '2026-10-01T00:00:00Z',
            'updated_at': '2026-10-01T00:00:00Z',
          }),
        ),
        isA<PlaylistUpsertSyncEvent>(),
      );
      expect(
        parser.parse(
          ev('playlist.delete', 1, {
            'playlist_id': p1,
            'deleted_at': '2026-10-01T00:00:00Z',
          }),
        ),
        isA<PlaylistDeleteSyncEvent>(),
      );
      expect(
        parser.parse(
          ev('playlist.items', 1, {
            'playlist_id': p1,
            'updated_at': '2026-10-01T00:00:00Z',
            'items': [
              {'item_id': i1, 'track_id': t1, 'position': 0},
            ],
          }),
        ),
        isA<PlaylistItemsSyncEvent>(),
      );
      expect(
        parser.parse(
          ev('history.append', 1, {
            'event_id': e1,
            'track_id': t1,
            'played_at': '2026-10-02T00:00:00Z',
            'listened_ms': 120000,
            'play_count': 4,
            'last_played_at': '2026-10-02T00:00:00Z',
          }),
        ),
        isA<HistoryAppendSyncEvent>(),
      );
    });

    test('unknown type, unknown version and malformed payload reject', () {
      expect(
        () => parser.parse(ev('library.archive', 1, const {})),
        throwsA(isA<SyncEventRejected>()),
      );
      expect(
        () => parser.parse(ev('library.upsert', 3, libraryV2())),
        throwsA(isA<SyncEventRejected>()),
      );
      expect(
        () => parser.parse(ev('library.upsert', 2, {'track_id': t1})),
        throwsA(
          isA<SyncEventRejected>().having(
            (e) => e.reason,
            'reason',
            startsWith('malformed'),
          ),
        ),
      );
      expect(
        () =>
            parser.parse(ev('analysis.upsert', 1, analysisReady(dimension: 3))),
        throwsA(isA<SyncEventRejected>()),
        reason: 'embedding length must equal embedding_dimension',
      );
      expect(
        () => parser.parse(
          ev('analysis.upsert', 1, {
            'track_id': t1,
            'analysis_status': 'pending',
          }),
        ),
        throwsA(isA<SyncEventRejected>()),
        reason: 'pending is never an analysis event',
      );
    });
  });

  group('local apply', () {
    late AppDatabase db;
    late CloudLocalStore store;
    late MusicAnalysisModelRegistry registry;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      store = CloudLocalStore(db);
      registry = MusicAnalysisModelRegistry(cloudModels: store.cloudModels);
    });
    tearDown(() => db.close());

    Future<TrackTableData?> track(String id) => (db.select(
      db.trackTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    Future<CloudLibraryItemTableData?> cloudRow(String id) => (db.select(
      db.cloudLibraryItemTable,
    )..where((t) => t.trackId.equals(id))).getSingleOrNull();

    MoodMapRepositoryImpl moodMap() => MoodMapRepositoryImpl(
      database: db,
      tracks: TrackRepositoryImpl(localDataSource: TrackDriftLocalSource(db)),
      emotions: TrackEmotionRepositoryImpl(db),
      registry: registry,
    );

    test(
      'library.upsert v2 populates the Library with effective metadata',
      () async {
        await store.apply(
          page([ev('library.upsert', 2, libraryV2(customTitle: 'Mine'))]),
        );

        final row = await track(t1);
        expect(row!.title, 'Mine');
        expect(row.sourceType, 'owlsonic');
        expect(row.pathToFile, isNull);
        expect(row.imageUrl, cloudArtworkUri(t1));
        final cloud = await cloudRow(t1);
        expect(cloud!.canonicalTitle, 'Canon');
        expect(cloud.analysisStatus, 'pending');
        final tracks = await TrackRepositoryImpl(
          localDataSource: TrackDriftLocalSource(db),
        ).getTracks();
        expect(tracks.single.isReadyToPlay, isTrue);
        expect(tracks.single.artists.single.name, 'Artist');
      },
    );

    test('library.upsert v1 keeps known personal state', () async {
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2(favorite: true, playCount: 5)),
        ]),
      );
      await store.apply(page([ev('library.upsert', 1, libraryV1())]));

      final cloud = await cloudRow(t1);
      expect(cloud!.favorite, isTrue);
      expect(cloud.playCount, 5);
    });

    test('pending → ready → newer ready; older replay ignored', () async {
      await store.apply(page([ev('library.upsert', 2, libraryV2())]));
      expect((await moodMap().loadTracks()), isEmpty, reason: 'pending');

      await store.apply(
        page([
          ev('analysis.upsert', 1, analysisReady(version: 1, valence: 0.1)),
        ]),
      );
      var placed = await moodMap().loadTracks();
      expect(placed.single.valence, 0.1);
      expect((await cloudRow(t1))!.analysisStatus, 'ready');

      await store.apply(
        page([
          ev('analysis.upsert', 1, analysisReady(version: 2, valence: 0.5)),
        ]),
      );
      await store.apply(
        page([
          ev('analysis.upsert', 1, analysisReady(version: 1, valence: 0.1)),
        ]),
      );
      placed = await moodMap().loadTracks();
      expect(placed.single.valence, 0.5);
      expect(placed.single.modelAnalysis.moodDistribution, isNull);
    });

    test(
      'ready → failed drops analysis; failed → later ready restores',
      () async {
        await store.apply(
          page([
            ev('library.upsert', 2, libraryV2()),
            ev('analysis.upsert', 1, analysisReady()),
          ]),
        );
        await store.apply(
          page([
            ev('analysis.upsert', 1, {
              'track_id': t1,
              'analysis_status': 'failed',
            }),
          ]),
        );
        expect(
          await moodMap().loadTracks(),
          isEmpty,
          reason: 'no fake placement',
        );
        expect((await cloudRow(t1))!.analysisStatus, 'failed');
        expect(await db.select(db.trackEmbeddingTable).get(), isEmpty);

        await store.apply(page([ev('analysis.upsert', 1, analysisReady())]));
        expect(await moodMap().loadTracks(), hasLength(1));
        expect((await cloudRow(t1))!.analysisStatus, 'ready');
      },
    );

    test('replayed page is idempotent', () async {
      final events = page([
        ev('library.upsert', 2, libraryV2()),
        ev('analysis.upsert', 1, analysisReady()),
      ]);
      await store.apply(events);
      await store.apply(events);
      expect(await db.select(db.trackTable).get(), hasLength(1));
      expect(await db.select(db.trackEmbeddingTable).get(), hasLength(1));
      expect(await db.select(db.trackEmotionAnalysisTable).get(), hasLength(1));
    });

    test('custom valence/arousal are personal; canonical stays', () async {
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2(customValence: 0.9)),
          ev('analysis.upsert', 1, analysisReady(valence: 0.3, arousal: -0.2)),
        ]),
      );
      final entry = (await moodMap().loadTracks()).single;
      expect(entry.modelAnalysis.valence, 0.3, reason: 'canonical untouched');
      expect(entry.valence, 0.9, reason: 'custom wins');
      expect(entry.arousal, -0.2, reason: 'canonical for the other axis');
      final canonical = await db.select(db.cloudAnalysisTable).getSingle();
      expect(canonical.valence, 0.3);

      await store.apply(page([ev('library.upsert', 2, libraryV2())]));
      final reset = (await moodMap().loadTracks()).single;
      expect(reset.hasPersonalPosition, isFalse);
      expect(reset.valence, 0.3);
    });

    test('Wave receives the synced embedding', () async {
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2()),
          ev('analysis.upsert', 1, analysisReady(embedding: const [0.6, 0.8])),
        ]),
      );
      final data = await AudioWaveDataLoader(
        tracks: TrackRepositoryImpl(localDataSource: TrackDriftLocalSource(db)),
        globals: TrackEmbeddingRepositoryImpl(db),
        temporals: TrackTemporalEmbeddingRepositoryImpl(db),
        registry: registry,
      ).load();
      // Stored as float32, like every embedding in the local database.
      final vector = data.globals[t1]!.vector;
      expect(vector[0], closeTo(0.6, 1e-6));
      expect(vector[1], closeTo(0.8, 1e-6));
    });

    test('cloud analysis is authoritative over legacy descriptors', () async {
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2()),
          ev('analysis.upsert', 1, analysisReady(model: 'clap-x')),
        ]),
      );
      final models = await registry.getModels();
      expect(models.schemaVersion, 'owlsonic-cloud');
      expect(models.models.first.modelId, 'clap-x');
    });

    test('library.delete removes track, playlist refs and analysis', () async {
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2()),
          ev('analysis.upsert', 1, analysisReady()),
          ev('playlist.upsert', 1, {
            'playlist_id': p1,
            'name': 'Night',
            'created_at': '2026-10-01T00:00:00Z',
            'updated_at': '2026-10-01T00:00:00Z',
          }),
          ev('playlist.items', 1, {
            'playlist_id': p1,
            'updated_at': '2026-10-01T00:00:00Z',
            'items': [
              {'item_id': i1, 'track_id': t1, 'position': 0},
            ],
          }),
          ev('library.delete', 1, {
            'track_id': t1,
            'deleted_at': '2026-10-02T00:00:00Z',
          }),
        ]),
      );
      expect(await track(t1), isNull);
      expect(await db.select(db.cloudPlaylistItemTable).get(), isEmpty);
      expect(await db.select(db.playlistTrackTable).get(), isEmpty);
      expect(await db.select(db.cloudAnalysisTable).get(), isEmpty);
      expect(await db.select(db.trackEmbeddingTable).get(), isEmpty);
      expect(await db.select(db.playlistTable).get(), hasLength(1));
    });

    test(
      'playlist upsert/items/delete converge; items replace whole list',
      () async {
        await store.apply(
          page([
            ev('library.upsert', 2, libraryV2()),
            ev('library.upsert', 2, libraryV2(trackId: t2), entity: t2),
            ev('playlist.upsert', 1, {
              'playlist_id': p1,
              'name': 'Night',
              'created_at': '2026-10-01T00:00:00Z',
              'updated_at': '2026-10-01T00:00:00Z',
            }),
            ev('playlist.items', 1, {
              'playlist_id': p1,
              'updated_at': '2026-10-01T00:00:00Z',
              'items': [
                {'item_id': i1, 'track_id': t1, 'position': 0},
                {'item_id': i2, 'track_id': t2, 'position': 1},
              ],
            }),
          ]),
        );
        await store.apply(
          page([
            ev('playlist.items', 1, {
              'playlist_id': p1,
              'updated_at': '2026-10-02T00:00:00Z',
              'items': [
                {'item_id': i2, 'track_id': t2, 'position': 0},
              ],
            }),
          ]),
        );
        final refs = await db.select(db.playlistTrackTable).get();
        expect(refs.map((r) => r.trackId), [t2]);
        expect(await store.isCloudPlaylist(p1), isTrue);

        await store.apply(
          page([
            ev('playlist.delete', 1, {
              'playlist_id': p1,
              'deleted_at': '2026-10-03T00:00:00Z',
            }),
          ]),
        );
        expect(await db.select(db.playlistTable).get(), isEmpty);
        expect(await db.select(db.cloudPlaylistItemTable).get(), isEmpty);
      },
    );

    test(
      'history.append is idempotent by event_id with the local play',
      () async {
        await store.apply(page([ev('library.upsert', 2, libraryV2())]));
        // The local player already recorded this play with the same id.
        await db
            .into(db.listeningSummaryTable)
            .insert(
              ListeningSummaryTableCompanion.insert(
                id: e1,
                trackId: t1,
                trackTitle: 'Canon',
                artistName: 'Artist',
                sourceType: 'owlsonic',
                listenedDurationMilliseconds: 120000,
                playedAt: DateTime.utc(2026, 10, 2),
              ),
            );
        final append = ev('history.append', 1, {
          'event_id': e1,
          'track_id': t1,
          'played_at': '2026-10-02T00:00:00Z',
          'listened_ms': 120000,
          'play_count': 4,
          'last_played_at': '2026-10-02T00:00:00Z',
        });
        await store.apply(page([append]));
        await store.apply(page([append]));

        expect(await db.select(db.listeningSummaryTable).get(), hasLength(1));
        expect((await cloudRow(t1))!.playCount, 4);
      },
    );

    test('a page with an unknown event writes nothing', () async {
      await expectLater(
        store.apply(
          page([
            ev('library.upsert', 2, libraryV2()),
            ev('library.archive', 1, const {}),
          ]),
        ),
        throwsA(isA<SyncEventRejected>()),
      );
      expect(await db.select(db.trackTable).get(), isEmpty);
    });

    test('complete snapshot sweeps cloud rows that no longer exist', () async {
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2()),
          ev('library.upsert', 2, libraryV2(trackId: t2), entity: t2),
        ]),
      );
      store.beginSnapshot();
      await store.apply(
        page(
          [ev('library.upsert', 2, libraryV2(trackId: t2), entity: t2)],
          mode: SyncMode.snapshot,
          more: false,
        ),
      );
      expect(await track(t1), isNull);
      expect(await track(t2), isNotNull);
    });

    test('purge isolates accounts and keeps local-only tracks', () async {
      await db
          .into(db.trackTable)
          .insert(
            TrackTableCompanion.insert(
              id: 'local01',
              title: 'Local',
              sourceType: 'localFile',
              sourceUri: '/x.mp3',
              pathToFile: const Value('x.mp3'),
            ),
          );
      await store.apply(
        page([
          ev('library.upsert', 2, libraryV2()),
          ev('analysis.upsert', 1, analysisReady()),
        ]),
      );

      await store.purgeCloudData();

      final rows = await db.select(db.trackTable).get();
      expect(rows.map((r) => r.id), ['local01']);
      expect(await db.select(db.cloudLibraryItemTable).get(), isEmpty);
      expect(await registry.getModels(), MusicAnalysisModelRegistry.empty);
    });
  });

  group('engine + store: cursor safety', () {
    test(
      'cursor does not advance past a page that cannot be applied',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final cursors = _Cursors()..value = 'c0';
        final engine = SyncEngine(
          remote: _Remote({
            'c0': page(
              [ev('library.upsert', 2, libraryV2())],
              next: 'c1',
              more: true,
            ),
            'c1': page([ev('analysis.upsert', 9, analysisReady())], next: 'c2'),
          }),
          cursors: cursors,
          applier: CloudLocalStore(db),
        );

        await expectLater(engine.run(), throwsA(isA<SyncEventRejected>()));

        expect(cursors.value, 'c1');
        expect(await db.select(db.trackTable).get(), hasLength(1));
      },
    );
  });
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

class _Remote implements CloudSyncRepository {
  _Remote(this.pages);
  final Map<String?, SyncPage> pages;
  @override
  Future<SyncPage> pull({String? cursor, int? limit}) async => pages[cursor]!;
}
