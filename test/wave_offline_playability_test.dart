import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/services/music_analysis/music_analysis_model_registry.dart';
import 'package:owlsonic/core/services/recommendation/track_wave_config.dart';
import 'package:owlsonic/core/services/recommendation/track_wave_engine.dart';
import 'package:owlsonic/core/services/recommendation/wave_playability.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';

import 'support/wave_engine_fakes.dart';

Track cloudTrack(String id, {String? filePath}) => Track(
  id: id,
  title: id,
  artists: const [Artist(id: 'other', name: 'other')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.owlsonic, originalUrl: 'owlsonic:$id'),
  addedAt: DateTime.utc(2026),
  filePath: filePath,
  audioRevision: 1,
);

void main() {
  late bool online;
  late Set<String> cached;
  late StreamController<void> changes;

  WavePlayability playability() => WavePlayability(
    isOnline: () async => online,
    changes: changes.stream,
    hasCachedAudio: cached.contains,
  );

  setUp(() {
    online = true;
    cached = {};
    changes = StreamController<void>.broadcast();
  });
  tearDown(() => changes.close());

  test('online: streaming-only cloud tracks stay eligible', () async {
    final rules = playability();
    await rules.refresh();
    expect(rules.isPlayable(cloudTrack('stream-only')), isTrue);
  });

  test('offline: only tracks with audio on this device are eligible', () async {
    online = false;
    cached = {'cached'};
    final rules = playability();
    await rules.refresh();

    expect(rules.isPlayable(cloudTrack('stream-only')), isFalse);
    expect(rules.isPlayable(cloudTrack('cached')), isTrue);
    expect(
      rules.isPlayable(cloudTrack('downloaded', filePath: 'offline/d.mp3')),
      isTrue,
    );
    expect(rules.isPlayable(waveTrack('local')), isTrue);
    expect(rules.isPlayable(waveTrack('missing', playable: false)), isFalse);
  });

  test('connectivity changes are picked up', () async {
    final rules = playability();
    await rules.refresh();
    expect(rules.online, isTrue);

    online = false;
    changes.add(null);
    await pumpEventQueue();
    expect(rules.online, isFalse);
    expect(rules.isPlayable(cloudTrack('stream-only')), isFalse);
  });

  test('offline Track Wave never queues streaming-only tracks; ranking among '
      'eligible tracks is unchanged', () async {
    final tracks = [
      waveTrack('seed'),
      cloudTrack('stream-best'),
      cloudTrack('downloaded', filePath: 'offline/downloaded.mp3'),
      waveTrack('local-far'),
    ];
    final globals = [
      waveGlobal('seed', const [1, 0]),
      waveGlobal('stream-best', const [1, 0]),
      waveGlobal('downloaded', const [0.9, 0.1]),
      waveGlobal('local-far', const [0, 1]),
    ];
    TrackWaveEngine engine(bool Function(Track)? isPlayable) => TrackWaveEngine(
      tracks: WaveTracks(tracks),
      globalEmbeddings: WaveGlobals(globals),
      temporalEmbeddings: const WaveTemporals([]),
      registry: MusicAnalysisModelRegistry(models: const WaveModels().models),
      config: const TrackWaveConfig(),
      isPlayable: isPlayable,
    );
    final session = WaveSession.startTrack(
      trackId: 'seed',
      trackTitle: 'Seed',
      seedAudioRevision: 1,
      startedAt: DateTime.utc(2026),
    );

    final onlineBatch = await engine(null).generate(session: session);
    expect(onlineBatch.tracks.map((t) => t.id), [
      'stream-best',
      'downloaded',
      'local-far',
    ]);

    online = false;
    final rules = playability();
    await rules.refresh();
    final offlineBatch = await engine(
      rules.isPlayable,
    ).generate(session: session);
    expect(offlineBatch.tracks.map((t) => t.id), ['downloaded', 'local-far']);
  });

  test('offline with nothing on the device yields an empty batch, not a '
      'queue of unplayable tracks', () async {
    online = false;
    final rules = playability();
    await rules.refresh();
    final batch =
        await TrackWaveEngine(
          tracks: WaveTracks([
            waveTrack('seed'),
            cloudTrack('a'),
            cloudTrack('b'),
          ]),
          globalEmbeddings: WaveGlobals([
            waveGlobal('seed', const [1, 0]),
            waveGlobal('a', const [1, 0]),
            waveGlobal('b', const [1, 0]),
          ]),
          temporalEmbeddings: const WaveTemporals([]),
          registry: MusicAnalysisModelRegistry(
            models: const WaveModels().models,
          ),
          config: const TrackWaveConfig(),
          isPlayable: rules.isPlayable,
        ).generate(
          session: WaveSession.startTrack(
            trackId: 'seed',
            trackTitle: 'Seed',
            seedAudioRevision: 1,
            startedAt: DateTime.utc(2026),
          ),
        );
    expect(batch.isEmpty, isTrue);
  });
}
