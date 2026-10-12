import 'package:owlsonic/core/network/owlsonic/owlsonic_api_client.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';

/// Strict decoders for docs/openapi.json schemas. Any shape mismatch becomes an
/// `invalid_response` OwlSonicApiException instead of a TypeError deep in UI.
class OwlSonicJson {
  const OwlSonicJson._();

  static T guard<T>(String schema, T Function() decode) {
    try {
      return decode();
    } on TypeError {
      throw OwlSonicApiClient.invalidResponse(schema);
    } on FormatException {
      throw OwlSonicApiClient.invalidResponse(schema);
    }
  }

  static DateTime _date(Object? value) => DateTime.parse(value as String);
  static DateTime? _dateOrNull(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
  static double? _doubleOrNull(Object? value) =>
      value == null ? null : (value as num).toDouble();
  static List<String> _strings(Object? value) =>
      (value as List).map((item) => item as String).toList(growable: false);
  static List<Map<String, dynamic>> _maps(Object? value) => (value as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList(growable: false);

  static CloudUser user(JsonMap json) => guard(
    'MeResponse',
    () => CloudUser(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: _date(json['created_at']),
    ),
  );

  static StorageUsage usage(JsonMap json) => guard('UsageResponse', () {
    final storage = Map<String, dynamic>.from(json['storage'] as Map);
    return StorageUsage(
      usedBytes: storage['used_bytes'] as int,
      limitBytes: storage['limit_bytes'] as int?,
      remainingBytes: storage['remaining_bytes'] as int?,
      unlimited: storage['unlimited'] as bool,
      overLimit: storage['over_limit'] as bool,
    );
  });

  static List<CloudDevice> devices(JsonMap json) => guard(
    'DeviceListResponse',
    () => _maps(json['items'])
        .map(
          (item) => CloudDevice(
            id: item['id'] as String,
            platform: item['platform'] as String,
            deviceName: item['device_name'] as String?,
            appVersion: item['app_version'] as String?,
            createdAt: _date(item['created_at']),
            lastSeenAt: _date(item['last_seen_at']),
            current: item['current'] as bool,
          ),
        )
        .toList(growable: false),
  );

  static CloudLibraryItem libraryItem(JsonMap json) => guard(
    'LibraryItem',
    () => CloudLibraryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: json['artist_name'] as String?,
      albumTitle: json['album_title'] as String?,
      albumArtist: json['album_artist'] as String?,
      trackNumber: json['track_number'] as int?,
      discNumber: json['disc_number'] as int?,
      year: json['year'] as int?,
      genres: _strings(json['genres']),
      duration: Duration(milliseconds: json['duration_ms'] as int),
      hasArtwork: json['has_artwork'] as bool,
      analysisStatus: CloudAnalysisStatus.parse(json['analysis_status']),
      customTitle: json['custom_title'] as String?,
      customArtistName: json['custom_artist_name'] as String?,
      customAlbumTitle: json['custom_album_title'] as String?,
      addedAt: _date(json['added_at']),
      updatedAt: _date(json['updated_at']),
      favorite: json['favorite'] as bool,
      customValence: _doubleOrNull(json['custom_valence']),
      customArousal: _doubleOrNull(json['custom_arousal']),
      playCount: json['play_count'] as int,
      lastPlayedAt: _dateOrNull(json['last_played_at']),
    ),
  );

  static CloudPage<CloudLibraryItem> libraryPage(JsonMap json) => guard(
    'LibraryPage',
    () => CloudPage(
      items: _maps(json['items']).map(libraryItem).toList(growable: false),
      nextCursor: json['next_cursor'] as String?,
    ),
  );

  static SignedUrl signedUrl(JsonMap json) => guard(
    'SignedUrlResponse',
    () => SignedUrl(
      url: Uri.parse(json['url'] as String),
      expiresAt: _date(json['expires_at']),
    ),
  );

  static PlayEventsResult playEventsResult(JsonMap json) => guard(
    'PlayEventsResult',
    () => PlayEventsResult(
      accepted: json['accepted'] as int,
      duplicates: json['duplicates'] as int,
    ),
  );

  static CloudPage<CloudHistoryItem> historyPage(JsonMap json) => guard(
    'HistoryPage',
    () => CloudPage(
      items: _maps(json['items'])
          .map(
            (item) => CloudHistoryItem(
              eventId: item['event_id'] as String,
              trackId: item['track_id'] as String,
              playedAt: _date(item['played_at']),
              listenedMs: item['listened_ms'] as int,
              title: item['title'] as String,
              artistName: item['artist_name'] as String?,
              albumTitle: item['album_title'] as String?,
            ),
          )
          .toList(growable: false),
      nextCursor: json['next_cursor'] as String?,
    ),
  );

  static CloudPage<CloudPlaylistSummary> playlistPage(JsonMap json) => guard(
    'PlaylistPage',
    () => CloudPage(
      items: _maps(json['items'])
          .map(
            (item) => CloudPlaylistSummary(
              id: item['id'] as String,
              name: item['name'] as String,
              itemCount: item['item_count'] as int,
              createdAt: _date(item['created_at']),
              updatedAt: _date(item['updated_at']),
            ),
          )
          .toList(growable: false),
      nextCursor: json['next_cursor'] as String?,
    ),
  );

  static CloudPlaylistItem playlistItem(JsonMap json) => guard(
    'PlaylistItemOut',
    () => CloudPlaylistItem(
      id: json['id'] as String,
      trackId: json['track_id'] as String,
      position: json['position'] as int,
      title: json['title'] as String,
      artistName: json['artist_name'] as String?,
      albumTitle: json['album_title'] as String?,
      trackAvailable: json['track_available'] as bool,
    ),
  );

  static CloudPlaylist playlist(JsonMap json) => guard(
    'PlaylistDetail',
    () => CloudPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      items: _maps(json['items']).map(playlistItem).toList(growable: false),
    ),
  );

