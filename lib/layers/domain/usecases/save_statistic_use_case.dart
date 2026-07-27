import 'package:openmusic/layers/domain/entities/play_record.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:uuid/uuid.dart';

class SaveRecordPlayUseCase {
  final PlayRecordRepository _playRecordRepository;
  static const _minDuration = Duration(seconds: 30);

  SaveRecordPlayUseCase({required PlayRecordRepository repo})
    : _playRecordRepository = repo;

  Future<void> call(
    Track track,
    Duration listenedDuration, {
    String? recordId,
  }) => saveSnapshot(
    recordId: recordId ?? const Uuid().v4(),
    trackId: track.id,
    trackTitle: track.title,
    artistName: track.artists.map((artist) => artist.name).join(', '),
    sourceType: track.source.type,
    listenedDuration: listenedDuration,
    playedAt: DateTime.now(),
  );

  Future<void> saveSnapshot({
    required String recordId,
    required String trackId,
    required String trackTitle,
    required String artistName,
    required SourceType sourceType,
    required Duration listenedDuration,
    required DateTime playedAt,
  }) async {
    if (listenedDuration < _minDuration) return;

    final record = PlayRecord(
      id: recordId,
      trackId: trackId,
      trackTitle: trackTitle,
      artistName: artistName,
      sourceType: sourceType,
      listenedDuration: listenedDuration,
      playedAt: playedAt,
    );

    await _playRecordRepository.save(record);
  }
}
