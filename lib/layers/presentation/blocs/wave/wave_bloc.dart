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
    on<WaveInitialized>(_onInitialized);
    on<WaveSeedSelected>(_onSeedSelected);
    on<WaveSeedDeselected>(_onSeedDeselected);
    on<WaveMoodSelected>(_onMoodSelected);
    on<WaveRefreshRequested>(_onRefreshRequested);
    on<WaveTrackSelected>(_onTrackSelected);
    on<WaveTrackDeselected>(_onTrackDeselected);
    on<WaveResetRequested>(_onResetRequested);
  }

  Future<void> _onInitialized(WaveInitialized e, Emitter<WaveState> emit) async {
    await _generateAndEmit(e.config, emit);
  }

  Future<void> _onResetRequested(WaveResetRequested e, Emitter<WaveState> emit) async {
    await _generateAndEmit(
      const WaveConfig(tracks: [], seeds: [], mood: ''),
      emit,
    );
  }

  Future<void> _onTrackSelected(WaveTrackSelected e, Emitter<WaveState> emit) async {
    await _generateAndEmit(
      _currentConfig.copyWith(tracks: [..._currentConfig.tracks, e.track]),
      emit,
    );
  }

  Future<void> _onTrackDeselected(
    WaveTrackDeselected e,
    Emitter<WaveState> emit,
  ) async {
    await _generateAndEmit(
      _currentConfig.copyWith(
        tracks: _currentConfig.tracks.where((t) => t != e.track).toList(),
      ),
      emit,
    );
  }

  Future<void> _onSeedSelected(WaveSeedSelected e, Emitter<WaveState> emit) async {
    final current = _currentConfig;
    await _generateAndEmit(
      WaveConfig(
        seeds: [...current.seeds, e.seed],
        mood: current.mood,
        tracks: current.tracks,
      ),
      emit,
    );
  }

  Future<void> _onSeedDeselected(
    WaveSeedDeselected e,
    Emitter<WaveState> emit,
  ) async {
    await _generateAndEmit(
      _currentConfig.copyWith(
        seeds: _currentConfig.seeds.where((s) => s != e.seed).toList(),
      ),
      emit,
    );
  }

  Future<void> _onMoodSelected(
    WaveMoodSelected e,
    Emitter<WaveState> emit,
  ) async {
    await _generateAndEmit(_currentConfig.copyWith(mood: e.mood), emit);
  }

  Future<void> _onRefreshRequested(WaveRefreshRequested e, Emitter<WaveState> emit) async {
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

      if (emit.isDone) return;
      if (tracks.isEmpty) {
        emit(WaveEmpty(config));
        return;
      }
      emit(WaveReady(tracks: tracks, config: config));
    } catch (e) {
      log(failureFromException(e).toString(), error: e);
      if (emit.isDone) return;
      emit(
        WaveError(error: failureFromException(e).toLocaleKey(), config: config),
      );
    }
  }
}
