import 'package:uuid/uuid.dart';

import '../entities/listening_event.dart';
import '../usecases/save_listening_event_use_case.dart';

enum ListeningNavigationIntent { userNext, userPrevious, queueSelection }

class ListeningTracker {
  ListeningTracker({
    required SaveListeningEventUseCase saveEvent,
    DateTime Function()? now,
    String Function()? createId,
    String? sessionId,
  }) : _saveEvent = saveEvent,
       _now = now ?? DateTime.now,
       _createId = createId ?? (const Uuid()).v4,
       sessionId = sessionId ?? const Uuid().v4();

  ListeningTracker.disabled()
    : _saveEvent = null,
      _now = DateTime.now,
      _createId = (const Uuid()).v4,
      sessionId = 'disabled';

  final SaveListeningEventUseCase? _saveEvent;
  final DateTime Function() _now;
  final String Function() _createId;
  final String sessionId;

  String? _trackId;
  Duration _position = Duration.zero;
  Duration _listened = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _startedCurrent = false;
  bool _completedCurrent = false;
  ListeningNavigationIntent? _pendingNavigation;

  void synchronize({
    required String? trackId,
    required Duration position,
    required Duration listened,
    required Duration duration,
    required bool isPlaying,
  }) {
    if (_trackId != trackId) {
      _startedCurrent = false;
      _completedCurrent = false;
      _pendingNavigation = null;
    }
    _trackId = trackId;
    _position = position;
    _listened = listened;
    _duration = duration;
    _isPlaying = isPlaying;
  }

  void positionUpdated({
    required String trackId,
    required Duration position,
    required Duration listened,
    required Duration duration,
  }) {
    if (_trackId != trackId) {
      synchronize(
        trackId: trackId,
        position: position,
        listened: listened,
        duration: duration,
        isPlaying: _isPlaying,
      );
      return;
    }
    _position = position;
    _listened = listened;
    _duration = duration;
  }

  void navigationRequested(ListeningNavigationIntent intent) {
    _pendingNavigation = intent;
  }

  void cancelNavigationRequest() {
    _pendingNavigation = null;
  }

  Future<void> playingChanged({
    required String? trackId,
    required bool isPlaying,
    required Duration position,
    required Duration listened,
    required Duration duration,
  }) async {
    if (trackId == null) {
      _isPlaying = isPlaying;
      return;
    }
    if (_trackId != trackId) {
      synchronize(
        trackId: trackId,
        position: position,
        listened: listened,
        duration: duration,
        isPlaying: _isPlaying,
      );
    } else {
      _position = position;
      _listened = listened;
      _duration = duration;
    }

    final wasPlaying = _isPlaying;
    _isPlaying = isPlaying;
    if (wasPlaying == isPlaying) return;

    if (isPlaying) {
      final type = _startedCurrent
          ? ListeningEventType.resume
          : ListeningEventType.playStarted;
      await _save(type: type, trackId: trackId);
      _startedCurrent = true;
    } else if (_startedCurrent && !_completedCurrent) {
      await _save(type: ListeningEventType.pause, trackId: trackId);
    }
  }

  Future<void> seekConfirmed({
    required String trackId,
    required Duration from,
    required Duration to,
    required Duration listened,
    required Duration duration,
  }) async {
    _trackId = trackId;
    _position = to;
    _listened = listened;
    _duration = duration;
    if (from == to) return;
    await _save(
      type: to > from
          ? ListeningEventType.seekForward
          : ListeningEventType.seekBackward,
      trackId: trackId,
      position: to,
    );
  }

  Future<void> replayConfirmed({
    required String trackId,
    required Duration listened,
    required Duration duration,
    ListeningTransitionReason reason = ListeningTransitionReason.repeat,
  }) async {
    _trackId = trackId;
    _position = Duration.zero;
    _listened = listened;
    _duration = duration;
    _completedCurrent = false;
    _pendingNavigation = null;
    await _save(
      type: ListeningEventType.replay,
      trackId: trackId,
      position: Duration.zero,
      reason: reason,
    );
  }

