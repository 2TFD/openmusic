import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';

/// Whether the backend is configured and the user is signed in. Cheap and
/// read-only: it only mirrors [AuthSession], so entry points (Home, sidebar,
/// Settings row) can show auth state without touching the network.
class CloudSessionState {
  const CloudSessionState({required this.configured, required this.signedIn});

  final bool configured;
  final bool signedIn;

  @override
  bool operator ==(Object other) =>
      other is CloudSessionState &&
      other.configured == configured &&
      other.signedIn == signedIn;

  @override
  int get hashCode => Object.hash(configured, signedIn);
}

class CloudSessionCubit extends Cubit<CloudSessionState> {
  CloudSessionCubit({required AuthSession session, required bool configured})
    : _configured = configured,
      super(
        CloudSessionState(configured: configured, signedIn: session.isSignedIn),
      ) {
    if (!configured) return;
    _subscription = session.changes.listen(_onStatus);
    unawaited(
      session.restore().then((_) {
        if (!isClosed) _onStatus(session.status);
      }),
    );
  }

  final bool _configured;
  StreamSubscription<AuthStatus>? _subscription;

  void _onStatus(AuthStatus status) {
    if (isClosed || status == AuthStatus.unknown) return;
    emit(
      CloudSessionState(
        configured: _configured,
        signedIn: status == AuthStatus.signedIn,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
