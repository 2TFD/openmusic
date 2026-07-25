import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';

class GetHistoryUseCase {
  final PlayRecordRepository playRecordRepository;
  final TrackRepository trackRepository;

  GetHistoryUseCase({
    required this.playRecordRepository,
    required this.trackRepository,
  });

  Future<List<Track>> execute({int limit = 20}) async {
    final ids = await playRecordRepository.getRecentTrackIds(limit: limit);
    if (ids.isEmpty) return [];
    final tracks = await trackRepository.getTracksByIds(ids);
    final trackMap = {for (final t in tracks) t.id: t};
    return ids.map((id) => trackMap[id]).whereType<Track>().toList();
  }
}
