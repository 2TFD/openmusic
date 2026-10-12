import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_sync_events.dart';

/// Explicit `(type, version)` parser for the `SyncEventOut` union. The OpenAPI
/// union has no discriminator (`library.upsert` exists as v1 and v2), so
/// codegen discrimination is not used. Unknown pairs and malformed payloads
/// throw [SyncEventRejected]; nothing is guessed or silently skipped.
class OwlSonicSyncParser {
  const OwlSonicSyncParser();

  CloudSyncEvent parse(SyncEvent raw) {
    final key = (raw.type, raw.version);
    try {
      return switch (key) {
        ('library.upsert', 1) => _libraryUpsert(raw, personal: false),
        ('library.upsert', 2) => _libraryUpsert(raw, personal: true),
        ('library.delete', 1) => LibraryDeleteSyncEvent(
          id: raw.id,
          entityId: raw.entityId,
          trackId: _uuid(raw.payload, 'track_id'),
        ),
        ('analysis.upsert', 1) => _analysis(raw),
        ('playlist.upsert', 1) => PlaylistUpsertSyncEvent(
          id: raw.id,
          entityId: raw.entityId,
          playlistId: _uuid(raw.payload, 'playlist_id'),
          name: _string(raw.payload, 'name'),
          createdAt: _date(raw.payload, 'created_at'),
          updatedAt: _date(raw.payload, 'updated_at'),
        ),
        ('playlist.delete', 1) => PlaylistDeleteSyncEvent(
          id: raw.id,
          entityId: raw.entityId,
          playlistId: _uuid(raw.payload, 'playlist_id'),
        ),
        ('playlist.items', 1) => _playlistItems(raw),
        ('history.append', 1) => _historyAppend(raw),
        _ => throw SyncEventRejected(
          type: raw.type,
          version: raw.version,
          eventId: raw.id,
          reason: 'unsupported event type/version',
        ),
      };
    } on SyncEventRejected {
      rethrow;
    } on Object catch (error) {
      throw SyncEventRejected(
        type: raw.type,
        version: raw.version,
        eventId: raw.id,
        reason: 'malformed payload: ${_describe(error)}',
      );
    }
  }

  LibraryUpsertSyncEvent _libraryUpsert(
    SyncEvent raw, {
    required bool personal,
  }) {
    final p = raw.payload;
    return LibraryUpsertSyncEvent(
      id: raw.id,
      entityId: raw.entityId,
      version: raw.version,
      item: CloudLibraryItem(
        id: _uuid(p, 'track_id'),
        title: _string(p, 'canonical_title'),
        artistName: _optString(p, 'canonical_artist_name'),
        albumTitle: _optString(p, 'canonical_album_title'),
        albumArtist: _optString(p, 'album_artist'),
        trackNumber: _optInt(p, 'track_number'),
        discNumber: _optInt(p, 'disc_number'),
        year: _optInt(p, 'year'),
        genres: (p['genres'] as List).cast<String>().toList(growable: false),
        duration: Duration(milliseconds: _int(p, 'duration_ms')),
        hasArtwork: p['has_artwork'] as bool,
        analysisStatus: _status(p['analysis_status']),
        customTitle: _optString(p, 'custom_title'),
        customArtistName: _optString(p, 'custom_artist_name'),
        customAlbumTitle: _optString(p, 'custom_album_title'),
        addedAt: _date(p, 'added_at'),
        updatedAt: _date(p, 'updated_at'),
        favorite: personal ? p['favorite'] as bool : false,
        customValence: personal ? _optDouble(p, 'custom_valence') : null,
        customArousal: personal ? _optDouble(p, 'custom_arousal') : null,
        playCount: personal ? _int(p, 'play_count') : 0,
        lastPlayedAt: personal ? _optDate(p, 'last_played_at') : null,
      ),
    );
  }

