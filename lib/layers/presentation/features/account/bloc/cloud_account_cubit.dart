import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/core/services/cloud/cloud_offline_library.dart';
import 'package:owlsonic/core/services/cloud/device_storage_mode_store.dart';
import 'package:owlsonic/core/services/cloud/local_library_migration.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

enum CloudAccountStatus { loading, unconfigured, signedOut, signedIn }

class CloudAccountState {
  const CloudAccountState({
    this.status = CloudAccountStatus.loading,
    this.submitting = false,
    this.user,
    this.usage,
    this.devices = const [],
    this.storageMode,
    this.error,
    this.migrationCount = 0,
    this.migrating = false,
    this.migration,
    this.sync = const CloudSyncStatus(),
    this.pendingEmail,
  });

  final CloudAccountStatus status;
  final bool submitting;
  final CloudUser? user;
  final StorageUsage? usage;
  final List<CloudDevice> devices;
  final DeviceStorageMode? storageMode;

  /// Last backend failure, with its code and request_id intact.
  final OwlSonicApiException? error;

  /// Local-only tracks that can be uploaded ("Upload local library").
  final int migrationCount;
  final bool migrating;
  final MigrationProgress? migration;
  final CloudSyncStatus sync;

  /// Address of a registration that still waits for its e-mail code.
  final String? pendingEmail;

  CloudAccountState copyWith({
    CloudAccountStatus? status,
    bool? submitting,
    CloudUser? user,
    StorageUsage? usage,
    List<CloudDevice>? devices,
    DeviceStorageMode? storageMode,
    OwlSonicApiException? error,
    bool clearError = false,
    bool clearAccount = false,
    int? migrationCount,
    bool? migrating,
    MigrationProgress? migration,
    CloudSyncStatus? sync,
    String? pendingEmail,
    bool clearPendingEmail = false,
  }) => CloudAccountState(
    status: status ?? this.status,
    submitting: submitting ?? this.submitting,
    user: clearAccount ? null : user ?? this.user,
    usage: clearAccount ? null : usage ?? this.usage,
    devices: clearAccount ? const [] : devices ?? this.devices,
    storageMode: storageMode ?? this.storageMode,
    error: clearError ? null : error ?? this.error,
    migrationCount: migrationCount ?? this.migrationCount,
    migrating: migrating ?? this.migrating,
    migration: migration ?? this.migration,
    sync: sync ?? this.sync,
    pendingEmail: clearPendingEmail ? null : pendingEmail ?? this.pendingEmail,
  );
}

class CloudAccountCubit extends Cubit<CloudAccountState> {
  CloudAccountCubit({
    required AuthSession session,
    required bool configured,
    required CloudAuthRepository auth,
    required CloudAccountRepository account,
    required DeviceStorageModeStore storageMode,
    LocalLibraryMigration? migration,
    CloudSyncCoordinator? sync,
    CloudOfflineLibrary? offline,
    Future<void> Function(Duration)? retryDelay,
  }) : _retryDelay = retryDelay ?? Future<void>.delayed,
       _offline = offline,
       _migration = migration,
       _sync = sync,
       _session = session,
       _configured = configured,
       _auth = auth,
       _account = account,
       _storageMode = storageMode,
       super(const CloudAccountState());

  final AuthSession _session;
  final bool _configured;
  final CloudAuthRepository _auth;
  final CloudAccountRepository _account;
  final DeviceStorageModeStore _storageMode;
  final LocalLibraryMigration? _migration;
  final CloudSyncCoordinator? _sync;
  final Future<void> Function(Duration) _retryDelay;
  final CloudOfflineLibrary? _offline;
  StreamSubscription<AuthStatus>? _subscription;
  StreamSubscription<CloudSyncStatus>? _syncSubscription;

  static const _maxEmailLength = 320;
  static const _maxPasswordLength = 128;

  Future<void> initialize() async {
    final mode = await _storageMode.load();
    if (isClosed) return;
    emit(state.copyWith(storageMode: mode));
    // Refreshes the offline progress shown on this screen (no-op when done).
    if (mode == DeviceStorageMode.offline) unawaited(_offline?.run());
    if (!_configured) {
      emit(state.copyWith(status: CloudAccountStatus.unconfigured));
      return;
    }
    _subscription ??= _session.changes.listen(_onStatus);
    final sync = _sync;
    if (sync != null) {
      emit(state.copyWith(sync: sync.status));
      _syncSubscription ??= sync.statusChanges.listen((status) {
        if (!isClosed) emit(state.copyWith(sync: status));
      });
    }
    await _session.restore();
    _onStatus(_session.status);
    await refreshPending();
  }

  /// Picks up a registration that is waiting for its code (also after an app
  /// restart), so the form can offer to continue it.
  Future<void> refreshPending() async {
    final pending = await _auth.pendingVerification();
    if (isClosed) return;
    emit(
      state.copyWith(
        pendingEmail: pending?.email,
        clearPendingEmail: pending == null,
      ),
    );
  }

