import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/domain/usecases/generate_wave_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/wave/wave_bloc.dart';

void main() {
  test('applied config generates once and becomes ready', () async {
    final generated = _track('generated');
    final generate = _FakeGenerateWave((_) async => [generated]);
    final bloc = WaveBloc(generate: generate);
    addTearDown(bloc.close);
    const config = WaveConfig(seeds: ['Artist'], tracks: []);
    final states = <WaveState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(const WaveConfigApplied(config));
    await bloc.stream.firstWhere((state) => state is WaveReady);

    expect(generate.configs, [config]);
    expect(states.whereType<WaveGenerating>(), hasLength(1));
    expect((bloc.state as WaveReady).tracks, [generated]);
  });

  test('refresh preserves previous tracks while generating', () async {
    final first = _track('first');
    final second = _track('second');
    final refresh = Completer<List<Track>>();
    var call = 0;
    final generate = _FakeGenerateWave((_) {
      call++;
      return call == 1 ? Future.value([first]) : refresh.future;
    });
    final bloc = WaveBloc(generate: generate);
    addTearDown(bloc.close);
    const config = WaveConfig(seeds: ['Artist'], tracks: []);

    bloc.add(const WaveConfigApplied(config));
    await bloc.stream.firstWhere((state) => state is WaveReady);
    bloc.add(WaveRefreshRequested());
    final generating =
        await bloc.stream.firstWhere((state) => state is WaveGenerating)
            as WaveGenerating;

    expect(generating.previousTracks, [first]);
    refresh.complete([second]);
    final ready =
        await bloc.stream.firstWhere((state) => state is WaveReady)
            as WaveReady;
    expect(ready.tracks, [second]);
  });

  test('reset invalidates an in-flight generation', () async {
    final pending = Completer<List<Track>>();
    final generate = _FakeGenerateWave((_) => pending.future);
    final bloc = WaveBloc(generate: generate);
    addTearDown(bloc.close);

    bloc.add(
      const WaveConfigApplied(WaveConfig(seeds: ['Artist'], tracks: [])),
    );
    await bloc.stream.firstWhere((state) => state is WaveGenerating);
    bloc.add(WaveResetRequested());
    await bloc.stream.firstWhere((state) => state is WaveEmpty);
    pending.complete([_track('stale')]);
    await pumpEventQueue(times: 20);

    expect(bloc.state, isA<WaveEmpty>());
    expect((bloc.state as WaveEmpty).config.seeds, isEmpty);
  });
}

class _FakeGenerateWave implements GenerateWave {
  _FakeGenerateWave(this._handler);

  final Future<List<Track>> Function(WaveConfig config) _handler;
  final List<WaveConfig> configs = [];

  @override
  Future<List<Track>> execute(WaveConfig config) {
    configs.add(config);
    return _handler(config);
  }
}

Track _track(String id) => Track(
  id: id,
  title: id,
  artists: const [Artist(id: 'artist', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/music/$id.mp3'),
  addedAt: DateTime.utc(2026),
  filePath: '/music/$id.mp3',
  imageUrl: 'https://img/$id.jpg',
);
