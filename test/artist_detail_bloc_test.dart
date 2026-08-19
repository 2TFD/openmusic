import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/artist/drift/artist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';
import 'package:openmusic/layers/data/repositories/artist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/domain/usecases/get_artist_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_artist_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/artist_detail/artist_detail_bloc.dart';

void main() {
  test('artist detail reacts to track changes and artist removal', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final trackSource = TrackDriftLocalSource(database);
    final trackRepository = TrackRepositoryImpl(localDataSource: trackSource);
    final artistRepository = ArtistRepositoryImpl(
      localDataSource: ArtistDriftLocalSource(database),
      trackRepository: trackRepository,
    );
    await trackSource.saveTrack(_track('first', DateTime.utc(2026, 1)));
    final bloc = ArtistDetailBloc(
      watchArtist: WatchArtistUseCase(artistRepository),
      getArtistTracks: GetArtistTracksUseCase(artistRepository),
    );
    addTearDown(bloc.close);

    bloc.add(const ArtistDetailLoad('artist'));
    await pumpEventQueue(times: 50);
    expect((bloc.state as ArtistDetailLoaded).tracks.map((track) => track.id), [
      'first',
    ]);

    await trackSource.saveTrack(_track('second', DateTime.utc(2026, 2)));
    await pumpEventQueue(times: 50);
    final updated = bloc.state as ArtistDetailLoaded;
    expect(updated.artist.trackCount, 2);
    expect(updated.tracks.map((track) => track.id), ['second', 'first']);

    await database.transaction(() async {
      await (database.delete(
        database.trackArtistTable,
      )..where((row) => row.artistId.equals('artist'))).go();
      await (database.delete(
        database.trackTable,
      )..where((row) => row.id.isIn(const ['first', 'second']))).go();
      await (database.delete(
        database.artistTable,
      )..where((row) => row.id.equals('artist'))).go();
    });
    await pumpEventQueue(times: 50);
    expect(bloc.state, isA<ArtistDetailNotFound>());
  });
}

TrackDto _track(String id, DateTime addedAt) {
  return TrackDto(
    id: id,
    title: id,
    filePath: '/$id.mp3',
    artists: const [ArtistDto(id: 'artist', name: 'Artist')],
    durationMs: 1000,
    sourceType: 'localFile',
    originalUrl: '/$id.mp3',
    addedAt: addedAt,
    imageUrl: 'https://img/$id.jpg',
  );
}
