part of 'statistic_bloc.dart';

sealed class StatisticState extends Equatable {
  const StatisticState();

  @override
  List<Object> get props => [];
}

final class StatisticInitial extends StatisticState {}

class StatisticsLoading extends StatisticState {
  final StatsPeriod period;
  const StatisticsLoading(this.period);
}

class StatisticsLoaded extends StatisticState {
  final Statistic statistics;
  const StatisticsLoaded(this.statistics);
}

class StatisticsError extends StatisticState {
  final String error;
  const StatisticsError(this.error);
}
