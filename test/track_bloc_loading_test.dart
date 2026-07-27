import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/remove_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/search_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_track_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/track/track_bloc.dart';

void main() {
  test('track refresh keeps loaded content visible', () async {
    final changes = StreamController<void>();
    final getTracks = _FakeGetTracksUseCase([
      [_track('first')],
      [_track('second')],
    ]);
    final bloc = TrackBloc(
      getTracksUseCase: getTracks,
      addTrackUseCase: _UnusedAddTrackUseCase(),
      searchUseCase: _UnusedSearchUseCase(),
      removeTrackUseCase: _UnusedRemoveTrackUseCase(),
      updateTrackUseCase: _UnusedUpdateTrackUseCase(),
      trackChangesStream: changes.stream,
    );
    final states = <TrackState>[];
    final subscription = bloc.stream.listen(states.add);

    changes.add(null);
    await pumpEventQueue();

    expect(states, [isA<TrackLoading>(), isA<TrackLoaded>()]);
    expect((bloc.state as TrackLoaded).tracks.single.id, 'first');

    states.clear();
    changes.add(null);
    await pumpEventQueue();

    expect(states, [isA<TrackLoaded>()]);
    expect(states.whereType<TrackLoading>(), isEmpty);
    expect((bloc.state as TrackLoaded).tracks.single.id, 'second');

    await subscription.cancel();
    await bloc.close();
    await changes.close();
  });
}

Track _track(String id) {
  return Track(
    id: id,
    title: id,
    artists: const [],
    duration: Duration.zero,
    source: Source(type: SourceType.localFile, originalUrl: id),
    addedAt: DateTime.utc(2026),
  );
}

class _FakeGetTracksUseCase extends Fake implements GetTracksUseCase {
  _FakeGetTracksUseCase(this.responses);

  final List<List<Track>> responses;
  int calls = 0;

  @override
  Future<List<Track>> call() async => responses[calls++];
}

class _UnusedAddTrackUseCase extends Fake implements AddTrackUseCase {}

class _UnusedSearchUseCase extends Fake implements SearchUseCase {}

class _UnusedRemoveTrackUseCase extends Fake implements RemoveTrackUseCase {}

class _UnusedUpdateTrackUseCase extends Fake implements UpdateTrackUseCase {}
