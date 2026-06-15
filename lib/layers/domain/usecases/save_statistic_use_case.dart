import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:uuid/uuid.dart';

class SaveRecordPlayUseCase {
  final PlayRecordRepository _repo;
  static const _minDuration = Duration(seconds: 30);

  SaveRecordPlayUseCase({required PlayRecordRepository repo}) : _repo = repo;

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
    final allrecords = await _repo.getAll();
    PlayRecord? lastRecordWithSameTrack;

    for (final r in allrecords) {
      if (r.trackId == record.trackId) {
        if (lastRecordWithSameTrack == null ||
            r.playedAt.isAfter(lastRecordWithSameTrack.playedAt)) {
          lastRecordWithSameTrack = r;
        }
      }
    }

    bool isCreatedWithin30Seconds = false;

    if (lastRecordWithSameTrack != null) {
      final diffInSeconds = record.playedAt
          .difference(lastRecordWithSameTrack.playedAt)
          .inSeconds;

      if (diffInSeconds >= 0 && diffInSeconds < 30) {
        isCreatedWithin30Seconds = true;
      }
    }
    if (isCreatedWithin30Seconds) return;
    await _repo.save(record);
  }
}
