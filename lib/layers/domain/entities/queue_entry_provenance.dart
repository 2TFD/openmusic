import 'package:equatable/equatable.dart';

enum QueueEntryOrigin { manual, wave }

class QueueEntryProvenance extends Equatable {
  const QueueEntryProvenance.manual()
    : origin = QueueEntryOrigin.manual,
      waveSessionId = null;

  const QueueEntryProvenance.wave(this.waveSessionId)
    : assert(waveSessionId != null && waveSessionId != ''),
      origin = QueueEntryOrigin.wave;

  final QueueEntryOrigin origin;
  final String? waveSessionId;

  bool belongsToWave(String sessionId) =>
      origin == QueueEntryOrigin.wave && waveSessionId == sessionId;

  @override
  List<Object?> get props => [origin, waveSessionId];
}
