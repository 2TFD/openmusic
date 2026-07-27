import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';
import 'package:openmusic/layers/data/models/playlist_dto.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';
import 'package:openmusic/layers/data/repositories/playlist_repository_impl.dart';
import 'package:openmusic/layers/data/repositories/track_repository_impl.dart';
import 'package:openmusic/layers/domain/usecases/add_track_to_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/delete_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_playlist_with_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_playlist_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/playlist_detail/playlist_detail_bloc.dart';

void main() {
  test('detail reacts to database changes and serializes mutations', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final trackSource = TrackDriftLocalSource(database);
    final playlistSource = PlaylistDriftLocalSource(database);
    final trackRepository = TrackRepositoryImpl(localDataSource: trackSource);
    final playlistRepository = PlaylistRepositoryImpl(
      localDataSource: playlistSource,
    );
    await trackSource.saveTrack(_track('a'));
    await trackSource.saveTrack(_track('b'));
    await playlistSource.savePlaylist(
      PlaylistDto(
        id: 'playlist',
        name: 'Playlist',
        trackIds: const ['a'],
        createdAt: DateTime.utc(2026),
      ),
    );
    final bloc = PlaylistDetailBloc(
      getPlaylistWithTracks: GetPlaylistWithTracksUseCase(
        playlistRepository: playlistRepository,
        trackRepository: trackRepository,
      ),
      updatePlaylist: UpdatePlaylistUseCase(playlistRepository),
      deletePlaylist: DeletePlaylistUseCase(playlistRepository),
      addTrack: AddTrackToPlaylistUseCase(playlistRepository),
      watchPlaylist: WatchPlaylistUseCase(playlistRepository),
      trackChanges: trackRepository.watchChanges(),
    );
    addTearDown(bloc.close);

    bloc.add(const PlaylistDetailLoad('playlist'));
    await pumpEventQueue(times: 50);
    expect(
      (bloc.state as PlaylistDetailLoaded).tracks.map((track) => track.id),
      ['a'],
    );

    await playlistRepository.addTrackToPlaylist('playlist', 'b');
    await pumpEventQueue(times: 50);
    expect(
      (bloc.state as PlaylistDetailLoaded).tracks.map((track) => track.id),
      ['a', 'b'],
    );

    bloc.add(const PlaylistDetailReorder(0, 2));
    bloc.add(const PlaylistDetailRemoveTrack('a'));
    await pumpEventQueue(times: 80);

    final stored = await playlistRepository.getPlaylistById('playlist');
    expect(stored!.trackIds, ['b']);
    expect(stored.revision, 3);
    expect(
      (bloc.state as PlaylistDetailLoaded).tracks.map((track) => track.id),
      ['b'],
    );

    await playlistRepository.deletePlaylist('playlist');
    await pumpEventQueue(times: 50);
    expect(bloc.state, isA<PlaylistDetailDeleted>());
  });
}

TrackDto _track(String id) {
  return TrackDto(
    id: id,
    title: id,
    filePath: null,
    artists: const [ArtistDto(id: 'artist', name: 'Artist')],
    durationMs: 1000,
    sourceType: 'localFile',
    originalUrl: '/$id.mp3',
    addedAt: DateTime.utc(2026),
  );
}
