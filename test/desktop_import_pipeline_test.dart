import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/errors/failures/failure.dart';
import 'package:owlsonic/core/services/track_identity/sha256_track_content_identity_service.dart';
import 'package:owlsonic/core/services/track_source_resolver.dart';
import 'package:owlsonic/core/telemetry/analytics_tracker.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:owlsonic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_duplicate_lookup_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:owlsonic/layers/data/repositories/track_repository_impl.dart';
import 'package:owlsonic/layers/domain/entities/import_candidate.dart';
import 'package:owlsonic/layers/domain/entities/operation_cancellation.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/repositories/local_file_scanner.dart';
import 'package:owlsonic/layers/domain/repositories/track_source.dart';
import 'package:owlsonic/layers/domain/usecases/add_track_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/get_tracks_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/import_local_track_item_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/remove_track_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/search_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/update_track_use_case.dart';
import 'package:owlsonic/layers/domain/usecases/scan_local_import_use_case.dart';
import 'package:owlsonic/layers/presentation/features/import_music/bloc/import_workspace/import_workspace_cubit.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:path/path.dart' as p;

/// End-to-end desktop import against a real in-memory database and real files,
/// with only ffprobe (metadata) and the file copy faked.
void main() {
  late Directory dir;
  late AppDatabase database;
  late TrackRepositoryImpl tracks;
  late _FakeLocalSource source;
  late ImportWorkspaceCubit cubit;
  late AddTrackUseCase addTrack;

  File write(String name, String content) =>
      File(p.join(dir.path, name))..writeAsStringSync(content);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('owlsonic_import_test');
    database = AppDatabase(NativeDatabase.memory());
    final local = TrackDriftLocalSource(database);
    tracks = TrackRepositoryImpl(localDataSource: local);
    final duplicates = TrackDuplicateLookupImpl(
      database: database,
      trackLocalDataSource: local,
    );
    source = _FakeLocalSource();
    const identity = Sha256TrackContentIdentityService();
    addTrack = AddTrackUseCase(
      analytics: const NoopAnalyticsTracker(),
      trackResolver: TrackSourceResolver([source]),
      trackRepository: tracks,
      ingestionRepository: TrackIngestionRepositoryImpl(
        database: database,
        trackLocalDataSource: local,
      ),
      playlistRepository: PlaylistRepositoryImpl(
        localDataSource: PlaylistDriftLocalSource(database),
      ),
      contentIdentityService: identity,
      duplicateLookup: duplicates,
    );
    cubit = ImportWorkspaceCubit(
      scan: ScanLocalImportUseCase(
        scanner: source,
        identity: identity,
        duplicates: duplicates,
        tracks: tracks,
      ),
      importItem: ImportLocalTrackItemUseCase(addTrack.addResolved),
    );
  });

  tearDown(() async {
    await cubit.close();
    await database.close();
    dir.deleteSync(recursive: true);
  });

  ImportCandidate item(String name) =>
      cubit.state.items.firstWhere((i) => p.basename(i.path) == name);

  test(
    'scan classifies ready, duplicate, invalid and unsupported files',
    () async {
      final a = write('a.mp3', 'song-x');
      final sameAsA = write('a_copy.mp3', 'song-x');
      final b = write('b.mp3', 'song-y');
      final corrupt = write('corrupt.mp3', 'broken');
      final notAudio = write('notes.txt', 'hello');
      source.unreadable.add(corrupt.path);

      await cubit.addPaths([
        a.path,
        sameAsA.path,
        b.path,
        corrupt.path,
        notAudio.path,
      ]);

      expect(cubit.state.phase, ImportPhase.review);
      expect(item('a.mp3').status, ImportItemStatus.ready);
      expect(item('b.mp3').status, ImportItemStatus.ready);
      expect(item('a_copy.mp3').status, ImportItemStatus.duplicate);
      expect(item('a_copy.mp3').duplicateOfTrackId, isNull); // same batch
      expect(item('corrupt.mp3').status, ImportItemStatus.invalid);
      expect(item('corrupt.mp3').failure, isA<UnsupportedMediaFailure>());
      expect(item('notes.txt').status, ImportItemStatus.invalid);
      // Only ready files are pre-selected; nothing was written yet.
      expect(cubit.state.selected, {a.path, b.path});
      expect(await tracks.getTracks(), isEmpty);
    },
  );

  test(
    'imported tracks appear in the library without waiting for analysis',
    () async {
      final a = write('a.mp3', 'song-x');
      final b = write('b.mp3', 'song-y');
      await cubit.addPaths([a.path, b.path]);

      await cubit.startImport();

      expect(cubit.state.phase, ImportPhase.done);
      expect(cubit.state.importedCount, 2);
      expect(cubit.state.lastAddedCount, 2);
      expect(cubit.state.completionSerial, 1);
      final library = await tracks.getTracks();
      expect(library.map((t) => t.title).toSet(), {'a', 'b'});
      expect(library.every((t) => t.isReadyToPlay), isTrue);
    },
  );

  test(
    'same audio at another path is a duplicate and creates no track',
    () async {
      final a = write('a.mp3', 'song-x');
      await cubit.addPaths([a.path]);
      await cubit.startImport();
      expect(await tracks.getTracks(), hasLength(1));

      cubit.reset();
      final moved = write('moved.mp3', 'song-x');
      await cubit.addPaths([moved.path]);

      final scanned = item('moved.mp3');
      expect(scanned.status, ImportItemStatus.duplicate);
      expect(scanned.duplicateOfTitle, 'a');
      expect(scanned.duplicateOfTrackId, isNotNull);
      expect(cubit.state.selected, isEmpty);

      // Even bypassing the review step, the use case reuses the existing track.
      final result = await addTrack.addResolved(
        ResolvedTrackInput.single(scanned.preview!),
      );
      expect(result.existingTrackIds, {result.firstTrack!.id});
      expect(result.firstTrack!.id, scanned.duplicateOfTrackId);
      expect(await tracks.getTracks(), hasLength(1));
    },
  );

  test(
    'one failed file does not destroy the batch and can be retried',
    () async {
      final a = write('a.mp3', 'song-x');
      final b = write('b.mp3', 'song-y');
      final c = write('c.mp3', 'song-z');
      await cubit.addPaths([a.path, b.path, c.path]);
      source.failCopy.add(b.path);

      await cubit.startImport();

      expect(cubit.state.phase, ImportPhase.done);
      expect(cubit.state.importedCount, 2);
      expect(cubit.state.failedCount, 1);
      expect(item('b.mp3').status, ImportItemStatus.failed);
      expect(item('b.mp3').failure, isNotNull);
      expect((await tracks.getTracks()).map((t) => t.title).toSet(), {
        'a',
        'c',
      });

      source.failCopy.clear();
      await cubit.retryFailed();

      expect(cubit.state.failedCount, 0);
      expect(cubit.state.importedCount, 3);
      expect(cubit.state.lastAddedCount, 1);
      expect(cubit.state.completionSerial, 2);
      expect(await tracks.getTracks(), hasLength(3));
    },
  );

  test('stopping an import returns untouched files to ready', () async {
    final a = write('a.mp3', 'song-x');
    final b = write('b.mp3', 'song-y');
    final c = write('c.mp3', 'song-z');
    await cubit.addPaths([a.path, b.path, c.path]);
    source.onCopy = (_) => cubit.cancelImport();

    await cubit.startImport();

    expect(item('a.mp3').status, ImportItemStatus.imported);
    expect(item('b.mp3').status, ImportItemStatus.ready);
    expect(item('c.mp3').status, ImportItemStatus.ready);
    expect(cubit.state.phase, ImportPhase.review);
    expect(await tracks.getTracks(), hasLength(1));
  });

  test('the library bloc refreshes with the imported tracks', () async {
    final library = TrackBloc(
      getTracksUseCase: GetTracksUseCase(tracks),
      addTrackUseCase: addTrack,
      searchUseCase: _UnusedSearch(),
      removeTrackUseCase: _UnusedRemove(),
      updateTrackUseCase: _UnusedUpdate(),
      trackChangesStream: tracks.watchChanges(),
    );
    addTearDown(library.close);
    library.add(LoadTracksEvent());
    await pumpEventQueue();
    expect((library.state as TrackLoaded).tracks, isEmpty);

    await cubit.addPaths([
      write('a.mp3', 'song-x').path,
      write('b.mp3', 'song-y').path,
    ]);
    await cubit.startImport();
    // Same explicit refresh the desktop shell issues when an import finishes.
    library.add(LoadTracksEvent());
    await pumpEventQueue();

    expect((library.state as TrackLoaded).tracks, hasLength(2));
  });

  test('selection errors surface instead of being swallowed', () async {
    source.expandError = const PermissionFailure();

    await cubit.addPaths(['/nope']);

    expect(cubit.state.phase, ImportPhase.idle);
    expect(cubit.state.error?.localeKey, 'errors.permission');
  });

  test('an empty folder is reported, not ignored', () async {
    source.expandResult = const [];

    await cubit.addPaths([dir.path]);

    expect(cubit.state.folderEmpty, isTrue);
    expect(cubit.state.items, isEmpty);
  });
}

