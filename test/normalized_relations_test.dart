import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/models/playlist_dto.dart';
import 'package:openmusic/layers/data/models/track_dto.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/playlist/drift/playlist_drift_local_source.dart';
import 'package:openmusic/layers/data/datasources/local/track/drift/track_drift_local_source.dart';

void main() {
  late AppDatabase database;
  late TrackDriftLocalSource tracks;
  late PlaylistDriftLocalSource playlists;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    tracks = TrackDriftLocalSource(database);
    playlists = PlaylistDriftLocalSource(database);
  });

  tearDown(() => database.close());

  test(
    'track artists are normalized and mismatched legacy data is safe',
    () async {
      await tracks.saveTrack(
        _track(
          'track-1',
          artists: const [
            ArtistDto(id: 'artist-1', name: 'Known'),
            ArtistDto(id: 'artist-2', name: 'Unknown Artist'),
          ],
        ),
      );

      final stored = await tracks.getTrackById('track-1');
      final searchResult = await tracks.searchTracks(
        'unknown artist',
        limit: 30,
        offset: 0,
      );

      expect(stored!.artists.map((artist) => artist.id), [
        'artist-1',
        'artist-2',
      ]);
      expect(stored.artists.map((artist) => artist.name), [
        'Known',
        'Unknown Artist',
      ]);
      expect(searchResult.map((track) => track.id), ['track-1']);
    },
  );

  test('parallel playlist adds do not lose updates', () async {
    const count = 12;
    for (var index = 0; index < count; index++) {
      await tracks.saveTrack(_track('track-$index'));
    }
    await playlists.savePlaylist(
      PlaylistDto(
        id: 'playlist-1',
        name: 'Playlist',
        trackIds: const [],
        createdAt: DateTime.utc(2026),
      ),
    );

    await Future.wait(
      List.generate(
        count,
        (index) => playlists.addTrack('playlist-1', 'track-$index'),
      ),
    );

    final stored = await playlists.getPlaylistById('playlist-1');
    final positions = await database.customSelect('''
SELECT position FROM playlist_track_table
WHERE playlist_id = 'playlist-1'
ORDER BY position
''').get();
    expect(stored!.trackIds.toSet(), {
      for (var index = 0; index < count; index++) 'track-$index',
    });
    expect(stored.trackIds, hasLength(count));
    expect(
      positions.map((row) => row.read<int>('position')),
      List.generate(count, (index) => index),
    );
  });

  test('local search is paginated in SQLite', () async {
    for (var index = 0; index < 35; index++) {
      await tracks.saveTrack(
        _track('matching-${index.toString().padLeft(2, '0')}'),
      );
    }

    final first = await tracks.searchTracks('matching', limit: 30, offset: 0);
    final second = await tracks.searchTracks('matching', limit: 30, offset: 30);

    expect(first, hasLength(30));
    expect(second, hasLength(5));
    expect(
      first
          .map((track) => track.id)
          .toSet()
          .intersection(second.map((track) => track.id).toSet()),
      isEmpty,
    );
  });

  test('playlist relation changes invalidate its watch stream', () async {
    await tracks.saveTrack(_track('track-1'));
    await playlists.savePlaylist(
      PlaylistDto(
        id: 'playlist-1',
        name: 'Playlist',
        trackIds: const [],
        createdAt: DateTime.utc(2026),
      ),
    );
    final updated = playlists.watchPlaylist().firstWhere(
      (items) => items.single.trackIds.isNotEmpty,
    );

    await playlists.addTrack('playlist-1', 'track-1');

    expect((await updated).single.trackIds, ['track-1']);
  });
}

TrackDto _track(
  String id, {
  List<ArtistDto> artists = const [ArtistDto(id: 'artist', name: 'Artist')],
}) {
  return TrackDto(
    id: id,
    title: id,
    filePath: null,
    artists: artists,
    durationMs: 1000,
    sourceType: 'localFile',
    originalUrl: '/$id.mp3',
    addedAt: DateTime.utc(2026),
  );
}
