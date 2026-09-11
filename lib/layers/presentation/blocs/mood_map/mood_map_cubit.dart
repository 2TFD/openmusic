import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/mood_map.dart';
import '../../../domain/entities/track_emotion_analysis.dart';
import '../../../domain/repositories/mood_map_repository.dart';
import '../../mood_map/mood_map_geometry.dart';
import '../../models/ui_error.dart';

part 'mood_map_state.dart';

class MoodMapCubit extends Cubit<MoodMapState> {
  MoodMapCubit({required MoodMapRepository repository})
    : _repository = repository,
      super(const MoodMapState());

  final MoodMapRepository _repository;
  StreamSubscription<void>? _changes;

  Future<void> initialize() async {
    if (_changes != null) return;
    _changes = _repository.watchChanges().listen((_) => unawaited(_load()));
    await _load(showLoading: true);
  }

  Future<void> _load({bool showLoading = false}) async {
    if (showLoading) emit(state.copyWith(status: MoodMapStatus.loading));
    try {
      emit(
        state.copyWith(
          status: MoodMapStatus.ready,
          tracks: await _repository.loadTracks(),
          error: null,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: MoodMapStatus.failure,
          error: UiError.fromException(
            error,
            stackTrace,
            operation: 'mood_map.load',
          ),
        ),
      );
    }
  }

  void selectTrack(String? trackId) {
    emit(state.copyWith(selectedTrackId: trackId));
  }

  void setTarget(double valence, double arousal) {
    emit(
      state.copyWith(
        targetValence: valence.clamp(-1.0, 1.0),
        targetArousal: arousal.clamp(-1.0, 1.0),
      ),
    );
  }

  void clearTarget() {
    emit(state.copyWith(targetValence: null, targetArousal: null));
  }

  void setRadius(double radius) {
    emit(state.copyWith(radius: radius.clamp(0.05, 2.0)));
  }

  void previewPersonalPosition(String trackId, double valence, double arousal) {
    final now = DateTime.now();
    emit(
      state.copyWith(
        selectedTrackId: trackId,
        tracks: state.tracks
            .map(
              (entry) => entry.track.id == trackId
                  ? entry.copyWith(
                      personalAdjustment: PersonalMoodAdjustment(
                        trackId: trackId,
                        valence: valence.clamp(-1.0, 1.0),
                        arousal: arousal.clamp(-1.0, 1.0),
                        updatedAt: now,
                      ),
                    )
                  : entry,
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> savePersonalPosition(
    String trackId,
    double valence,
    double arousal,
  ) async {
    previewPersonalPosition(trackId, valence, arousal);
    final current = state.tracks
        .firstWhere((entry) => entry.track.id == trackId)
        .personalAdjustment!;
    await _repository.savePersonalPosition(current);
  }

  Future<void> resetPersonalPosition(String trackId) async {
    await _repository.resetPersonalPosition(trackId);
    emit(
      state.copyWith(
        tracks: state.tracks
            .map(
              (entry) => entry.track.id == trackId
                  ? MoodMapTrack(
                      track: entry.track,
                      modelAnalysis: entry.modelAnalysis,
                    )
                  : entry,
            )
            .toList(growable: false),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
