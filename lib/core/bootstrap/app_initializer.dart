import 'package:owlsonic/core/utils/app_logger.dart';

typedef BootstrapRunner = Future<void> Function();

enum BootstrapPhase {
  telemetryConsent,
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
    final total = Stopwatch()..start();
    while (_nextStep < _steps.length) {
      final step = _steps[_nextStep];
      final stopwatch = Stopwatch()..start();
      await step.run();
      stopwatch.stop();
      await AppLogger.info(
        'Startup phase ${step.phase.name}: ${stopwatch.elapsedMilliseconds} ms',
        operation: 'startup.${step.phase.name}',
      );
      _nextStep++;
    }
    total.stop();
    await AppLogger.info(
      'Essential startup complete: ${total.elapsedMilliseconds} ms',
      operation: 'startup.essential_complete',
    );
  }
}
