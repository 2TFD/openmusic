import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';

class ClearHistoryUseCase {
  final PlayRecordRepository _playRecordRepository;

  ClearHistoryUseCase({required PlayRecordRepository playRecordRepository})
    : _playRecordRepository = playRecordRepository;

  Future<void> call() async {
    await _playRecordRepository.clear();
  }
}
