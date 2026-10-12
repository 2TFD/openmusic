import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';

enum CloudStatusKind {
  /// Cloud is not configured in this build.
  hidden,

  /// Cloud is configured but the saved session has not been read yet.
  checking,

  /// Signed out: music lives on this device only.
  deviceOnly,

  /// Signed in and the library is up to date.
  upToDate,

  /// Signed in and a sync is running.
  syncing,

  /// Signed in and tracks are waiting to be uploaded.
  uploading,

  /// The last sync failed because there is no connection.
  offline,

  /// The last sync failed for another reason.
  failed,
}

class CloudStatusState extends Equatable {
  const CloudStatusState({
    this.kind = CloudStatusKind.hidden,
    this.pendingUploads = 0,
    this.awaitingFirstSync = false,
  });

  final CloudStatusKind kind;

  /// Real number of uploads still waiting; only meaningful for `uploading`.
  final int pendingUploads;

  /// Signed in, but the library has not been synced since launch yet. Home
  /// uses this to avoid calling a still-loading cloud library "empty".
  final bool awaitingFirstSync;

  bool get signedIn =>
      kind != CloudStatusKind.hidden &&
      kind != CloudStatusKind.checking &&
      kind != CloudStatusKind.deviceOnly;

  @override
  List<Object?> get props => [kind, pendingUploads, awaitingFirstSync];
}

/// Quiet, read-only summary of the existing auth, sync and upload state for
/// Home and Library. It never starts work on its own; [retry] only asks the
/// sync coordinator, which coalesces requests.
class CloudStatusCubit extends Cubit<CloudStatusState> {
  CloudStatusCubit({
    required bool configured,
    required AuthSession session,
    required CloudSyncStatus Function() currentSync,
    required Stream<CloudSyncStatus> syncChanges,
    required Future<int> Function() pendingUploads,
    required void Function() requestSync,
  }) : _configured = configured,
       _session = session,
       _currentSync = currentSync,
       _pendingUploads = pendingUploads,
       _requestSync = requestSync,
       super(
         configured
             ? const CloudStatusState(kind: CloudStatusKind.checking)
             : const CloudStatusState(),
       ) {
    if (!configured) return;
    _auth = session.changes.listen((_) => _recompute());
    _sync = syncChanges.listen((_) => _recompute());
    _recompute();
  }

  final bool _configured;
  final AuthSession _session;
  final CloudSyncStatus Function() _currentSync;
  final Future<int> Function() _pendingUploads;
  final void Function() _requestSync;
  StreamSubscription<AuthStatus>? _auth;
  StreamSubscription<CloudSyncStatus>? _sync;
  int _pending = 0;

  void retry() => _requestSync();

  Future<void> _recompute() async {
    if (isClosed) return;
    try {
      _pending = _session.isSignedIn ? await _pendingUploads() : 0;
    } catch (_) {
      // Keep the previous count; the status line is informational.
    }
    if (isClosed) return;
    emit(
      derive(
        configured: _configured,
        status: _session.status,
        sync: _currentSync(),
        pendingUploads: _pending,
      ),
    );
  }

  static CloudStatusState derive({
    required bool configured,
    required AuthStatus status,
    required CloudSyncStatus sync,
    required int pendingUploads,
  }) {
    if (!configured) return const CloudStatusState();
    if (status == AuthStatus.unknown) {
      return const CloudStatusState(kind: CloudStatusKind.checking);
    }
    if (status == AuthStatus.signedOut) {
      return const CloudStatusState(kind: CloudStatusKind.deviceOnly);
    }
    final firstSync =
        sync.lastSyncedAt == null && sync.phase != CloudSyncPhase.failed;
    final kind = switch (sync.phase) {
      CloudSyncPhase.failed =>
        (sync.lastErrorCode ?? '').startsWith('network')
            ? CloudStatusKind.offline
            : CloudStatusKind.failed,
      _ when pendingUploads > 0 => CloudStatusKind.uploading,
      CloudSyncPhase.syncing => CloudStatusKind.syncing,
      _ when firstSync => CloudStatusKind.syncing,
      _ => CloudStatusKind.upToDate,
    };
    return CloudStatusState(
      kind: kind,
      pendingUploads: kind == CloudStatusKind.uploading ? pendingUploads : 0,
      awaitingFirstSync: firstSync,
    );
  }

  @override
  Future<void> close() async {
    await _auth?.cancel();
    await _sync?.cancel();
    return super.close();
  }
}
