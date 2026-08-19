import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/usecases/watch_artist_summaries_use_case.dart';

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
  const ArtistsError(this.errorKey);

  final String errorKey;

  @override
  List<Object> get props => [errorKey];
}

class ArtistsCubit extends Cubit<ArtistsState> {
  ArtistsCubit(WatchArtistSummariesUseCase watchArtists)
    : super(ArtistsLoading()) {
    _subscription = watchArtists().listen(
      (artists) => emit(ArtistsLoaded(artists)),
      onError: (Object error, StackTrace _) {
        emit(ArtistsError(failureFromException(error).toLocaleKey()));
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
