import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/domain/usecases/get_statistic_use_case.dart';

part 'statistic_event.dart';
part 'statistic_state.dart';

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  final GetStatisticsUseCase getStatistics;
  StreamSubscription<dynamic>? _statisticChangesSubscription;
  StatsPeriod _currentPeriod = StatsPeriod.twoWeeks;

  StatisticBloc({
    required this.getStatistics,
    required Stream<dynamic> statisticChangesStream,
  }) : super(StatisticInitial()) {
    _statisticChangesSubscription = statisticChangesStream.listen(
      (e) {
        add(LoadStatisticEvent(_currentPeriod));
      },
      onError: (error, stackTrace) {
        log('[StatisticBloc] Stream error: $error, stackTrace: $stackTrace');
      },
    );
    on<LoadStatisticEvent>(_onLoad);
    on<ChangePeriodEvent>(_onChangePeriod);
    on<StatisticErrorEvent>(_onStatisticError);
  }
  @override
  Future<void> close() {
    _statisticChangesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadStatisticEvent e,
    Emitter<StatisticState> emit,
  ) async {
    emit(StatisticsLoading(e.period));
    _currentPeriod = e.period;
    try {
      final stats = await getStatistics.execute(e.period);
      emit(StatisticsLoaded(stats));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriodEvent e,
    Emitter<StatisticState> emit,
  ) async {
    add(LoadStatisticEvent(e.period));
    _currentPeriod = e.period;
  }

  void _onStatisticError(
    StatisticErrorEvent event,
    Emitter<StatisticState> emit,
  ) {
    emit(StatisticsError(event.message));
  }
}
