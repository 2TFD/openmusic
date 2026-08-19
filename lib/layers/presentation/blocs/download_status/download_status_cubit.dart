import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/usecases/retry_track_download_use_case.dart';

class DownloadStatusCubit extends Cubit<Map<String, DownloadTrackTask>> {
  DownloadStatusCubit({
    required Stream<List<DownloadTrackTask>> tasks,
    required RetryTrackDownloadUseCase retryDownload,
  }) : _retryDownload = retryDownload,
       super(const {}) {
    _subscription = tasks.listen(
      (items) => emit({for (final task in items) task.trackId: task}),
      onError: (error, stackTrace) {
        unawaited(
          AppLogger.log(
            '[DownloadStatusCubit] Stream error: '
            '$error, stackTrace: $stackTrace',
          ),
        );
      },
    );
  }

  final RetryTrackDownloadUseCase _retryDownload;
  late final StreamSubscription<List<DownloadTrackTask>> _subscription;

  Future<void> retry(Track track) => _retryDownload(track);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
