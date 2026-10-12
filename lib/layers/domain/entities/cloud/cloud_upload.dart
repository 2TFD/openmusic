import 'package:owlsonic/layers/domain/entities/cloud/cloud_models.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';

/// One logical `POST /v1/tracks` upload. [trackId] and [idempotencyKey] are
/// generated once, persisted, and reused for every retry of this upload.
class CloudUploadRequest {
  const CloudUploadRequest({
    required this.localId,
    required this.audioPath,
    required this.manifest,
    required this.idempotencyKey,
    this.artworkPath,
  });

  /// Client-side id of the upload record (not a backend id).
  final String localId;
  final String audioPath;
  final String? artworkPath;
  final TrackManifest manifest;
  final String idempotencyKey;

  String get trackId => manifest.trackId;
}

enum TrackSourceKind {
  localUpload('LOCAL_UPLOAD'),
  communityImport('COMMUNITY_IMPORT');

  const TrackSourceKind(this.wire);
  final String wire;

  static TrackSourceKind parse(String? wire) =>
      values.firstWhere((kind) => kind.wire == wire, orElse: () => localUpload);
}

/// `source_provider` for audio downloaded from a link; null for local files.
String? communityProviderFor(SourceType type) => switch (type) {
  SourceType.soundcloud => 'soundcloud',
  SourceType.youtube => 'youtube',
  SourceType.spotify => 'spotify_match',
  _ => null,
};

/// OpenAPI `TrackManifest`: shared, user-independent content metadata only.
/// No technical properties (duration, MIME, codec, size, hash, path), owner or
/// personal state — the server rejects unknown fields and derives the rest.
class TrackManifest {
  TrackManifest({
    required this.trackId,
    required String title,
    String? sourceProvider,
    String? artistName,
    String? albumTitle,
    String? albumArtist,
    this.trackNumber,
    this.discNumber,
    this.year,
    List<String> genres = const [],
  }) : title = _text(title, maxLength: maxTitleLength) ?? '',
       sourceProvider = sourceProvider,
       sourceType = sourceProvider == null
           ? TrackSourceKind.localUpload
           : TrackSourceKind.communityImport,
       artistName = _text(artistName),
       albumTitle = _text(albumTitle),
       albumArtist = _text(albumArtist),
       genres = [
         for (final genre in genres) ?_text(genre),
       ].take(maxGenres).toList(growable: false) {
    if (this.title.isEmpty) throw ArgumentError.value(title, 'title');
  }

  static const maxTitleLength = 300;
  static const maxGenres = 20;

  final String trackId;
  final String title;
  final TrackSourceKind sourceType;

  /// Only sent with [TrackSourceKind.communityImport].
  final String? sourceProvider;
  final String? artistName;
  final String? albumTitle;
  final String? albumArtist;
  final int? trackNumber;
  final int? discNumber;
  final int? year;
  final List<String> genres;

  Map<String, Object?> toJson() => {
    'track_id': trackId,
    'title': title,
    'source_type': sourceType.wire,
    'source_provider': ?sourceProvider,
    'artist_name': ?artistName,
    'album_title': ?albumTitle,
    'album_artist': ?albumArtist,
    'track_number': ?trackNumber,
    'disc_number': ?discNumber,
    'year': ?year,
    if (genres.isNotEmpty) 'genres': genres,
  };

  factory TrackManifest.fromJson(Map<String, dynamic> json) => TrackManifest(
    trackId: json['track_id'] as String,
    title: json['title'] as String,
    sourceProvider:
        TrackSourceKind.parse(json['source_type'] as String?) ==
            TrackSourceKind.communityImport
        ? json['source_provider'] as String?
        : null,
    artistName: json['artist_name'] as String?,
    albumTitle: json['album_title'] as String?,
    albumArtist: json['album_artist'] as String?,
    trackNumber: json['track_number'] as int?,
    discNumber: json['disc_number'] as int?,
    year: json['year'] as int?,
    genres: (json['genres'] as List?)?.cast<String>() ?? const [],
  );

