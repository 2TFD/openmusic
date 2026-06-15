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

class StatisticErrorEvent extends StatisticEvent {
  final String message;
  const StatisticErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}
