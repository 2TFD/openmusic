import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/domain/usecases/create_playlist_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/playlist/playlist_bloc.dart';

void main() {
  test('snapshots and mutations keep playlist content visible', () async {
    final snapshots = StreamController<List<PlaylistSummary>>();
    final create = _FakeCreatePlaylistUseCase();
    final bloc = PlaylistBloc(
      createPlaylistUseCase: create,
      playlistChangesStream: snapshots.stream,
    );
    final states = <PlaylistState>[];
    final subscription = bloc.stream.listen(states.add);

    snapshots.add([_summary()]);
    await pumpEventQueue();
    expect(bloc.state, isA<PlaylistLoaded>());
    expect((bloc.state as PlaylistLoaded).playlists.single.trackCount, 3);

    states.clear();
    final playlist = Playlist(
      id: 'new-playlist',
      name: 'New',
      trackIds: const [],
      createdAt: DateTime.utc(2026),
    );
    bloc.add(CreatePlaylistEvent(playlist));
    await pumpEventQueue();

    expect(states.whereType<PlaylistLoading>(), isEmpty);
    expect(states.whereType<PlaylistLoaded>(), hasLength(2));
    expect((states.first as PlaylistLoaded).playlists, [_summary()]);
    expect(
      (states.last as PlaylistLoaded).completedOperationId,
      'new-playlist',
    );
    expect(create.created, [playlist]);

    states.clear();
    snapshots.addError(StateError('watch failed'));
    await pumpEventQueue();
    final afterError = bloc.state as PlaylistLoaded;
    expect(afterError.playlists, [_summary()]);
    expect(afterError.errorKey, isNotNull);

    await subscription.cancel();
    await bloc.close();
    await snapshots.close();
  });
}

PlaylistSummary _summary() {
  return PlaylistSummary(
    id: 'playlist',
    name: 'Playlist',
    createdAt: DateTime.utc(2026),
    trackCount: 3,
    revision: 1,
  );
}

class _FakeCreatePlaylistUseCase extends Fake implements CreatePlaylistUseCase {
  final List<Playlist> created = [];

  @override
  Future<void> call(Playlist playlist) async => created.add(playlist);
}
