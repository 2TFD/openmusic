import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/domain/usecases/get_statistic_use_case.dart';

part 'statistic_event.dart';
part 'statistic_state.dart';

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  final GetStatisticsUseCase getStatistics;
  StreamSubscription<List<PlayRecord>>? _statisticChangesSubscription;

  StatisticBloc({
    required this.getStatistics,
    required Stream<List<PlayRecord>> statisticChangesStream,
  }) : super(StatisticInitial()) {
    _statisticChangesSubscription = statisticChangesStream.listen(
      (_) {
        final period = switch (state) {
          StatisticsLoading(:final period) => period,
          StatisticsLoaded(:final statistics) => statistics.period,
          _ => StatsPeriod.twoWeeks,
        };
        add(LoadStatisticEvent(period));
      },
      onError: (error, stackTrace) {
        log('[StatisticBloc] Stream error: $error, stackTrace: $stackTrace');
        add(_StatisticStreamErrored(error));
      },
    );
    on<LoadStatisticEvent>(_onLoad);
    on<ChangePeriodEvent>(_onChangePeriod);
    on<_StatisticStreamErrored>(
      (e, emit) =>
          emit(StatisticsError(failureFromException(e.error).toLocaleKey())),
    );
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
    try {
      final stats = await getStatistics.execute(e.period);
      emit(StatisticsLoaded(stats));
    } catch (e) {
      emit(StatisticsError(failureFromException(e).toLocaleKey()));
    }
  }

  Future<void> _onChangePeriod(
    ChangePeriodEvent e,
    Emitter<StatisticState> emit,
  ) {
    add(LoadStatisticEvent(e.period));
    return Future.value();
  }
}
