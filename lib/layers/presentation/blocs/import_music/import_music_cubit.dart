import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/pick_local_tracks_use_case.dart';

part 'import_music_state.dart';

class ImportMusicCubit extends Cubit<ImportMusicState> {
  ImportMusicCubit({
    required PickLocalTracksUseCase pickLocalTracks,
    required ImportLocalTracksUseCase importLocalTracks,
  }) : _pickLocalTracks = pickLocalTracks,
       _importLocalTracks = importLocalTracks,
       super(const ImportMusicInitial());

  final PickLocalTracksUseCase _pickLocalTracks;
  final ImportLocalTracksUseCase _importLocalTracks;

  Future<void> pickLocalTracks() async {
    if (state is LocalTracksPicking || state is LocalTracksImporting) return;

    emit(const LocalTracksPicking());
    try {
      final previews = await _pickLocalTracks();
      if (isClosed) return;
      if (previews.isEmpty) {
        emit(const LocalTracksSelectionEmpty());
      } else {
        emit(LocalTracksPicked(previews));
      }
    } catch (_) {
      if (!isClosed) emit(const LocalTracksPickFailure());
    }
  }

  Future<void> importLocalTracks(List<TrackPreview> previews) async {
    if (previews.isEmpty || state is LocalTracksImporting) return;

    emit(const LocalTracksImporting());
    final result = await _importLocalTracks(previews);
    if (!isClosed) emit(LocalTracksImported(result));
  }
}
