import 'dart:async';

import 'package:openmusic/core/utils/app_logger.dart';

class TaskLeasePolicy {
  static const duration = Duration(minutes: 1);
  static const heartbeatInterval = Duration(seconds: 20);

  const TaskLeasePolicy._();
}

class TaskLeaseLostException implements Exception {
  final String taskId;

  const TaskLeaseLostException(this.taskId);

  @override
  String toString() => 'Lease lost for task $taskId';
}

class LeaseHeartbeat {
  final Duration interval;
  final Future<bool> Function() renew;

  LeaseHeartbeat({required this.renew, required this.interval});

  bool _active = true;
  bool _leaseLost = false;
  final _stopped = Completer<void>();

  Future<T> run<T>(String taskId, Future<T> Function() operation) async {
    final heartbeat = _runHeartbeat();
    try {
      final result = await operation();
      if (_leaseLost || !await renew()) {
        throw TaskLeaseLostException(taskId);
      }
      return result;
    } finally {
      _active = false;
      if (!_stopped.isCompleted) _stopped.complete();
      await heartbeat;
    }
  }

  Future<void> _runHeartbeat() async {
    while (_active) {
      await Future.any([Future<void>.delayed(interval), _stopped.future]);
      if (!_active) return;
      try {
        if (!await renew()) {
          _leaseLost = true;
          return;
        }
      } catch (error, stackTrace) {
        _leaseLost = true;
        await AppLogger.warning(
          'Task lease renewal failed.',
          operation: 'task_lease.renew',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
    }
  }
}
