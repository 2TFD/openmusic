part of 'statistic_bloc.dart';

sealed class StatisticEvent extends Equatable {
  const StatisticEvent();

  @override
  List<Object> get props => [];
}

class LoadStatisticEvent extends StatisticEvent {
  final StatsPeriod period;
  const LoadStatisticEvent(this.period);
}

class ChangePeriodEvent extends StatisticEvent {
  final StatsPeriod period;
  const ChangePeriodEvent(this.period);
}

class _StatisticStreamErrored extends StatisticEvent {
  final Object error;
  const _StatisticStreamErrored(this.error);

  @override
  List<Object> get props => [error];
}

