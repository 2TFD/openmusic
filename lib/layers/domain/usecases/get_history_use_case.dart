import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/usecases/get_tracks_use_case.dart';

class GetHistoryUseCase {
  final PlayRecordRepository playRecordRepository;
  final GetTracksUseCase getTracksUseCase;
  GetHistoryUseCase({
    required this.playRecordRepository,
    required this.getTracksUseCase,
  });

  Future<List<Track>> execute({int limit = 20}) async {
    final tracks = await getTracksUseCase();
    final records = await playRecordRepository.getAll();
    final trackMap = {for (var track in tracks) track.id: track};
    final historyTracks = <Track>[];
    for (final record in records.take(limit)) {
      final track = trackMap[record.trackId];
      if (track != null) {
        historyTracks.add(track);
      }
    }
    return historyTracks;
  }
}
