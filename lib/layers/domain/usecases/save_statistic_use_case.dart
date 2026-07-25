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

    final now = DateTime.now();
    final record = PlayRecord(
      id: const Uuid().v4(),
      trackId: track.id,
      trackTitle: track.title,
      artistName: track.artists.map((a) => a.name).join(', '),
      sourceType: track.source.type,
      listenedDuration: listenedDuration,
      playedAt: now,
    );

    final last = await _playRecordRepository.getLatestByTrackId(track.id);
    if (last != null && now.difference(last.playedAt).inSeconds < 30) return;

    await _playRecordRepository.save(record);
  }
}
