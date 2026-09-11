import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.captureException(
      error,
      stackTrace,
      operation: 'bloc.${bloc.runtimeType}.unhandled',
      message: '[${bloc.runtimeType}] Unhandled error',
    );
    super.onError(bloc, error, stackTrace);
  }
}
