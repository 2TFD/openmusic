import 'package:owlsonic/layers/domain/entities/cloud/auth_challenge.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';

abstract interface class CloudAuthRepository {
  /// Starts a registration. No tokens are issued: the account stays signed
  /// out until [verifyEmail] succeeds. The pending registration is persisted.
  Future<CodeChallenge> register({
    required String email,
    required String password,
  });
  Future<void> login({required String email, required String password});

  Future<PendingVerification?> pendingVerification();
  Future<void> clearPendingVerification();

  /// Completes registration with the e-mailed code and signs in.
  Future<void> verifyEmail({required String email, required String code});
  Future<CodeChallenge> resendVerification({required String email});

  Future<CodeChallenge> forgotPassword({required String email});

  /// On success every stored session is dropped; the user must log in again.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Revokes the server session (best effort) and always clears local tokens.
  Future<void> logout();
}

abstract interface class CloudAccountRepository {
  Future<CloudUser> me();
  Future<StorageUsage> usage();
  Future<List<CloudDevice>> devices();
  Future<void> revokeDevice(String deviceId);

  /// Server-side deletion request. Returns the backend status, e.g.
  /// `deletion_pending`. Local tokens are cleared on success.
  Future<String> deleteAccount({required String password});
}

abstract interface class CloudLibraryRepository {
  Future<CloudPage<CloudLibraryItem>> list({String? cursor, int? limit});
  Future<CloudLibraryItem> get(String trackId);
  Future<CloudLibraryItem> patch(String trackId, LibraryItemPatch patch);
  Future<void> delete(String trackId);
  Future<SignedUrl> playbackUrl(String trackId);
  Future<SignedUrl> artworkUrl(String trackId);
}

abstract interface class CloudPlaylistRepository {
  Future<CloudPage<CloudPlaylistSummary>> list({String? cursor, int? limit});
  Future<CloudPlaylist> create({required String id, required String name});
  Future<CloudPlaylist> get(String playlistId);
  Future<CloudPlaylist> rename(String playlistId, String name);
  Future<void> delete(String playlistId);
  Future<CloudPlaylistItem> addItem(
    String playlistId, {
    required String itemId,
    required String trackId,
    int? index,
  });
  Future<CloudPlaylist> reorder(String playlistId, List<String> itemIds);
  Future<void> removeItem(String playlistId, String itemId);
}

abstract interface class CloudHistoryRepository {
  Future<CloudPage<CloudHistoryItem>> list({String? cursor, int? limit});
  Future<PlayEventsResult> submit(List<PlayEvent> events);
}

abstract interface class CloudDiscoverRepository {
  Future<CloudPage<DiscoverCandidate>> candidates({String? cursor, int? limit});
  Future<CloudLibraryItem> addToLibrary(String trackId);
  Future<SignedUrl> artworkUrl(String trackId);
}

abstract interface class CloudSyncRepository {
  Future<SyncPage> pull({String? cursor, int? limit});
}

abstract interface class CloudTrackUploadRepository {
  Future<CloudTrack> upload(
    CloudUploadRequest request, {
    void Function(int sent, int total)? onProgress,
    Future<void>? cancelled,
  });
}
