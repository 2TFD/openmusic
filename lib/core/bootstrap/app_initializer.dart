typedef BootstrapRunner = Future<void> Function();

enum BootstrapPhase {
  localization,
  appDirectory,
  dependencies,
  recovery,
  audio,
}

final class BootstrapStep {
  const BootstrapStep(this.phase, this.run);

  final BootstrapPhase phase;
  final BootstrapRunner run;
}

final class AppInitializer {
  AppInitializer(List<BootstrapStep> steps) : _steps = List.unmodifiable(steps);

  final List<BootstrapStep> _steps;
  int _nextStep = 0;
  Future<void>? _inFlight;

  BootstrapPhase? get currentPhase =>
      _nextStep < _steps.length ? _steps[_nextStep].phase : null;

  bool get isComplete => _nextStep == _steps.length;

  Future<void> initialize() {
    final active = _inFlight;
    if (active != null) return active;
    final future = _runRemaining();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }

  Future<void> _runRemaining() async {
    while (_nextStep < _steps.length) {
      await _steps[_nextStep].run();
      _nextStep++;
    }
  }
}
