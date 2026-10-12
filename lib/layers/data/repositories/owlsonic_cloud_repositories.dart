import 'package:owlsonic/core/network/owlsonic/installation_identity.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_client.dart';
import 'package:owlsonic/core/network/owlsonic/owlsonic_api_exception.dart';
import 'package:owlsonic/core/network/owlsonic/pending_verification_store.dart';
import 'package:owlsonic/core/utils/app_logger.dart';
import 'package:owlsonic/layers/data/datasources/remote/owlsonic/owlsonic_json.dart';
import 'package:owlsonic/layers/domain/entities/cloud/auth_challenge.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/repositories/cloud_repositories.dart';

String _seg(String value) => Uri.encodeComponent(value);

class OwlSonicAuthRepository implements CloudAuthRepository {
  OwlSonicAuthRepository({
    required OwlSonicApiClient client,
    required InstallationIdentity identity,
    required PendingVerificationStore pending,
    String? appVersion,
    DateTime Function()? now,
  }) : _client = client,
       _identity = identity,
       _pending = pending,
       _appVersion = appVersion,
       _now = now ?? (() => DateTime.now().toUtc());

  final OwlSonicApiClient _client;
  final InstallationIdentity _identity;
  final PendingVerificationStore _pending;
  final String? _appVersion;
  final DateTime Function() _now;

  Map<String, Object?> _device(String installationId) => <String, Object?>{
    'installation_id': installationId,
    'platform': InstallationIdentity.platform,
    'device_name': InstallationIdentity.deviceName,
    'app_version': _appVersion,
  }..removeWhere((_, value) => value == null);

  CodeChallenge _challenge(JsonMap json, String status, DateTime receivedAt) {
    try {
      return CodeChallenge.fromJson(
        json,
        expectedStatus: status,
        receivedAt: receivedAt,
      );
    } on FormatException {
      throw OwlSonicApiClient.invalidResponse('code response');
    }
  }

  @override
  Future<CodeChallenge> register({
    required String email,
    required String password,
  }) async {
    final installationId = await _identity.installationId();
    final receivedAt = _now();
    final json = await _client.postJson(
      '/v1/auth/register',
      authenticated: false,
      body: {
        'email': email.trim(),
        'password': password,
        'device': _device(installationId),
      },
    );
    final challenge = _challenge(json, 'verification_required', receivedAt);
    final normalized = challenge.email;
    if (normalized == null || normalized.isEmpty) {
      throw OwlSonicApiClient.invalidResponse('PendingVerificationResponse');
    }
    // 201 is not a session: remember what is needed to finish verification.
    await _pending.write(
      PendingVerification(
        email: normalized,
        installationId: installationId,
        codeExpiresAt: challenge.codeExpiresAt,
        resendAvailableAt: challenge.resendAvailableAt,
      ),
    );
    return challenge;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final receivedAt = _now();
    final json = await _client.postJson(
      '/v1/auth/login',
      authenticated: false,
      body: {
        'email': email.trim(),
        'password': password,
        'device': _device(await _identity.installationId()),
      },
    );
    await _client.session.signIn(
      OwlSonicApiClient.parseCredentials(json, receivedAt: receivedAt),
    );
    await _pending.clear();
  }

  @override
  Future<PendingVerification?> pendingVerification() => _pending.read();

