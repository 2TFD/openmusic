import 'package:openmusic/layers/domain/repositories/listening_summary_repository.dart';

class ClearHistoryUseCase {
  final ListeningSummaryRepository _listeningSummaryRepository;

  ClearHistoryUseCase({
    required ListeningSummaryRepository listeningSummaryRepository,
  }) : _listeningSummaryRepository = listeningSummaryRepository;

  Future<void> call() async {
    await _listeningSummaryRepository.clear();
  }
}
