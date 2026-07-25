import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/fetch_track_preview_use_case.dart';

part 'add_track_event.dart';
part 'add_track_state.dart';

class AddTrackBloc extends Bloc<AddTrackEvent, AddTrackState> {
  final AddTrackUseCase addTrackUseCase;
  final FetchTrackPreviewUseCase fetchTrackPreviewUseCase;

  AddTrackBloc({
    required this.addTrackUseCase,
    required this.fetchTrackPreviewUseCase,
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
      final preview = await fetchTrackPreviewUseCase(event.url);

      if (emit.isDone) return;
      emit(AddTrackPreviewLoaded(preview: preview));
    } catch (e, st) {
      log(
        'Error fetching track preview ${event.url}.',
        error: e,
        stackTrace: st,
        name: 'AddTrackBloc',
      );
      if (emit.isDone) return;
      emit(AddTrackError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onAddTrackToLibrary(
    AddTrackToLibrary event,
    Emitter<AddTrackState> emit,
  ) async {
    emit(AddTrackLoading(event.preview));

    try {
      final track = await addTrackUseCase.execute(event.preview.originalUrl);

      if (emit.isDone) return;
      emit(AddTrackSuccess(track));
    } catch (e) {
      log('Error adding track to library', error: e, name: 'AddTrackBloc');
      if (emit.isDone) return;
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
