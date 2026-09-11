import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/resolved_track_input.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/usecases/add_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/fetch_track_preview_use_case.dart';
import 'package:openmusic/layers/presentation/models/ui_error.dart';

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
    on<UseResolvedTrackInput>(_onUseResolvedTrackInput);
    on<AddTrackToLibrary>(_onAddTrackToLibrary);
    on<ResetAddTrack>(_onResetAddTrack);
  }

  Future<void> _onFetchTrackPreview(
    FetchTrackPreview event,
    Emitter<AddTrackState> emit,
  ) async {
    emit(const AddTrackPreviewLoading());
    try {
      final resolved = await fetchTrackPreviewUseCase(event.url);

      if (emit.isDone) return;
      emit(AddTrackPreviewLoaded(resolved: resolved));
    } catch (e, st) {
      await AppLogger.warning(
        'Error fetching track preview.',
        operation: 'add_track.fetch_preview',
      );
      if (emit.isDone) return;
      emit(
        AddTrackError(
          UiError.fromException(e, st, operation: 'add_track.fetch_preview'),
        ),
      );
    }
  }

  void _onUseResolvedTrackInput(
    UseResolvedTrackInput event,
    Emitter<AddTrackState> emit,
  ) {
    emit(AddTrackPreviewLoaded(resolved: event.resolved));
  }

  Future<void> _onAddTrackToLibrary(
    AddTrackToLibrary event,
    Emitter<AddTrackState> emit,
  ) async {
    emit(AddTrackLoading(event.resolved));

    try {
      final result = await addTrackUseCase.addResolved(event.resolved);
      final track = result.firstTrack;
      if (track == null) {
        throw result.failures.firstOrNull?.failure ??
            const EmptyResultFailure('add tracks');
      }

      if (emit.isDone) return;
      emit(AddTrackSuccess(track, result: result, resolved: event.resolved));
    } catch (e, stackTrace) {
      if (emit.isDone) return;
      emit(
        AddTrackError(
          UiError.fromException(
            e,
            stackTrace,
            operation: 'add_track.add_to_library',
          ),
          preview: event.resolved.firstTrack,
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
