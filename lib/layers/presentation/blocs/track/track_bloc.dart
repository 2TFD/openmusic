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
  StreamSubscription<dynamic>? _trackChangesSubscription;

  TrackBloc({
    required this.getTracksUseCase,
    required this.addTrackUseCase,
    required this.searchUseCase,
    required this.removeTrackUseCase,
    required this.updateTrackUseCase,
    required Stream<dynamic> trackChangesStream,
  }) : super(TrackInitial()) {
    _trackChangesSubscription = trackChangesStream.listen(
      (e) {
        add(LoadTracksEvent());
      },
      onError: (error, stackTrace) {
        AppLogger.log(
          '[TrackBloc] Stream error: $error, stackTrace: $stackTrace',
        );
        add(const TrackErrorEvent('Stream error occurred'));
      },
    );
    on<LoadTracksEvent>(_onLoadTracks);
    on<RemoveTrackEvent>(_onRemoveTrack);
    on<UpdateTrackEvent>(_onUpdateTrack);
    on<TrackErrorEvent>(_onTrackError);
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
    emit(TrackLoading());
    try {
      final tracks = await getTracksUseCase();
      emit(TrackLoaded(tracks));
    } catch (e) {
      emit(TrackError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onRemoveTrack(
    RemoveTrackEvent event,
    Emitter<TrackState> emit,
  ) async {
    emit(TrackLoading());
    try {
      await removeTrackUseCase(event.trackId);
      final tracks = await getTracksUseCase();
      emit(TrackLoaded(tracks));
    } catch (e) {
      emit(TrackError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onUpdateTrack(
    UpdateTrackEvent event,
    Emitter<TrackState> emit,
  ) async {
    emit(TrackLoading());
    try {
      await updateTrackUseCase(event.track);
      final tracks = await getTracksUseCase();
      emit(TrackLoaded(tracks));
    } catch (e) {
      emit(TrackError(failureFromException(e).toLocaleKey()));
    }
  }

  void _onTrackError(TrackErrorEvent event, Emitter<TrackState> emit) {
    emit(TrackError(event.message));
  }
}
