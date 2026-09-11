import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/usecases/watch_artist_summaries_use_case.dart';
import 'package:openmusic/layers/presentation/models/ui_error.dart';

sealed class ArtistsState extends Equatable {
  const ArtistsState();

  @override
  List<Object?> get props => [];
}

final class ArtistsLoading extends ArtistsState {}

final class ArtistsLoaded extends ArtistsState {
  const ArtistsLoaded(this.artists);

  final List<ArtistSummary> artists;

  @override
  List<Object> get props => [artists];
}

final class ArtistsError extends ArtistsState {
  const ArtistsError(this.error);

  final UiError error;

  @override
  List<Object> get props => [error];
}

class ArtistsCubit extends Cubit<ArtistsState> {
  ArtistsCubit(WatchArtistSummariesUseCase watchArtists)
    : super(ArtistsLoading()) {
    _subscription = watchArtists().listen(
      (artists) => emit(ArtistsLoaded(artists)),
      onError: (Object error, StackTrace stackTrace) {
        emit(
          ArtistsError(
            UiError.fromException(
              error,
              stackTrace,
              operation: 'artists.watch',
            ),
          ),
        );
      },
    );
  }

  StreamSubscription<List<ArtistSummary>>? _subscription;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