  /// Trims, removes control characters (rejected by the server) and enforces
  /// length limits so a long tag cannot turn into a permanent 422.
  static String? _text(String? value, {int? maxLength}) {
    if (value == null) return null;
    var text = value.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    if (maxLength != null && text.length > maxLength) {
      text = text.substring(0, maxLength).trimRight();
    }
    return text.isEmpty ? null : text;
  }
}

/// `Idempotency-Key`: 16-128 chars of `A-Za-z0-9._:-`.
final idempotencyKeyPattern = RegExp(r'^[A-Za-z0-9._:-]{16,128}$');

enum CloudUploadPhase {
  queued,
  uploading,
  retrying,
  succeeded,
  failed,
  skipped,
}

/// Item-level upload outcome, derived from the backend `error.code` (HTTP
/// status alone is ambiguous: 409 and 413 each carry several meanings).
enum CloudUploadFailureKind {
  network,
  signedOut,
  quotaExceeded,
  audioTooLarge,
  audioTooLong,
  artworkTooLarge,
  requestTooLarge,
  invalidAudio,
  unsupportedFormat,
  invalidArtwork,
  sanitizationFailed,
  trackIdConflict,
  idempotencyKeyReused,
  invalidRequest,
  ingestionInProgress,
  rateLimited,
  storageUnavailable,
  serviceUnavailable,
  server,
  fileMissing,
  cancelled,
  unknown;

  static CloudUploadFailureKind? fromCode(String code) => switch (code) {
    'STORAGE_QUOTA_EXCEEDED' => quotaExceeded,
    'AUDIO_TOO_LARGE' => audioTooLarge,
    'AUDIO_TOO_LONG' => audioTooLong,
    'ARTWORK_TOO_LARGE' => artworkTooLarge,
    'REQUEST_TOO_LARGE' => requestTooLarge,
    'INVALID_AUDIO' => invalidAudio,
    'UNSUPPORTED_AUDIO_FORMAT' => unsupportedFormat,
    'INVALID_ARTWORK' => invalidArtwork,
    'SANITIZATION_FAILED' => sanitizationFailed,
    'TRACK_ID_CONFLICT' => trackIdConflict,
    'IDEMPOTENCY_KEY_REUSED' => idempotencyKeyReused,
    'INVALID_REQUEST' => invalidRequest,
    'INGESTION_IN_PROGRESS' => ingestionInProgress,
    'RATE_LIMITED' => rateLimited,
    'STORAGE_UNAVAILABLE' => storageUnavailable,
    'SERVICE_UNAVAILABLE' => serviceUnavailable,
    'INTERNAL_ERROR' => server,
    'UNAUTHORIZED' || 'signed_out' => signedOut,
    _ => null,
  };
}

class CloudUploadItemState {
  const CloudUploadItemState({
    required this.localId,
    required this.phase,
    this.attempt = 0,
    this.sentBytes = 0,
    this.totalBytes = 0,
    this.track,
    this.failureKind,
    this.errorCode,
    this.errorMessage,
    this.requestId,
  });

  final String localId;
  final CloudUploadPhase phase;
  final int attempt;
  final int sentBytes;
  final int totalBytes;
  final CloudTrack? track;
  final CloudUploadFailureKind? failureKind;

  /// Backend `error.code`, kept verbatim so UI can follow server semantics
  /// (e.g. distinguishing 409 meanings) without the client guessing.
  final String? errorCode;
  final String? errorMessage;
  final String? requestId;

  double? get progress => totalBytes <= 0 ? null : sentBytes / totalBytes;
  bool get isTerminal =>
      phase == CloudUploadPhase.succeeded ||
      phase == CloudUploadPhase.failed ||
      phase == CloudUploadPhase.skipped;
}
