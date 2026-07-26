part of 'import_music_cubit.dart';

sealed class ImportMusicState extends Equatable {
  const ImportMusicState();

  @override
  List<Object?> get props => const [];
}

final class ImportMusicInitial extends ImportMusicState {
  const ImportMusicInitial();
}

final class LocalTracksPicking extends ImportMusicState {
  const LocalTracksPicking();
}

final class LocalTracksPicked extends ImportMusicState {
  const LocalTracksPicked(this.previews);

  final List<TrackPreview> previews;

  @override
  List<Object?> get props => [previews];
}

final class LocalTracksSelectionEmpty extends ImportMusicState {
  const LocalTracksSelectionEmpty();
}

final class LocalTracksPickFailure extends ImportMusicState {
  const LocalTracksPickFailure();
}

final class LocalTracksImporting extends ImportMusicState {
  const LocalTracksImporting();
}

final class LocalTracksImported extends ImportMusicState {
  const LocalTracksImported(this.result);

  final ImportLocalTracksResult result;

  @override
  List<Object?> get props => [result.added, result.failed];
}
