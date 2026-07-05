import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:uuid/uuid.dart';

class SaveRecordPlayUseCase {
  final PlayRecordRepository _playRecordRepository;
  static const _minDuration = Duration(seconds: 30);

  SaveRecordPlayUseCase({required PlayRecordRepository repo}) : _playRecordRepository = repo;

  Future<void> call(Track track, Duration listenedDuration) async {
    if (listenedDuration < _minDuration) return;

    final record = PlayRecord(
      id: const Uuid().v4(),
      trackId: track.id,
      trackTitle: track.title,
      artistName: track.artists.map((a) => a.name).join(', '),
      sourceType: track.source.type,
      listenedDuration: listenedDuration,
      playedAt: DateTime.now(),
    );
    final allRecords = await _playRecordRepository.getAll();
    PlayRecord? lastRecordWithSameTrack;

    for (final r in allRecords) {
      if (r.trackId == record.trackId) {
        if (lastRecordWithSameTrack == null ||
            r.playedAt.isAfter(lastRecordWithSameTrack.playedAt)) {
          lastRecordWithSameTrack = r;
        }
      }
    }

    bool isDuplicatePlay = false;

    if (lastRecordWithSameTrack != null) {
      final diffInSeconds = record.playedAt
          .difference(lastRecordWithSameTrack.playedAt)
          .inSeconds;

      if (diffInSeconds >= 0 && diffInSeconds < 30) {
        isDuplicatePlay = true;
      }
    }
    if (isDuplicatePlay) return;
    await _playRecordRepository.save(record);
  }
}
