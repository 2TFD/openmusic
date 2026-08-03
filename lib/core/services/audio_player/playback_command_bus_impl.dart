import 'dart:async';

import 'package:openmusic/layers/domain/repositories/playback_command_bus.dart';

/// Реализация на single-subscription контроллере, а не на broadcast.
///
/// Подписчик ровно один — PlayerBloc, — и такой контроллер буферизует события
/// до первого `listen()`. Это важно на холодном старте: Android поднимает
/// сервис по нажатию play в нотификации раньше, чем построено дерево виджетов,
/// и broadcast-контроллер такую команду молча потерял бы.
class PlaybackCommandBusImpl implements PlaybackCommandBus {
  final StreamController<PlaybackCommand> _controller = StreamController();

  @override
  Stream<PlaybackCommand> get commands => _controller.stream;

  @override
  void send(PlaybackCommand command) {
    if (_controller.isClosed) return;
    _controller.add(command);
  }

  @override
  Future<void> dispose() => _controller.close();
}
