import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/domain/usecases/get_statistic_use_case.dart';
import 'package:openmusic/layers/presentation/models/ui_error.dart';

part 'statistic_event.dart';
part 'statistic_state.dart';

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  final GetStatisticsUseCase getStatistics;
  StreamSubscription<void>? _statisticChangesSubscription;

  StatisticBloc({
    required this.getStatistics,
    required Stream<void> statisticChangesStream,
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
        AppLogger.warning(
          '[StatisticBloc] Stream error: $error, stackTrace: $stackTrace',
          operation: 'statistics.watch',
        );
        add(_StatisticStreamErrored(error, stackTrace));
      },
    );
    on<LoadStatisticEvent>(_onLoad);
    on<ChangePeriodEvent>(_onChangePeriod);
    on<_StatisticStreamErrored>((e, emit) {
      emit(
        StatisticsError(
          UiError.fromException(
            e.error,
            e.stackTrace,
            operation: 'statistics.watch',
          ),
        ),
      );
    });
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
    } catch (e, stackTrace) {
      emit(
        StatisticsError(
          UiError.fromException(e, stackTrace, operation: 'statistics.load'),
        ),
      );
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
