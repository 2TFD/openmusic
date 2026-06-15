import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/wave_config.dart';
import 'package:openmusic/layers/domain/usecases/generate_wave_use_case.dart';

part 'wave_event.dart';
part 'wave_state.dart';

class WaveBloc extends Bloc<WaveEvent, WaveState> {
  final GenerateWaveUseCase _generate;

  WaveBloc({required GenerateWaveUseCase generate})
    : _generate = generate,
      super(WaveInitial()) {
    on<WaveStarted>(_onStarted);
    on<WaveSeedAdded>(_onSeedAdded);
    on<WaveSeedRemoved>(_onSeedRemoved);
    on<WaveMoodChanged>(_onMoodChanged);
    on<WaveRefreshed>(_onRefreshed);
    on<WaveAddTrack>(_onWaveAddTrack);
    on<WaveRemoveTrack>(_onWaveRemoveTrack);
    on<WaveReset>(_onWaveReset);
  }

  Future<void> _onStarted(WaveStarted e, Emitter<WaveState> emit) async {
    await _generateAndEmit(e.config, emit);
  }

  Future<void> _onWaveReset(WaveReset e, Emitter<WaveState> emit) async {
    await _generateAndEmit(
      const WaveConfig(tracks: [], seeds: [], mood: ''),
      emit,
    );
  }

  Future<void> _onWaveAddTrack(WaveAddTrack e, Emitter<WaveState> emit) async {
    await _generateAndEmit(
      _currentConfig.copyWith(tracks: [..._currentConfig.tracks, e.track]),
      emit,
    );
  }

  Future<void> _onWaveRemoveTrack(
    WaveRemoveTrack e,
    Emitter<WaveState> emit,
  ) async {
    await _generateAndEmit(
      _currentConfig.copyWith(
        tracks: _currentConfig.tracks.where((t) => t != e.track).toList(),
      ),
      emit,
    );
  }

  Future<void> _onSeedAdded(WaveSeedAdded e, Emitter<WaveState> emit) async {
    final current = _currentConfig;

    final updated = WaveConfig(
      seeds: [...current.seeds, e.seed],
      mood: current.mood,
      tracks: current.tracks,
    );
    await _generateAndEmit(updated, emit);
  }

  Future<void> _onSeedRemoved(
    WaveSeedRemoved e,
    Emitter<WaveState> emit,
  ) async {
    await _generateAndEmit(
      _currentConfig.copyWith(
        seeds: _currentConfig.seeds.where((s) => s != e.seed).toList(),
      ),
      emit,
    );
  }

  Future<void> _onMoodChanged(
    WaveMoodChanged e,
    Emitter<WaveState> emit,
  ) async {
    await _generateAndEmit(_currentConfig.copyWith(mood: e.mood), emit);
  }

  Future<void> _onRefreshed(WaveRefreshed e, Emitter<WaveState> emit) async {
    await _generateAndEmit(_currentConfig, emit);
  }

  WaveConfig get _currentConfig => switch (state) {
    WaveReady() => (state as WaveReady).config,
    WaveGenerating() => (state as WaveGenerating).config,
    WaveEmpty() => (state as WaveEmpty).config,
    WaveError() => (state as WaveError).config,
    _ => const WaveConfig(seeds: [], mood: '', tracks: []),
  };

  Future<void> _generateAndEmit(
    WaveConfig config,
    Emitter<WaveState> emit,
  ) async {
    emit(WaveGenerating(config));
    try {
      final tracks = await _generate.execute(config);

      if (tracks.isEmpty) {
        emit(WaveEmpty(config));
        return;
      }
      emit(WaveReady(tracks: tracks, config: config));
    } catch (e) {
      log(failureFromException(e).toString(), error: e);
      emit(
        WaveError(error: failureFromException(e).toLocaleKey(), config: config),
      );
    }
  }
}