  @override
  Future<void> clearPendingVerification() => _pending.clear();

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    // The account is bound to the installation id sent to register.
    final pending = await _pending.read();
    final installationId =
        pending?.installationId ?? await _identity.installationId();
    final receivedAt = _now();
    final json = await _client.postJson(
      '/v1/auth/verify-email',
      authenticated: false,
      body: {
        'email': (pending?.email ?? email).trim(),
        'code': code,
        'device': _device(installationId),
      },
    );
    await _client.session.signIn(
      OwlSonicApiClient.parseCredentials(json, receivedAt: receivedAt),
    );
    await _pending.clear();
  }

  @override
  Future<CodeChallenge> resendVerification({required String email}) async {
    final receivedAt = _now();
    final pending = await _pending.read();
    try {
      final json = await _client.postJson(
        '/v1/auth/resend-verification',
        authenticated: false,
        body: {'email': email.trim()},
      );
      final challenge = _challenge(json, 'accepted', receivedAt);
      if (pending != null)
        await _pending.write(pending.withChallenge(challenge));
      return challenge;
    } on OwlSonicApiException catch (error) {
      final wait = error.retryAfter;
      if (pending != null && error.code == 'RESEND_COOLDOWN' && wait != null) {
        await _pending.write(
          pending.withResendAvailableAt(receivedAt.add(wait)),
        );
      }
      rethrow;
    }
  }

  @override
  Future<CodeChallenge> forgotPassword({required String email}) async {
    final receivedAt = _now();
    final json = await _client.postJson(
      '/v1/auth/forgot-password',
      authenticated: false,
      body: {'email': email.trim()},
    );
    return _challenge(json, 'accepted', receivedAt);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _client.send(
      'POST',
      '/v1/auth/reset-password',
      authenticated: false,
      body: {'email': email.trim(), 'code': code, 'new_password': newPassword},
    );
    // The server revoked every session; drop ours and do not sign in.
    await _client.session.signOut();
  }

  @override
  Future<void> logout() async {
    try {
      await _client.session.restore();
      if (_client.session.isSignedIn) {
        await _client.send('POST', '/v1/auth/logout');
      }
    } catch (error) {
      // Server revocation is best effort; local sign-out must still happen.
      await AppLogger.warning(
        'OwlSonic logout request failed: $error',
        operation: 'owlsonic.auth.logout',
      );
    } finally {
      await _client.session.signOut();
    }
  }
}

class OwlSonicAccountRepository implements CloudAccountRepository {
  OwlSonicAccountRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<CloudUser> me() async =>
      OwlSonicJson.user(await _client.getJson('/v1/me'));

  @override
  Future<StorageUsage> usage() async =>
      OwlSonicJson.usage(await _client.getJson('/v1/me/usage'));

  @override
  Future<List<CloudDevice>> devices() async =>
      OwlSonicJson.devices(await _client.getJson('/v1/devices'));

  @override
  Future<void> revokeDevice(String deviceId) async {
    await _client.send('DELETE', '/v1/devices/${_seg(deviceId)}');
  }

  @override
  Future<String> deleteAccount({required String password}) async {
    final response = await _client.send(
      'DELETE',
      '/v1/me',
      body: {'password': password},
    );
    final status = response is Map && response['status'] is String
        ? response['status'] as String
        : 'deletion_pending';
    await _client.session.signOut();
    return status;
  }
}

class OwlSonicLibraryRepository implements CloudLibraryRepository {
  OwlSonicLibraryRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<CloudPage<CloudLibraryItem>> list({
    String? cursor,
    int? limit,
  }) async => OwlSonicJson.libraryPage(
    await _client.getJson(
      '/v1/library',
      query: {'cursor': cursor, 'limit': limit},
    ),
  );

  @override
  Future<CloudLibraryItem> get(String trackId) async =>
      OwlSonicJson.libraryItem(
        await _client.getJson('/v1/library/${_seg(trackId)}'),
      );

  @override
  Future<CloudLibraryItem> patch(
    String trackId,
    LibraryItemPatch patch,
  ) async => OwlSonicJson.libraryItem(
    await _client.patchJson(
      '/v1/library/${_seg(trackId)}',
      body: patch.toJson(),
    ),
  );

  @override
  Future<void> delete(String trackId) async {
    await _client.send('DELETE', '/v1/library/${_seg(trackId)}');
  }

  @override
  Future<SignedUrl> playbackUrl(String trackId) async => OwlSonicJson.signedUrl(
    await _client.postJson('/v1/library/${_seg(trackId)}/playback'),
  );

  @override
  Future<SignedUrl> artworkUrl(String trackId) async => OwlSonicJson.signedUrl(
    await _client.getJson('/v1/library/${_seg(trackId)}/artwork'),
  );
}

