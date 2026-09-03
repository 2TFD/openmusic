import '../entities/listening_event.dart';

abstract interface class ListeningEventRepository {
  Future<void> save(ListeningEvent event);

  Future<List<ListeningEvent>> getForTrack(String trackId);

  Future<List<ListeningEvent>> getAll();
}
