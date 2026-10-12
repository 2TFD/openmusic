import 'dart:async';

import 'package:owlsonic/core/network/owlsonic/auth_token_store.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';

enum AuthStatus { unknown, signedOut, signedIn }

typedef TokenRefresher = Future<AuthTokens> Function(String refreshToken);

/// Owns the OwlSonic credentials and serialises refreshes.
///
/// Invariants:
/// - at most one `/v1/auth/refresh` request is in flight;
/// - a rejected refresh (revoked/expired) signs the user out;
/// - a refresh that fails for network or server reasons keeps the session, so
///   offline users and server outages never sign anyone out;
/// - every sign-in and sign-out starts a new [epoch]. A refresh, request or
///   background job started under one epoch never writes credentials or
///   account data into another (e.g. after account A signs out and B signs
///   in while A's refresh is still in flight).
class AuthSession {
  AuthSession({required AuthTokenStore store, DateTime Function()? now})
    : _store = store,
      _now = now ?? (() => DateTime.now().toUtc());

  final AuthTokenStore _store;
  final DateTime Function() _now;
  final _changes = StreamController<AuthStatus>.broadcast();

  TokenRefresher? _refresher;
  AuthTokens? _tokens;
  AuthStatus _status = AuthStatus.unknown;
  Future<String?>? _inflightRefresh;
  int? _inflightEpoch;
  Future<void>? _restore;
  int _epoch = 0;

  static final _zoneKey = Object();

  AuthStatus get status => _status;

  /// Identity of the current sign-in. Changes on every sign-in and sign-out,
  /// never on a token refresh of the same session.
  int get epoch => _epoch;

  /// True while [epoch] is still the signed-in session.
  bool isCurrent(int epoch) => _epoch == epoch && isSignedIn;

  /// Runs [body] bound to [epoch]: every OwlSonic request it makes fails with
  /// [OwlSonicApiException.sessionChanged] once that session has ended, so a
  /// job started for one account never runs with another account's token.
  Future<T> bind<T>(int epoch, Future<T> Function() body) =>
      runZoned(body, zoneValues: {_zoneKey: epoch});

  /// Epoch the current zone was bound to with [bind], if any.
  int? get boundEpoch => Zone.current[_zoneKey] as int?;
  Stream<AuthStatus> get changes => _changes.stream;
  bool get isSignedIn => _status == AuthStatus.signedIn;

  void bindRefresher(TokenRefresher refresher) => _refresher = refresher;

  Future<void> restore() => _restore ??= _doRestore();

  Future<void> _doRestore() async {
    final epoch = _epoch;
    AuthTokens? tokens;
    try {
      tokens = await _store.read();
    } catch (_) {
      tokens = null;
    }
    if (tokens != null && tokens.refreshExpired(_now())) {
      await _store.clear();
      tokens = null;
    }
    // A sign-in or sign-out while reading the store wins over the stale read.
    if (_epoch != epoch) return;
    _tokens = tokens;
    _emit(tokens == null ? AuthStatus.signedOut : AuthStatus.signedIn);
  }

  /// A new sign-in (login, registration, verification): starts a new epoch.
  Future<void> signIn(AuthTokens tokens) async {
    _epoch++;
    _tokens = tokens;
    await _persist();
    _emit(AuthStatus.signedIn);
  }

  Future<void> signOut() async {
    _epoch++;
    _tokens = null;
    await _persist();
    _emit(AuthStatus.signedOut);
  }

  /// Writes the in-memory credentials. Re-checks after the write so a store
  /// write that raced with a newer sign-in/out cannot leave stale tokens.
  Future<void> _persist() async {
    for (var i = 0; i < 3; i++) {
      final tokens = _tokens;
      if (tokens == null) {
        await _store.clear();
      } else {
        await _store.write(tokens);
      }
      if (identical(tokens, _tokens)) return;
    }
  }

  /// Access token for an outgoing request, refreshed first when it is about to
  /// expire. Returns null when signed out.
  Future<String?> accessToken() async {
    await restore();
    final tokens = _tokens;
    if (tokens == null) return null;
    if (!tokens.accessExpiresSoon(_now())) return tokens.accessToken;
    try {
      return await _refreshOnce();
    } on OwlSonicApiException catch (error) {
      // Offline: send the current token; the request fails on its own terms.
      if (_isTransient(error)) return _tokens?.accessToken;
      rethrow;
    }
  }

  /// Called after a 401 for [rejectedToken]. Concurrent callers share one
  /// refresh. Returns the token to retry with, or null when signed out.
  ///
  /// With [epoch], returns null when that session has ended meanwhile: a
  /// request of a previous session is never retried with a newer token.
  Future<String?> refreshAfterUnauthorized(
    String? rejectedToken, {
    int? epoch,
  }) async {
    await restore();
    if (epoch != null && epoch != _epoch) return null;
    final current = _tokens;
    if (current == null) return null;
    if (rejectedToken != null && current.accessToken != rejectedToken) {
      return current.accessToken;
    }
    return _refreshOnce();
  }

  /// One shared refresh per session: a caller of a newer session never joins
  /// (and never receives the result of) a refresh started for an older one.
  Future<String?> _refreshOnce() {
    final inflight = _inflightRefresh;
    if (inflight != null && _inflightEpoch == _epoch) return inflight;
    final epoch = _epoch;
    final future = _doRefresh(epoch);
    _inflightRefresh = future;
    _inflightEpoch = epoch;
    return future.whenComplete(() {
      if (identical(_inflightRefresh, future)) {
        _inflightRefresh = null;
        _inflightEpoch = null;
      }
    });
  }

  Future<String?> _doRefresh(int epoch) async {
    final tokens = _tokens;
    final refresher = _refresher;
    if (tokens == null) return null;
    if (refresher == null) {
      throw StateError('AuthSession has no refresher bound');
    }
    if (tokens.refreshExpired(_now())) {
      await signOut();
      return null;
    }
    try {
      final next = await refresher(tokens.refreshToken);
      // A sign-out or another sign-in during the refresh wins: the result
      // belongs to a session that no longer exists.
      if (_epoch != epoch || _tokens == null) return null;
      _tokens = next;
      await _persist();
      if (_epoch != epoch) return null;
      _emit(AuthStatus.signedIn);
      return next.accessToken;
    } on OwlSonicApiException catch (error) {
      if (_isTransient(error)) rethrow;
      // Only the session whose refresh token was rejected ends.
      if (_epoch == epoch) await signOut();
      return null;
    }
  }

  /// Only an explicit rejection of the refresh token (401, or 422 for a
  /// malformed one) ends the session. Network trouble, server faults and
  /// undecodable responses keep it.
  static bool _isTransient(OwlSonicApiException error) =>
      !error.isUnauthorized && error.statusCode != 422;

  void _emit(AuthStatus status) {
    _status = status;
    if (!_changes.isClosed) _changes.add(status);
  }

  Future<void> dispose() => _changes.close();
}
