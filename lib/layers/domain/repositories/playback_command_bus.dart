/// Команды воспроизведения, приходящие извне приложения: экран блокировки,
/// нотификация, кнопки наушников, Bluetooth, Android Auto.
///
/// Входящий порт: платформа командует приложением — в противоположность
/// [AudioPlayerPort], которым приложение командует плеером. Системный адаптер
/// только формулирует намерение; решение принимает PlayerBloc, поэтому
/// правила переключения треков живут в одном месте.
sealed class PlaybackCommand {
  const PlaybackCommand();
}

class PlayRequested extends PlaybackCommand {
  const PlayRequested();
}

class PauseRequested extends PlaybackCommand {
  const PauseRequested();
}

class StopRequested extends PlaybackCommand {
  const StopRequested();
}

class SkipNextRequested extends PlaybackCommand {
  const SkipNextRequested();
}

class SkipPreviousRequested extends PlaybackCommand {
  const SkipPreviousRequested();
}

class SeekRequested extends PlaybackCommand {
  const SeekRequested(this.position);

  final Duration position;
}

class QueueItemRequested extends PlaybackCommand {
  const QueueItemRequested(this.index);

  final int index;
}

abstract class PlaybackCommandBus {
  Stream<PlaybackCommand> get commands;

  void send(PlaybackCommand command);

  Future<void> dispose();
}
