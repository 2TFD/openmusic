import '../entities/listening_event.dart';
import '../repositories/listening_event_repository.dart';

class SaveListeningEventUseCase {
  const SaveListeningEventUseCase(this.repository);

  final ListeningEventRepository repository;

  Future<void> call(ListeningEvent event) => repository.save(event);
}
