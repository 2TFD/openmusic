import 'dart:isolate';

import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/core/services/wave/wave_engine.dart';

class GenerateWaveUseCase {
  final TrackRepository _trackRepository;

  GenerateWaveUseCase({required TrackRepository repo}) : _trackRepository = repo;

  Future<List<Track>> execute(WaveConfig config) async {
    final library = await _trackRepository.getTracks();

    return Isolate.run(() => WaveEngine.generate(config, library));
  }
}
