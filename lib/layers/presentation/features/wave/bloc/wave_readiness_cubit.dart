import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/wave_session.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';

class WaveReadinessState extends Equatable {
  const WaveReadinessState({
    this.loaded = false,
    this.readyCount = 0,
    this.center,
  });

  /// False until the first look at the analyzed library has finished.
  final bool loaded;

  /// Playable tracks that already have a mood position.
  final int readyCount;

  /// Average mood of those tracks: where a one-tap Wave starts.
  final MoodPoint? center;

  bool get isReady => readyCount > 0 && center != null;

  @override
  List<Object?> get props => [loaded, readyCount, center];
}

/// Tells the UI whether Wave has anything to work with and where a default
/// Wave should start. Read-only: ranking and playback stay in `PlayerBloc`.
class WaveReadinessCubit extends Cubit<WaveReadinessState> {
  WaveReadinessCubit({
    required MoodMapRepository repository,
    Duration refreshDelay = const Duration(seconds: 2),
  }) : _repository = repository,
       _refreshDelay = refreshDelay,
       super(const WaveReadinessState());

  /// Default Wave: stay close to the library's average mood.
  static const defaultRadius = 0.35;
  static const defaultMode = MoodWaveMode.stay;

  final MoodMapRepository _repository;
  final Duration _refreshDelay;
  StreamSubscription<void>? _changes;
  Timer? _pending;

  Future<void> initialize() async {
    if (_changes != null) return;
    // Analysis finishes track by track; coalesce the bursts of changes.
    _changes = _repository.watchChanges().listen((_) {
      _pending?.cancel();
      _pending = Timer(_refreshDelay, () => unawaited(refresh()));
    });
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final entries = await _repository.loadTracks();
      if (isClosed) return;
      emit(summarize(entries));
    } catch (_) {
      // Keep the last known state; Wave simply stays as it was.
      if (!isClosed && !state.loaded) {
        emit(const WaveReadinessState(loaded: true));
      }
    }
  }

  /// Fresh starting point for a one-tap Wave, or null when nothing is ready.
  Future<MoodPoint?> defaultTarget() async {
    await refresh();
    return state.center;
  }

  static WaveReadinessState summarize(List<MoodMapTrack> entries) {
    var count = 0;
    var valence = 0.0;
    var arousal = 0.0;
    for (final entry in entries) {
      final track = entry.track;
      if (!track.isReadyToPlay ||
          !track.source.isAvailable ||
          !_valid(entry.valence) ||
          !_valid(entry.arousal)) {
        continue;
      }
      count++;
      valence += entry.valence;
      arousal += entry.arousal;
    }
    if (count == 0) return const WaveReadinessState(loaded: true);
    return WaveReadinessState(
      loaded: true,
      readyCount: count,
      center: MoodPoint(
        valence: (valence / count).clamp(-1.0, 1.0),
        arousal: (arousal / count).clamp(-1.0, 1.0),
      ),
    );
  }

  static bool _valid(double value) =>
      value.isFinite && value >= -1 && value <= 1;

  @override
  Future<void> close() async {
    _pending?.cancel();
    await _changes?.cancel();
    return super.close();
  }
}