class _UnusedSearch extends Fake implements SearchUseCase {}

class _UnusedRemove extends Fake implements RemoveTrackUseCase {}

class _UnusedUpdate extends Fake implements UpdateTrackUseCase {}

class _FakeLocalSource implements TrackSource, LocalFileScanner {
  final Set<String> unreadable = {};
  final Set<String> failCopy = {};
  Object? expandError;
  List<String>? expandResult;
  void Function(String path)? onCopy;

  @override
  SourceType get sourceType => SourceType.localFile;

  @override
  bool canHandle(String input) => true;

  @override
  bool isSupportedPath(String path) => path.endsWith('.mp3');

  @override
  Future<List<String>> pickFiles() async => const [];

  @override
  Future<List<String>> pickFolder() async => const [];

  @override
  Future<List<String>> expandPaths(List<String> paths) async {
    if (expandError != null) throw expandError!;
    return expandResult ?? paths;
  }

  @override
  Future<TrackPreview> readPreview(String path) async {
    if (unreadable.contains(path)) {
      throw UnsupportedMediaFailure('$path: not audio');
    }
    final name = p.basenameWithoutExtension(path);
    return TrackPreview(
      id: 'local-$name',
      title: name,
      artist: 'Artist',
      source: SourceType.localFile,
      originalUrl: path,
      urlFile: path,
    );
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async =>
      ResolvedTrackInput.single(await readPreview(input));

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) async {
    onCopy?.call(track.originalUrl);
    if (failCopy.contains(track.originalUrl)) {
      throw const FileSystemException('disk full');
    }
    return track.originalUrl;
  }
}