  static CandidateAnalysis candidateAnalysis(JsonMap json) => guard(
    'CandidateAnalysis',
    () => CandidateAnalysis(
      embedding: (json['embedding'] as List)
          .map((value) => (value as num).toDouble())
          .toList(growable: false),
      embeddingDimension: json['embedding_dimension'] as int,
      embeddingModel: json['embedding_model'] as String,
      embeddingVersion: json['embedding_version'] as String,
      analysisVersion: json['analysis_version'] as int,
      valence: (json['valence'] as num).toDouble(),
      arousal: (json['arousal'] as num).toDouble(),
      emotionVersion: json['emotion_version'] as String,
    ),
  );

  static CloudPage<DiscoverCandidate> candidatePage(JsonMap json) => guard(
    'CandidatePage',
    () => CloudPage(
      items: _maps(json['items'])
          .map(
            (item) => DiscoverCandidate(
              trackId: item['track_id'] as String,
              title: item['title'] as String,
              artistName: item['artist_name'] as String?,
              albumTitle: item['album_title'] as String?,
              albumArtist: item['album_artist'] as String?,
              trackNumber: item['track_number'] as int?,
              discNumber: item['disc_number'] as int?,
              year: item['year'] as int?,
              genres: _strings(item['genres']),
              duration: Duration(milliseconds: item['duration_ms'] as int),
              hasArtwork: item['has_artwork'] as bool,
              analysis: candidateAnalysis(
                Map<String, dynamic>.from(item['analysis'] as Map),
              ),
            ),
          )
          .toList(growable: false),
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool,
    ),
  );

  static CloudTrack track(JsonMap json) => guard(
    'TrackResponse',
    () => CloudTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: json['artist_name'] as String?,
      albumTitle: json['album_title'] as String?,
      duration: Duration(milliseconds: json['duration_ms'] as int),
      hasArtwork: json['has_artwork'] as bool,
      addedAt: _date(json['added_at']),
    ),
  );

  static SyncPage syncPage(JsonMap json) => guard(
    'SyncResponse',
    () => SyncPage(
      mode: switch (json['mode']) {
        'snapshot' => SyncMode.snapshot,
        'delta' => SyncMode.delta,
        _ => throw const FormatException('mode'),
      },
      events: _maps(json['events'])
          .map(
            (event) => SyncEvent(
              id: event['id'] as String?,
              type: event['type'] as String,
              version: event['version'] as int,
              entityId: event['entity_id'] as String,
              payload: Map<String, dynamic>.from(event['payload'] as Map),
              createdAt: _dateOrNull(event['created_at']),
            ),
          )
          .toList(growable: false),
      nextCursor: json['next_cursor'] as String,
      hasMore: json['has_more'] as bool,
    ),
  );
}
