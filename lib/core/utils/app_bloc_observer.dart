import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.log(
      '[${bloc.runtimeType}] Unhandled error: $error, stackTrace: $stackTrace',
    );
    super.onError(bloc, error, stackTrace);
  }
}
