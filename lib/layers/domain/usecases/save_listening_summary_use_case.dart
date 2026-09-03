import 'package:openmusic/layers/domain/entities/listening_summary.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/repositories/listening_summary_repository.dart';
import 'package:uuid/uuid.dart';

class SaveListeningSummaryUseCase {
  final ListeningSummaryRepository _listeningSummaryRepository;
  static const _minDuration = Duration(seconds: 30);

  SaveListeningSummaryUseCase({required ListeningSummaryRepository repo})
    : _listeningSummaryRepository = repo;

  Future<void> call(
    Track track,
    Duration listenedDuration, {
    String? summaryId,
  }) => saveSnapshot(
    summaryId: summaryId ?? const Uuid().v4(),
    trackId: track.id,
    trackTitle: track.title,
    artistName: track.artists.map((artist) => artist.name).join(', '),
    sourceType: track.source.type,
    listenedDuration: listenedDuration,
    playedAt: DateTime.now(),
  );

  Future<void> saveSnapshot({
    required String summaryId,
    required String trackId,
    required String trackTitle,
    required String artistName,
    required SourceType sourceType,
    required Duration listenedDuration,
    required DateTime playedAt,
  }) async {
    if (listenedDuration < _minDuration) return;

    final summary = ListeningSummary(
      id: summaryId,
      trackId: trackId,
      trackTitle: trackTitle,
      artistName: artistName,
      sourceType: sourceType,
      listenedDuration: listenedDuration,
      playedAt: playedAt,
    );

    await _listeningSummaryRepository.save(summary);
  }
}
