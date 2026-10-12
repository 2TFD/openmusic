import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';

/// Typed `GET /v1/sync` events, one class per (type, payload version) pair of
/// the OpenAPI `SyncEventOut` union.
sealed class CloudSyncEvent {
  const CloudSyncEvent({required this.id, required this.entityId});

  /// Null for snapshot events.
  final String? id;
  final String entityId;
}

/// `library.upsert` v1 (legacy, no personal state) and v2 (full item).
final class LibraryUpsertSyncEvent extends CloudSyncEvent {
  const LibraryUpsertSyncEvent({
    required super.id,
    required super.entityId,
    required this.item,
    required this.version,
  });

  /// For v1, personal fields (favorite, custom mood, play aggregates) carry
  /// defaults and must not overwrite known local values; see
  /// [hasPersonalState].
  final CloudLibraryItem item;
  final int version;

  bool get hasPersonalState => version >= 2;
}

final class LibraryDeleteSyncEvent extends CloudSyncEvent {
  const LibraryDeleteSyncEvent({
    required super.id,
    required super.entityId,
    required this.trackId,
  });
  final String trackId;
}

/// `analysis.upsert` v1. [analysis] is non-null exactly when status is ready.
final class AnalysisUpsertSyncEvent extends CloudSyncEvent {
  const AnalysisUpsertSyncEvent({
    required super.id,
    required super.entityId,
    required this.trackId,
    required this.analysis,
  });
  final String trackId;
  final CloudCanonicalAnalysis? analysis;

  bool get failed => analysis == null;
}

final class PlaylistUpsertSyncEvent extends CloudSyncEvent {
  const PlaylistUpsertSyncEvent({
    required super.id,
    required super.entityId,
    required this.playlistId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  final String playlistId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class PlaylistDeleteSyncEvent extends CloudSyncEvent {
  const PlaylistDeleteSyncEvent({
    required super.id,
    required super.entityId,
    required this.playlistId,
  });
  final String playlistId;
}

class CloudPlaylistItemRef {
  const CloudPlaylistItemRef({
    required this.itemId,
    required this.trackId,
    required this.position,
  });
  final String itemId;
  final String trackId;
  final int position;
}

/// Whole ordered item list (snapshot, not a diff).
final class PlaylistItemsSyncEvent extends CloudSyncEvent {
  const PlaylistItemsSyncEvent({
    required super.id,
    required super.entityId,
    required this.playlistId,
    required this.items,
    required this.updatedAt,
  });
  final String playlistId;
  final List<CloudPlaylistItemRef> items;
  final DateTime updatedAt;
}

final class HistoryAppendSyncEvent extends CloudSyncEvent {
  const HistoryAppendSyncEvent({
    required super.id,
    required super.entityId,
    required this.eventId,
    required this.trackId,
    required this.playedAt,
    required this.listenedMs,
    required this.playCount,
    required this.lastPlayedAt,
  });
  final String eventId;
  final String trackId;
  final DateTime playedAt;
  final int listenedMs;
  final int playCount;
  final DateTime lastPlayedAt;
}

/// Canonical, shared analysis of a library track (`analysis.upsert` ready).
class CloudCanonicalAnalysis {
  const CloudCanonicalAnalysis({
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

/// A sync event that cannot be applied safely. The page fails and the cursor
/// is not advanced.
class SyncEventRejected implements Exception {
  const SyncEventRejected({
    required this.type,
    required this.version,
    required this.reason,
    this.eventId,
  });
  final String type;
  final int version;
  final String reason;
  final String? eventId;

  @override
  String toString() =>
      'SyncEventRejected(type=$type, version=$version, id=$eventId: $reason)';
}
