import 'dart:async';

class OperationCancelledException implements Exception {
  const OperationCancelledException();

  @override
  String toString() => 'Operation cancelled';
}

class OperationCancellation {
  final _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!isCancelled) _cancelled.complete();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const OperationCancelledException();
  }
}