class OwlSonicPlaylistRepository implements CloudPlaylistRepository {
  OwlSonicPlaylistRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<CloudPage<CloudPlaylistSummary>> list({
    String? cursor,
    int? limit,
  }) async => OwlSonicJson.playlistPage(
    await _client.getJson(
      '/v1/playlists',
      query: {'cursor': cursor, 'limit': limit},
    ),
  );

  @override
  Future<CloudPlaylist> create({
    required String id,
    required String name,
  }) async => OwlSonicJson.playlist(
    await _client.postJson('/v1/playlists', body: {'id': id, 'name': name}),
  );

  @override
  Future<CloudPlaylist> get(String playlistId) async => OwlSonicJson.playlist(
    await _client.getJson('/v1/playlists/${_seg(playlistId)}'),
  );

  @override
  Future<CloudPlaylist> rename(String playlistId, String name) async =>
      OwlSonicJson.playlist(
        await _client.patchJson(
          '/v1/playlists/${_seg(playlistId)}',
          body: {'name': name},
        ),
      );

  @override
  Future<void> delete(String playlistId) async {
    await _client.send('DELETE', '/v1/playlists/${_seg(playlistId)}');
  }

  @override
  Future<CloudPlaylistItem> addItem(
    String playlistId, {
    required String itemId,
    required String trackId,
    int? index,
  }) async => OwlSonicJson.playlistItem(
    await _client.postJson(
      '/v1/playlists/${_seg(playlistId)}/items',
      body: {'id': itemId, 'track_id': trackId, 'index': ?index},
    ),
  );

  @override
  Future<CloudPlaylist> reorder(
    String playlistId,
    List<String> itemIds,
  ) async => OwlSonicJson.playlist(
    await _client.putJson(
      '/v1/playlists/${_seg(playlistId)}/items/order',
      body: {'item_ids': itemIds},
    ),
  );

  @override
  Future<void> removeItem(String playlistId, String itemId) async {
    await _client.send(
      'DELETE',
      '/v1/playlists/${_seg(playlistId)}/items/${_seg(itemId)}',
    );
  }
}

class OwlSonicHistoryRepository implements CloudHistoryRepository {
  OwlSonicHistoryRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<CloudPage<CloudHistoryItem>> list({
    String? cursor,
    int? limit,
  }) async => OwlSonicJson.historyPage(
    await _client.getJson(
      '/v1/history',
      query: {'cursor': cursor, 'limit': limit},
    ),
  );

  @override
  Future<PlayEventsResult> submit(List<PlayEvent> events) async =>
      OwlSonicJson.playEventsResult(
        await _client.postJson(
          '/v1/history/events',
          body: {
            'events': [for (final event in events) event.toJson()],
          },
        ),
      );
}

class OwlSonicDiscoverRepository implements CloudDiscoverRepository {
  OwlSonicDiscoverRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<CloudPage<DiscoverCandidate>> candidates({
    String? cursor,
    int? limit,
  }) async => OwlSonicJson.candidatePage(
    await _client.getJson(
      '/v1/discover/candidates',
      query: {'cursor': cursor, 'limit': limit},
    ),
  );

  @override
  Future<CloudLibraryItem> addToLibrary(String trackId) async =>
      OwlSonicJson.libraryItem(
        await _client.postJson('/v1/discover/${_seg(trackId)}/add'),
      );

  @override
  Future<SignedUrl> artworkUrl(String trackId) async => OwlSonicJson.signedUrl(
    await _client.getJson('/v1/discover/${_seg(trackId)}/artwork'),
  );
}

class OwlSonicSyncRepository implements CloudSyncRepository {
  OwlSonicSyncRepository(this._client);
  final OwlSonicApiClient _client;

  @override
  Future<SyncPage> pull({String? cursor, int? limit}) async =>
      OwlSonicJson.syncPage(
        await _client.getJson(
          '/v1/sync',
          query: {'cursor': cursor, 'limit': limit},
        ),
      );
}
