part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {
  final int limit;

  const LoadHistoryEvent({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class RefreshHistoryEvent extends HistoryEvent {
  const RefreshHistoryEvent();
}

class ClearHistoryEvent extends HistoryEvent {
  const ClearHistoryEvent();
}
