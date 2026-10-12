/// Domain models for the OwlSonic backend. Field sets mirror docs/openapi.json;
/// nothing here is inferred beyond the published schemas.
library;

class CloudUser {
  const CloudUser({
    required this.id,
    required this.email,
    required this.createdAt,
  });
  final String id;
  final String email;
  final DateTime createdAt;
}

class StorageUsage {
  const StorageUsage({
    required this.usedBytes,
    required this.limitBytes,
    required this.remainingBytes,
    required this.unlimited,
    required this.overLimit,
  });
  final int usedBytes;
  final int? limitBytes;
  final int? remainingBytes;
  final bool unlimited;
  final bool overLimit;
}

class CloudDevice {
  const CloudDevice({
    required this.id,
    required this.platform,
    required this.deviceName,
    required this.appVersion,
    required this.createdAt,
    required this.lastSeenAt,
    required this.current,
  });
  final String id;
  final String platform;
  final String? deviceName;
  final String? appVersion;
  final DateTime createdAt;
  final DateTime lastSeenAt;
  final bool current;
}

enum CloudAnalysisStatus {
  pending,
  ready,
  failed,
  unknown;

  static CloudAnalysisStatus parse(Object? value) => switch (value) {
    'pending' => pending,
    'ready' => ready,
    'failed' => failed,
    _ => unknown,
  };
}

class CloudPage<T> {
  const CloudPage({
    required this.items,
    required this.nextCursor,
    bool? hasMore,
  }) : hasMore = hasMore ?? nextCursor != null;
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
}

class CloudLibraryItem {
  const CloudLibraryItem({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.albumArtist,
    required this.trackNumber,
    required this.discNumber,
    required this.year,
    required this.genres,
    required this.duration,
    required this.hasArtwork,
    required this.analysisStatus,
    required this.customTitle,
    required this.customArtistName,
    required this.customAlbumTitle,
    required this.addedAt,
    required this.updatedAt,
    required this.favorite,
    required this.customValence,
    required this.customArousal,
    required this.playCount,
    required this.lastPlayedAt,
  });

  final String id;
  final String title;
  final String? artistName;
  final String? albumTitle;
  final String? albumArtist;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final List<String> genres;
  final Duration duration;
  final bool hasArtwork;
  final CloudAnalysisStatus analysisStatus;
  final String? customTitle;
  final String? customArtistName;
  final String? customAlbumTitle;
  final DateTime addedAt;
  final DateTime updatedAt;
  final bool favorite;
  final double? customValence;
  final double? customArousal;
  final int playCount;
  final DateTime? lastPlayedAt;

  /// Personal overrides win over canonical metadata.
  String get effectiveTitle => customTitle ?? title;
  String? get effectiveArtistName => customArtistName ?? artistName;
  String? get effectiveAlbumTitle => customAlbumTitle ?? albumTitle;
}

/// A PATCH field: absent (null wrapper) = unchanged, [PatchValue.clear] = null,
/// [PatchValue.set] = new value.
class PatchValue<T> {
  const PatchValue.set(T this.value);
  const PatchValue.clear() : value = null;
  final T? value;
}

class LibraryItemPatch {
  const LibraryItemPatch({
    this.favorite,
    this.customTitle,
    this.customArtistName,
    this.customAlbumTitle,
    this.customValence,
    this.customArousal,
  });

  final PatchValue<bool>? favorite;
  final PatchValue<String>? customTitle;
  final PatchValue<String>? customArtistName;
  final PatchValue<String>? customAlbumTitle;
  final PatchValue<double>? customValence;
  final PatchValue<double>? customArousal;

  bool get isEmpty => toJson().isEmpty;

  Map<String, Object?> toJson() => {
    if (favorite != null) 'favorite': favorite!.value,
    if (customTitle != null) 'custom_title': customTitle!.value,
    if (customArtistName != null) 'custom_artist_name': customArtistName!.value,
    if (customAlbumTitle != null) 'custom_album_title': customAlbumTitle!.value,
    if (customValence != null) 'custom_valence': customValence!.value,
    if (customArousal != null) 'custom_arousal': customArousal!.value,
  };
}

/// Short-lived signed GET URL. Never persist or log [url].
class SignedUrl {
  const SignedUrl({required this.url, required this.expiresAt});
  final Uri url;
  final DateTime expiresAt;

  bool isUsableAt(
    DateTime now, {
    Duration margin = const Duration(seconds: 30),
  }) => now.isBefore(expiresAt.subtract(margin));

