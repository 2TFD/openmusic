import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';

part 'add_track_event.dart';
part 'add_track_state.dart';

class AddTrackBloc extends Bloc<AddTrackEvent, AddTrackState> {
  final AddTrackUseCase addTrackUseCase;
  final TrackSourceResolver trackSourceResolver;

  AddTrackBloc({
    required this.addTrackUseCase,
    required this.trackSourceResolver,
  }) : super(const AddTrackInitial()) {
    on<FetchTrackPreview>(_onFetchTrackPreview);
    on<AddTrackToLibrary>(_onAddTrackToLibrary);
    on<ResetAddTrack>(_onResetAddTrack);
  }

  Future<void> _onFetchTrackPreview(
    FetchTrackPreview event,
    Emitter<AddTrackState> emit,
  ) async {
    emit(const AddTrackPreviewLoading());
    try {
      final source = trackSourceResolver.resolveByUrl(event.url);

      TrackPreview preview = await source.fetchTrackPreview(event.url);

      emit(AddTrackPreviewLoaded(preview: preview));
    } catch (e, st) {
      log(
        'Error fetching track preview ${event.url}.',
        error: e,
        stackTrace: st,
        name: 'AddTrackBloc',
      );
      emit(AddTrackError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onAddTrackToLibrary(
    AddTrackToLibrary event,
    Emitter<AddTrackState> emit,
  ) async {
    emit(AddTrackLoading(event.preview));

    try {
      log(event.preview.originalUrl);
      final track = await addTrackUseCase.execute(event.preview.originalUrl);

      emit(AddTrackSuccess(track));
    } catch (e) {
      log('Error adding track to library', error: e, name: 'AddTrackBloc');
      emit(
        AddTrackError(
          failureFromException(e).toLocaleKey(),
          preview: event.preview,
        ),
      );
    }
  }

  Future<void> _onResetAddTrack(
    ResetAddTrack event,
    Emitter<AddTrackState> emit,
  ) async {
    emit(const AddTrackInitial());
  }
}
