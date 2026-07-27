import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/remove_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/search_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_track_use_case.dart';

part 'track_event.dart';
part 'track_state.dart';

class TrackBloc extends Bloc<TrackEvent, TrackState> {
  final GetTracksUseCase getTracksUseCase;
  final AddTrackUseCase addTrackUseCase;
  final SearchUseCase searchUseCase;
  final RemoveTrackUseCase removeTrackUseCase;
  final UpdateTrackUseCase updateTrackUseCase;
  StreamSubscription<void>? _trackChangesSubscription;

  TrackBloc({
    required this.getTracksUseCase,
    required this.addTrackUseCase,
    required this.searchUseCase,
    required this.removeTrackUseCase,
    required this.updateTrackUseCase,
    required Stream<void> trackChangesStream,
  }) : super(TrackInitial()) {
    on<LoadTracksEvent>(_onLoadTracks);
    on<RemoveTrackEvent>(_onRemoveTrack);
    on<UpdateTrackEvent>(_onUpdateTrack);
    on<_TrackStreamErrored>(
      (e, emit) =>
          emit(TrackError(failureFromException(e.error).toLocaleKey())),
    );

    _trackChangesSubscription = trackChangesStream.listen(
      (e) {
        add(LoadTracksEvent());
      },
      onError: (error, stackTrace) {
        AppLogger.log(
          '[TrackBloc] Stream error: $error, stackTrace: $stackTrace',
        );
        add(_TrackStreamErrored(error));
      },
    );
  }

  @override
  Future<void> close() {
    _trackChangesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTracks(
    LoadTracksEvent event,
    Emitter<TrackState> emit,
  ) async {
    final previous = state;
    if (previous is! TrackLoaded) emit(TrackLoading());

    try {
      final tracks = await getTracksUseCase();

      emit(TrackLoaded(tracks));
    } catch (e, stackTrace) {
      if (previous is TrackLoaded) {
        AppLogger.log(
          '[TrackBloc] Refresh failed: $e, stackTrace: $stackTrace',
        );
        return;
      }
      emit(TrackError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onRemoveTrack(
    RemoveTrackEvent event,
    Emitter<TrackState> emit,
  ) async {
    final current = state;
    if (current is TrackLoaded) {
      emit(
        TrackLoaded(
          current.tracks.where((t) => t.id != event.trackId).toList(),
        ),
      );
    }
    try {
      await removeTrackUseCase(event.trackId);
    } catch (e) {
      emit(TrackError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onUpdateTrack(
    UpdateTrackEvent event,
    Emitter<TrackState> emit,
  ) async {
    try {
      await updateTrackUseCase(event.track);
    } catch (e) {
      emit(TrackError(failureFromException(e).toLocaleKey()));
    }
  }
}
