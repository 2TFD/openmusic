import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_ingestion_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/operation_cancellation.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/track_ingestion_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_source.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';

void main() {
  test(
    'partial add returns failures and playlists successful tracks only',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final trackRepository = TrackRepositoryImpl(
        localDataSource: TrackDriftLocalSource(database),
      );
      final playlistRepository = PlaylistRepositoryImpl(
        localDataSource: PlaylistDriftLocalSource(database),
      );
      final source = _FakeTrackSource([
        _preview('track-a'),
        _preview('track-b'),
        _preview('track-c'),
      ]);
      final ingestion = _FailingIngestionRepository(
        TrackIngestionRepositoryImpl(
          database: database,
          trackLocalDataSource: TrackDriftLocalSource(database),
        ),
        failingTrackId: 'track-b',
      );
      final useCase = AddTrackUseCase(
        ingestionRepository: ingestion,
        trackResolver: TrackSourceResolver([source]),
        trackRepository: trackRepository,
        playlistRepository: playlistRepository,
      );

      final result = await useCase.execute('https://example.com/set');

      expect(result.isPartial, isTrue);
      expect(result.addedTracks.map((track) => track.id), [
        'track-a',
        'track-c',
      ]);
      expect(result.failures.single.preview.id, 'track-b');
      expect(result.playlist?.trackIds, ['track-a', 'track-c']);
      expect(
        (await trackRepository.getTracks()).map((track) => track.id).toSet(),
        {'track-a', 'track-c'},
      );
      expect(ingestion.ingested, {'track-a', 'track-c'});
    },
  );
}

TrackPreview _preview(String id) {
  return TrackPreview(
    id: id,
    title: id,
    artist: 'Artist',
    source: SourceType.soundcloud,
    originalUrl: 'https://example.com/$id',
    urlFile: '',
  );
}

class _FakeTrackSource implements TrackSource {
  _FakeTrackSource(this.previews);

  final List<TrackPreview> previews;

  @override
  SourceType get sourceType => SourceType.soundcloud;

  @override
  bool canHandle(String input) => true;

  @override
  Future<String> download(
    TrackPreview track, {
    OperationCancellation? cancellation,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ResolvedTrackInput> resolve(String input) async => ResolvedTrackInput(
    input: input,
    sourceType: sourceType,
    tracks: previews,
    collection: const ResolvedTrackCollection(
      id: 'playlist-1',
      name: 'Resolved playlist',
    ),
  );
}

class _FailingIngestionRepository implements TrackIngestionRepository {
  _FailingIngestionRepository(this.delegate, {required this.failingTrackId});

  final TrackIngestionRepository delegate;
  final String failingTrackId;
  final Set<String> ingested = {};

  @override
  Future<Track> ingestRemote(Track track) async {
    if (track.id == failingTrackId) throw StateError('ingestion failed');
    final result = await delegate.ingestRemote(track);
    ingested.add(track.id);
    return result;
  }

  @override
  Future<Track> ingestLocal(Track track, {required String filePath}) =>
      delegate.ingestLocal(track, filePath: filePath);
}