  void _onStatus(AuthStatus status) {
    if (isClosed) return;
    switch (status) {
      case AuthStatus.unknown:
        return;
      case AuthStatus.signedOut:
        emit(
          state.copyWith(
            status: CloudAccountStatus.signedOut,
            clearAccount: true,
          ),
        );
      case AuthStatus.signedIn:
        final wasSignedIn = state.status == CloudAccountStatus.signedIn;
        emit(state.copyWith(status: CloudAccountStatus.signedIn));
        if (!wasSignedIn) {
          unawaited(refresh());
          unawaited(refreshMigration());
        }
    }
  }

  /// Field-level validation only; the backend remains the authority.
  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'cloud.errors.emailRequired';
    if (email.length > _maxEmailLength ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'cloud.errors.emailInvalid';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'cloud.errors.passwordRequired';
    if (value.length > _maxPasswordLength)
      return 'cloud.errors.passwordTooLong';
    return null;
  }

  Future<bool> login(String email, String password) =>
      _submit(() => _auth.login(email: email, password: password));

  /// True when the backend accepted the registration and e-mailed a code.
  /// The user is NOT signed in until the code is verified.
  Future<bool> register(String email, String password) async {
    final ok = await _submit(
      () => _auth.register(email: email, password: password),
    );
    if (ok) await refreshPending();
    return ok;
  }

  void clearError() {
    if (state.error != null) emit(state.copyWith(clearError: true));
  }

  Future<void> logout() => _submit(_auth.logout);

  Future<bool> _submit(Future<void> Function() action) async {
    if (state.submitting) return false;
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await action();
      if (!isClosed) emit(state.copyWith(submitting: false));
      return true;
    } on OwlSonicApiException catch (error) {
      if (!isClosed) emit(state.copyWith(submitting: false, error: error));
      return false;
    }
  }

  static const _loadAttempts = 3;

  /// One dropped connection must not fail a read; retried a couple of times.
  Future<T> _load<T>(Future<T> Function() request) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await request();
      } on OwlSonicApiException catch (error) {
        if (attempt >= _loadAttempts || !(error.isNetwork || error.retryable)) {
          rethrow;
        }
        await _retryDelay(Duration(milliseconds: 400 * attempt));
        if (isClosed) rethrow;
      }
    }
  }

  /// Loads profile, quota and devices independently: a failed request keeps
  /// its cached value and does not discard the ones that succeeded.
  Future<void> refresh() async {
    if (!_session.isSignedIn) return;
    OwlSonicApiException? failure;
    Future<T?> guarded<T>(Future<T> Function() request) async {
      try {
        return await _load(request);
      } on OwlSonicApiException catch (error) {
        failure ??= error;
        return null;
      }
    }

    final results = await Future.wait([
      guarded(_account.me),
      guarded(_account.usage),
      guarded(_account.devices),
    ]);
    if (isClosed) return;
    final error = failure;
    emit(
      state.copyWith(
        user: results[0] as CloudUser?,
        usage: results[1] as StorageUsage?,
        devices: results[2] as List<CloudDevice>?,
        error: error,
        clearError: error == null,
      ),
    );
  }

  Future<void> revokeDevice(String deviceId) async {
    final ok = await _submit(() => _account.revokeDevice(deviceId));
    if (ok) await refresh();
  }

  Future<bool> deleteAccount(String password) =>
      _submit(() => _account.deleteAccount(password: password));

  Future<void> refreshMigration() async {
    final migration = _migration;
    if (migration == null || !migration.available) return;
    final count = (await migration.candidates()).length;
    if (!isClosed) emit(state.copyWith(migrationCount: count));
  }

  /// Explicit, user-confirmed upload of local-only tracks.
  Future<void> startMigration() async {
    final migration = _migration;
    if (migration == null || state.migrating || !migration.available) return;
    emit(state.copyWith(migrating: true));
    final result = await migration.run(
      onProgress: (progress) {
        if (!isClosed) emit(state.copyWith(migration: progress));
      },
    );
    if (isClosed) return;
    emit(state.copyWith(migrating: false, migration: result));
    await refreshMigration();
  }

  void stopMigration() => _migration?.stop();

  /// Download progress of the offline mode; null without cloud support.
  ValueListenable<OfflineProgress>? get offlineProgress => _offline?.progress;

  /// Resumes offline downloads after the user freed space or got online.
  Future<void> retryOffline() async => _offline?.run();

  Future<void> setStorageMode(DeviceStorageMode mode) async {
    final previous = state.storageMode;
    await _storageMode.save(mode);
    if (!isClosed) emit(state.copyWith(storageMode: mode));
    // Offline downloads the library; stream hands the copies to the cache.
    if (previous != mode) unawaited(_offline?.onModeChanged(mode));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _syncSubscription?.cancel();
    return super.close();
  }
}