  Future<void> trackChanged({
    required String previousTrackId,
    required String trackId,
    required Duration previousPosition,
    required Duration previousListened,
    required Duration previousDuration,
    required Duration duration,
    required bool isPlaying,
    ListeningTransitionReason? forcedReason,
  }) async {
    if (previousTrackId == trackId) {
      _pendingNavigation = null;
      return;
    }

    final navigation = _pendingNavigation;
    _pendingNavigation = null;
    _trackId = previousTrackId;
    _position = previousPosition;
    _listened = previousListened;
    _duration = previousDuration;

    if (navigation == ListeningNavigationIntent.userNext) {
      await _save(
        type: ListeningEventType.skipNext,
        trackId: previousTrackId,
        reason: ListeningTransitionReason.userNext,
      );
    } else if (navigation == ListeningNavigationIntent.userPrevious) {
      await _save(
        type: ListeningEventType.skipPrevious,
        trackId: previousTrackId,
        reason: ListeningTransitionReason.userPrevious,
      );
    }

    final natural =
        forcedReason == null &&
        navigation == null &&
        isPlaying &&
        _isNearEnd(previousPosition, previousDuration);
    final reason =
        forcedReason ??
        _reasonFor(navigation) ??
        (natural
            ? ListeningTransitionReason.natural
            : ListeningTransitionReason.unknown);

    if (natural && !_completedCurrent) {
      await _save(
        type: ListeningEventType.trackCompleted,
        trackId: previousTrackId,
        reason: ListeningTransitionReason.natural,
      );
      _completedCurrent = true;
    }

    await _save(
      type: ListeningEventType.trackChanged,
      trackId: trackId,
      previousTrackId: previousTrackId,
      position: Duration.zero,
      duration: duration,
      listened: Duration.zero,
      reason: reason,
    );

    _trackId = trackId;
    _position = Duration.zero;
    _listened = Duration.zero;
    _duration = duration;
    _isPlaying = isPlaying;
    _startedCurrent = false;
    _completedCurrent = false;
    if (isPlaying) {
      await _save(type: ListeningEventType.playStarted, trackId: trackId);
      _startedCurrent = true;
    }
  }

  Future<void> processingCompleted({
    required String trackId,
    required Duration position,
    required Duration listened,
    required Duration duration,
  }) async {
    _trackId = trackId;
    _position = position;
    _listened = listened;
    _duration = duration;
    if (_completedCurrent || _pendingNavigation != null) return;
    await _save(
      type: ListeningEventType.trackCompleted,
      trackId: trackId,
      reason: ListeningTransitionReason.natural,
    );
    _completedCurrent = true;
  }

  Future<void> _save({
    required ListeningEventType type,
    required String trackId,
    Duration? position,
    Duration? listened,
    Duration? duration,
    String? previousTrackId,
    ListeningTransitionReason? reason,
  }) {
    final saveEvent = _saveEvent;
    if (saveEvent == null) return Future.value();
    return saveEvent(
      ListeningEvent(
        id: _createId(),
        sessionId: sessionId,
        trackId: trackId,
        type: type,
        occurredAt: _now(),
        positionMs: (position ?? _position).inMilliseconds,
        listenedMs: (listened ?? _listened).inMilliseconds,
        durationMs: (duration ?? _duration).inMilliseconds,
        previousTrackId: previousTrackId,
        transitionReason: reason,
      ),
    );
  }

  static ListeningTransitionReason? _reasonFor(
    ListeningNavigationIntent? intent,
  ) => switch (intent) {
    ListeningNavigationIntent.userNext => ListeningTransitionReason.userNext,
    ListeningNavigationIntent.userPrevious =>
      ListeningTransitionReason.userPrevious,
    ListeningNavigationIntent.queueSelection =>
      ListeningTransitionReason.queueSelection,
    null => null,
  };

  static bool _isNearEnd(Duration position, Duration duration) {
    if (position <= Duration.zero || duration <= Duration.zero) return false;
    final percent = duration.inMilliseconds ~/ 100;
    final toleranceMs = percent.clamp(2000, 5000);
    final remainingMs = duration.inMilliseconds - position.inMilliseconds;
    return remainingMs.abs() <= toleranceMs;
  }
}
