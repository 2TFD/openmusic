import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/get_artist_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/watch_artist_use_case.dart';

part 'artist_detail_event.dart';
part 'artist_detail_state.dart';

class ArtistDetailBloc extends Bloc<ArtistDetailEvent, ArtistDetailState> {
  ArtistDetailBloc({
    required WatchArtistUseCase watchArtist,
    required GetArtistTracksUseCase getArtistTracks,
  }) : _watchArtist = watchArtist,
       _getArtistTracks = getArtistTracks,
       super(ArtistDetailInitial()) {
    on<ArtistDetailEvent>(_onEvent, transformer: _sequential());
  }

  final WatchArtistUseCase _watchArtist;
  final GetArtistTracksUseCase _getArtistTracks;
  StreamSubscription<ArtistSummary?>? _subscription;
  String? _artistId;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> _onEvent(
    ArtistDetailEvent event,
    Emitter<ArtistDetailState> emit,
  ) async {
    switch (event) {
      case ArtistDetailLoad():
        await _onLoad(event, emit);
      case _ArtistDetailSnapshotReceived():
        await _onSnapshot(event, emit);
      case _ArtistDetailStreamErrored():
        emit(
          ArtistDetailError(failureFromException(event.error).toLocaleKey()),
        );
    }
  }

  Future<void> _onLoad(
    ArtistDetailLoad event,
    Emitter<ArtistDetailState> emit,
  ) async {
    emit(ArtistDetailLoading());
    _artistId = event.artistId;
    await _subscription?.cancel();
    _subscription = _watchArtist(event.artistId).listen(
      (artist) => add(_ArtistDetailSnapshotReceived(artist)),
      onError: (Object error, StackTrace _) {
        add(_ArtistDetailStreamErrored(error));
      },
    );
  }

  Future<void> _onSnapshot(
    _ArtistDetailSnapshotReceived event,
    Emitter<ArtistDetailState> emit,
  ) async {
    final artist = event.artist;
    final artistId = _artistId;
    if (artist == null || artistId == null) {
      emit(ArtistDetailNotFound());
      return;
    }
    try {
      final tracks = await _getArtistTracks(artistId);
      emit(ArtistDetailLoaded(artist: artist, tracks: tracks));
    } catch (error) {
      emit(ArtistDetailError(failureFromException(error).toLocaleKey()));
    }
  }
}

EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