  AnalysisUpsertSyncEvent _analysis(SyncEvent raw) {
    final p = raw.payload;
    final trackId = _uuid(p, 'track_id');
    final status = p['analysis_status'];
    if (status == 'failed') {
      return AnalysisUpsertSyncEvent(
        id: raw.id,
        entityId: raw.entityId,
        trackId: trackId,
        analysis: null,
      );
    }
    if (status != 'ready') {
      throw FormatException('analysis_status "$status"');
    }
    final dimension = _int(p, 'embedding_dimension');
    final embedding = (p['audio_embedding'] as List)
        .map((value) => (value as num).toDouble())
        .toList(growable: false);
    if (dimension <= 0 || embedding.length != dimension) {
      throw FormatException(
        'audio_embedding has ${embedding.length} values, '
        'embedding_dimension is $dimension',
      );
    }
    if (embedding.any((value) => !value.isFinite)) {
      throw const FormatException('audio_embedding has non-finite values');
    }
    return AnalysisUpsertSyncEvent(
      id: raw.id,
      entityId: raw.entityId,
      trackId: trackId,
      analysis: CloudCanonicalAnalysis(
        embedding: embedding,
        embeddingDimension: dimension,
        embeddingModel: _string(p, 'embedding_model'),
        embeddingVersion: _string(p, 'embedding_version'),
        analysisVersion: _int(p, 'analysis_version'),
        valence: _finite(p, 'valence'),
        arousal: _finite(p, 'arousal'),
        emotionVersion: _string(p, 'emotion_version'),
      ),
    );
  }

  PlaylistItemsSyncEvent _playlistItems(SyncEvent raw) {
    final p = raw.payload;
    return PlaylistItemsSyncEvent(
      id: raw.id,
      entityId: raw.entityId,
      playlistId: _uuid(p, 'playlist_id'),
      updatedAt: _date(p, 'updated_at'),
      items: (p['items'] as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .map(
            (item) => CloudPlaylistItemRef(
              itemId: _uuid(item, 'item_id'),
              trackId: _uuid(item, 'track_id'),
              position: _nonNegative(item, 'position'),
            ),
          )
          .toList(growable: false),
    );
  }

  HistoryAppendSyncEvent _historyAppend(SyncEvent raw) {
    final p = raw.payload;
    return HistoryAppendSyncEvent(
      id: raw.id,
      entityId: raw.entityId,
      eventId: _uuid(p, 'event_id'),
      trackId: _uuid(p, 'track_id'),
      playedAt: _date(p, 'played_at'),
      listenedMs: _nonNegative(p, 'listened_ms'),
      playCount: _nonNegative(p, 'play_count'),
      lastPlayedAt: _date(p, 'last_played_at'),
    );
  }

  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static String _uuid(Map<String, dynamic> p, String key) {
    final value = _string(p, key);
    if (!_uuidPattern.hasMatch(value)) throw FormatException('$key not a uuid');
    return value.toLowerCase();
  }

  static String _string(Map<String, dynamic> p, String key) {
    final value = p[key];
    if (value is! String) throw FormatException('$key missing');
    return value;
  }

  static String? _optString(Map<String, dynamic> p, String key) =>
      p[key] as String?;
  static int _int(Map<String, dynamic> p, String key) => p[key] as int;
  static int? _optInt(Map<String, dynamic> p, String key) => p[key] as int?;
  static int _nonNegative(Map<String, dynamic> p, String key) {
    final value = _int(p, key);
    if (value < 0) throw FormatException('$key negative');
    return value;
  }

  static double _finite(Map<String, dynamic> p, String key) {
    final value = (p[key] as num).toDouble();
    if (!value.isFinite) throw FormatException('$key not finite');
    return value;
  }

  static double? _optDouble(Map<String, dynamic> p, String key) {
    final value = p[key];
    if (value == null) return null;
    return _finite(p, key);
  }

  static DateTime _date(Map<String, dynamic> p, String key) =>
      DateTime.parse(_string(p, key)).toUtc();
  static DateTime? _optDate(Map<String, dynamic> p, String key) =>
      p[key] == null ? null : _date(p, key);

  static CloudAnalysisStatus _status(Object? value) {
    final status = CloudAnalysisStatus.parse(value);
    if (status == CloudAnalysisStatus.unknown) {
      throw FormatException('analysis_status "$value"');
    }
    return status;
  }

  // Diagnostics only: never include payload values (could be user metadata).
  static String _describe(Object error) => switch (error) {
    FormatException(:final message) => message,
    TypeError() => 'unexpected field type',
    _ => error.runtimeType.toString(),
  };
}
