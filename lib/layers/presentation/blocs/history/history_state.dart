part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<Track> tracks;

  final int totalRecords;

  const HistoryLoaded({required this.tracks, this.totalRecords = 0});

  @override
  List<Object?> get props => [tracks, totalRecords];

  bool get isEmpty => tracks.isEmpty;

  int get count => tracks.length;

  HistoryLoaded copyWith({List<Track>? tracks, int? totalRecords}) {
    return HistoryLoaded(
      tracks: tracks ?? this.tracks,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
