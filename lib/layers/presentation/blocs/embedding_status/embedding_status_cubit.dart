import 'dart:async';

import 'package:bloc/bloc.dart';

class EmbeddingStatusCubit extends Cubit<int> {
  EmbeddingStatusCubit({required Stream<int> pendingCounts}) : super(0) {
    _subscription = pendingCounts.listen(emit);
  }

  late final StreamSubscription<int> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
