enum SkipDirection { next, previous }

sealed class SkipAction {
  const SkipAction();
}

/// Перемотать текущий трек в начало вместо перехода к предыдущему.
class RestartCurrentTrack extends SkipAction {
  const RestartCurrentTrack();
}

class AdvanceToNextTrack extends SkipAction {
  const AdvanceToNextTrack();
}

class AdvanceToPreviousTrack extends SkipAction {
  const AdvanceToPreviousTrack();
}

/// Переключать некуда — команду игнорируем.
class SkipRejected extends SkipAction {
  const SkipRejected();
}

/// Решает, что означает «вперёд»/«назад» при текущем состоянии очереди.
///
/// Чистая функция без побочных эффектов: исполняет решение вызывающая сторона.
/// Один и тот же экземпляр обслуживает и кнопки в UI, и системные команды из
/// [PlaybackCommandBus], поэтому поведение экрана блокировки не может
/// разойтись с поведением плеера в приложении.
class SkipTrackUseCase {
  const SkipTrackUseCase({this.restartThreshold = const Duration(seconds: 3)});

  /// После этой позиции «назад» перематывает трек, а не уходит к предыдущему.
  final Duration restartThreshold;

  SkipAction call(
    SkipDirection direction, {
    required Duration position,
    required bool hasNext,
    required bool hasPrev,
  }) {
    return switch (direction) {
      SkipDirection.next => hasNext
          ? const AdvanceToNextTrack()
          : const SkipRejected(),
      // На первом треке «назад» тоже перематывает в начало: молча ничего не
      // делать — худший из вариантов, юзер считает кнопку сломанной.
      SkipDirection.previous => position > restartThreshold || !hasPrev
          ? const RestartCurrentTrack()
          : const AdvanceToPreviousTrack(),
    };
  }
}
