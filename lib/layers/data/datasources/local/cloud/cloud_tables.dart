import 'package:drift/drift.dart';
import 'package:owlsonic/layers/data/datasources/local/playlist/drift/playlist_table.dart';
import 'package:owlsonic/layers/data/datasources/local/track/drift/track_table.dart';

/// Cloud library state of one track (`library.upsert` v1/v2). The matching
/// [TrackTable] row carries the effective (custom ?? canonical) metadata the
/// UI reads; this row keeps canonical values and personal state separately.
/// All rows belong to the signed-in account and are purged on sign-out.
class CloudLibraryItemTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get canonicalTitle => text()();
  TextColumn get canonicalArtistName => text().nullable()();
  TextColumn get canonicalAlbumTitle => text().nullable()();
  TextColumn get albumArtist => text().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  IntColumn get durationMs => integer()();
  BoolColumn get hasArtwork => boolean()();

  /// pending | ready | failed, from `library.upsert`.
  TextColumn get analysisStatus => text()();
  TextColumn get customTitle => text().nullable()();
  TextColumn get customArtistName => text().nullable()();
  TextColumn get customAlbumTitle => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  RealColumn get customValence => real().nullable()();
  RealColumn get customArousal => real().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

/// Canonical analysis metadata from `analysis.upsert` (status `ready`). The
/// embedding vector and valence/arousal are projected into the existing
/// embedding/emotion tables so Mood Map and Wave read them unchanged.
class CloudAnalysisTable extends Table {
  TextColumn get trackId =>
      text().references(TrackTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get analysisVersion => integer()();
  TextColumn get embeddingModel => text()();
  TextColumn get embeddingVersion => text()();
  IntColumn get embeddingDimension => integer()();
  TextColumn get emotionVersion => text()();
  RealColumn get valence => real()();
  RealColumn get arousal => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

/// Marks a [PlaylistTable] row as an OwlSonic cloud playlist.
class CloudPlaylistTable extends Table {
  TextColumn get playlistId =>
      text().references(PlaylistTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId};
}

/// Authoritative ordered item list of a cloud playlist (`playlist.items`).
/// The local playlist-track projection keeps one row per track.
class CloudPlaylistItemTable extends Table {
  TextColumn get itemId => text()();
  TextColumn get playlistId =>
      text().references(PlaylistTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

/// Durable state of one logical `POST /v1/tracks` upload. The track id and
/// Idempotency-Key are generated once and reused on every retry.
class CloudUploadTable extends Table {
  TextColumn get id => text()();
  TextColumn get trackId => text()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get audioPath => text()();
  TextColumn get artworkPath => text().nullable()();
  TextColumn get manifestJson => text()();

  /// Local-only track being migrated to the cloud, if any.
  TextColumn get sourceTrackId => text().nullable()();

  /// Content identity of the uploaded file, kept for duplicate warnings.
  TextColumn get contentIdentity => text().nullable()();

  /// pending | succeeded | failed
  TextColumn get status => text()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