  @override
  String toString() => 'SignedUrl(<redacted>, expiresAt: $expiresAt)';
}

class PlayEvent {
  const PlayEvent({
    required this.id,
    required this.trackId,
    required this.playedAt,
    required this.listenedMs,
    this.accountId,
  });
  final String id;
  final String trackId;
  final DateTime playedAt;
  final int listenedMs;

  /// Account the play was recorded under (local outbox only, never sent).
  /// Null when it was not known yet at record time.
  final String? accountId;

  PlayEvent withAccount(String? accountId) => PlayEvent(
    id: id,
    trackId: trackId,
    playedAt: playedAt,
    listenedMs: listenedMs,
    accountId: accountId,
  );

  /// Wire format of `POST /v1/history/events`.
  Map<String, Object?> toJson() => {
    'id': id,
    'track_id': trackId,
    'played_at': playedAt.toUtc().toIso8601String(),
    'listened_ms': listenedMs,
  };

  /// Outbox format: the wire format plus the owning account.
  Map<String, Object?> toStoredJson() => {
    ...toJson(),
    if (accountId != null) 'account_id': accountId,
  };

  factory PlayEvent.fromJson(Map<String, dynamic> json) => PlayEvent(
    id: json['id'] as String,
    trackId: json['track_id'] as String,
    playedAt: DateTime.parse(json['played_at'] as String),
    listenedMs: json['listened_ms'] as int,
    accountId: json['account_id'] as String?,
  );
}

class PlayEventsResult {
  const PlayEventsResult({required this.accepted, required this.duplicates});
  final int accepted;
  final int duplicates;
}

class CloudHistoryItem {
  const CloudHistoryItem({
    required this.eventId,
    required this.trackId,
    required this.playedAt,
    required this.listenedMs,
    required this.title,
    required this.artistName,
    required this.albumTitle,
  });
  final String eventId;
  final String trackId;
  final DateTime playedAt;
  final int listenedMs;
  final String title;
  final String? artistName;
  final String? albumTitle;
}

class CloudPlaylistSummary {
  const CloudPlaylistSummary({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String name;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CloudPlaylistItem {
  const CloudPlaylistItem({
    required this.id,
    required this.trackId,
    required this.position,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.trackAvailable,
  });
  final String id;
  final String trackId;
  final int position;
  final String title;
  final String? artistName;
  final String? albumTitle;
  final bool trackAvailable;
}

class CloudPlaylist {
  const CloudPlaylist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CloudPlaylistItem> items;
}

class CandidateAnalysis {
  const CandidateAnalysis({
    required this.embedding,
    required this.embeddingDimension,
    required this.embeddingModel,
    required this.embeddingVersion,
    required this.analysisVersion,
    required this.valence,
    required this.arousal,
    required this.emotionVersion,
  });
  final List<double> embedding;
  final int embeddingDimension;
  final String embeddingModel;
  final String embeddingVersion;
  final int analysisVersion;
  final double valence;
  final double arousal;
  final String emotionVersion;
}

class DiscoverCandidate {
  const DiscoverCandidate({
    required this.trackId,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.albumArtist,
    required this.trackNumber,
    required this.discNumber,
    required this.year,
    required this.genres,
    required this.duration,
    required this.hasArtwork,
    required this.analysis,
  });
  final String trackId;
  final String title;
  final String? artistName;
  final String? albumTitle;
  final String? albumArtist;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final List<String> genres;
  final Duration duration;
  final bool hasArtwork;
  final CandidateAnalysis analysis;
}

/// POST /v1/tracks result.
class CloudTrack {
  const CloudTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.duration,
    required this.hasArtwork,
    required this.addedAt,
  });
  final String id;
  final String title;
  final String? artistName;
  final String? albumTitle;
  final Duration duration;
  final bool hasArtwork;
  final DateTime addedAt;
}

enum SyncMode { snapshot, delta }

/// `type` and `payload` are opaque: the published contract does not define
/// them (see docs/CLOUD_INTEGRATION.md, blocker B).
class SyncEvent {
  const SyncEvent({
    required this.id,
    required this.type,
    required this.version,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });
  final String? id;
  final String type;
  final int version;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime? createdAt;
}

class SyncPage {
  const SyncPage({
    required this.mode,
    required this.events,
    required this.nextCursor,
    required this.hasMore,
  });
  final SyncMode mode;
  final List<SyncEvent> events;
  final String nextCursor;
  final bool hasMore;
}
