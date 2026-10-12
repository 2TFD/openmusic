import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:owlsonic/layers/data/database/app_database.dart';
import 'package:owlsonic/layers/domain/entities/cloud/cloud_upload.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:uuid/uuid.dart';

enum CloudUploadStatus { pending, succeeded, failed }

class CloudUploadRecord {
  const CloudUploadRecord({
    required this.id,
    required this.request,
    required this.status,
    this.sourceTrackId,
    this.contentIdentity,
    this.errorCode,
  });

  final String id;
  final CloudUploadRequest request;
  final CloudUploadStatus status;
  final String? sourceTrackId;
  final String? contentIdentity;
  final String? errorCode;
}

/// Durable upload records. A logical upload keeps one track id (UUIDv7) and
/// one Idempotency-Key from creation until success, across retries and app
/// restarts. A different file/track always gets a new key.
class CloudUploadStore {
  CloudUploadStore(
    this.db, {
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : _uuid = uuid,
       _now = now ?? (() => DateTime.now().toUtc());

  final AppDatabase db;
  final Uuid _uuid;
  final DateTime Function() _now;

  String newTrackId() => _uuid.v7();
  String newIdempotencyKey() => 'owlsonic-upload:${_uuid.v4()}';

  /// Reuses an unfinished record for the same file (a retry of the same
  /// logical upload) or creates a new one.
  Future<CloudUploadRecord> createOrReuse({
    required String audioPath,
    required TrackManifest Function(String trackId) manifestFor,
    String? artworkPath,
    String? sourceTrackId,
    String? contentIdentity,
  }) => db.transaction(() async {
    final existing =
        await (db.select(db.cloudUploadTable)
              ..where(
                (t) =>
                    t.audioPath.equals(audioPath) &
                    t.status.isNotIn([CloudUploadStatus.succeeded.name]) &
                    (sourceTrackId == null
                        ? t.sourceTrackId.isNull()
                        : t.sourceTrackId.equals(sourceTrackId)),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return _map(existing);

    final now = _now();
    final trackId = newTrackId();
    final id = _uuid.v4();
    await db
        .into(db.cloudUploadTable)
        .insert(
          CloudUploadTableCompanion.insert(
            id: id,
            trackId: trackId,
            idempotencyKey: newIdempotencyKey(),
            audioPath: audioPath,
            artworkPath: Value(artworkPath),
            manifestJson: jsonEncode(manifestFor(trackId).toJson()),
            sourceTrackId: Value(sourceTrackId),
            contentIdentity: Value(contentIdentity),
            status: CloudUploadStatus.pending.name,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await get(id))!;
  });

  Future<CloudUploadRecord?> get(String id) async {
    final row = await (db.select(
      db.cloudUploadTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  Future<CloudUploadRecord?> byTrackId(String trackId) async {
    final row = await (db.select(
      db.cloudUploadTable,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  /// Unfinished uploads to resume after a restart. Permanently failed ones
  /// wait for an explicit user retry.
  Future<List<CloudUploadRecord>> pending() async => [
    for (final row in await (db.select(
      db.cloudUploadTable,
    )..where((t) => t.status.equals(CloudUploadStatus.pending.name))).get())
      _map(row),
  ];

  Future<void> markSucceeded(String id) => _update(
    id,
    CloudUploadTableCompanion(
      status: Value(CloudUploadStatus.succeeded.name),
      errorCode: const Value(null),
      errorMessage: const Value(null),
    ),
  );

  /// [retryable] failures stay `pending` so they resume with the same key.
  Future<void> markFailed(
    String id, {
    required String? code,
    required String? message,
    required bool retryable,
    required int attempts,
  }) => _update(
    id,
    CloudUploadTableCompanion(
      status: Value(
        (retryable ? CloudUploadStatus.pending : CloudUploadStatus.failed).name,
      ),
      errorCode: Value(code),
      errorMessage: Value(message),
      attempts: Value(attempts),
    ),
  );

  /// TRACK_ID_CONFLICT: the id belongs to another Track. This becomes a new
  /// logical upload, so both the track id and the key are regenerated.
  Future<CloudUploadRecord> regenerateIdentity(String id) async {
    final record = (await get(id))!;
    final trackId = newTrackId();
    final manifest = record.request.manifest;
    await _update(
      id,
      CloudUploadTableCompanion(
        trackId: Value(trackId),
        idempotencyKey: Value(newIdempotencyKey()),
        manifestJson: Value(
          jsonEncode(
            TrackManifest(
              trackId: trackId,
              title: manifest.title,
              sourceProvider: manifest.sourceProvider,
              artistName: manifest.artistName,
              albumTitle: manifest.albumTitle,
              albumArtist: manifest.albumArtist,
              trackNumber: manifest.trackNumber,
              discNumber: manifest.discNumber,
              year: manifest.year,
              genres: manifest.genres,
            ).toJson(),
          ),
        ),
        status: Value(CloudUploadStatus.pending.name),
      ),
    );
    return (await get(id))!;
  }

  /// Drops unfinished records of [ids] (e.g. of a session that ended), so they
  /// never resume under another account. Succeeded records and files stay.
  Future<void> discardUnfinished(Iterable<String> ids) async {
    final list = ids.toList();
    for (var start = 0; start < list.length; start += 200) {
      final chunk = list.sublist(start, (start + 200).clamp(0, list.length));
      await (db.delete(db.cloudUploadTable)..where(
            (t) =>
                t.id.isIn(chunk) &
                t.status.equals(CloudUploadStatus.succeeded.name).not(),
          ))
          .go();
    }
  }

  /// Local-only tracks with a playable managed file that were never migrated.
  Future<List<TrackTableData>> migrationCandidates() async {
    final migrated =
        (await (db.select(db.cloudUploadTable)..where(
                  (t) =>
                      t.sourceTrackId.isNotNull() &
                      t.status.equals(CloudUploadStatus.succeeded.name),
                ))
                .get())
            .map((row) => row.sourceTrackId!)
            .toSet();
    final rows =
        await (db.select(db.trackTable)..where(
              (t) =>
                  t.sourceType.equals(SourceType.owlsonic.name).not() &
                  t.pathToFile.isNotNull(),
            ))
            .get();
    return rows.where((row) => !migrated.contains(row.id)).toList();
  }

  /// Local tracks whose upload failed for a reason a retry will not fix (too
  /// large, unsupported, storage full). Automatic upload leaves them alone;
  /// the manual action in Account still tries them.
  Future<Set<String>> permanentlyFailedSourceTracks() async => {
    for (final row
        in await (db.select(db.cloudUploadTable)..where(
              (t) =>
                  t.sourceTrackId.isNotNull() &
                  t.status.equals(CloudUploadStatus.failed.name),
            ))
            .get())
      row.sourceTrackId!,
  };

  Future<void> _update(String id, CloudUploadTableCompanion companion) =>
      (db.update(db.cloudUploadTable)..where((t) => t.id.equals(id))).write(
        companion.copyWith(updatedAt: Value(_now())),
      );

  CloudUploadRecord _map(CloudUploadTableData row) => CloudUploadRecord(
    id: row.id,
    status: CloudUploadStatus.values.byName(row.status),
    sourceTrackId: row.sourceTrackId,
    contentIdentity: row.contentIdentity,
    errorCode: row.errorCode,
    request: CloudUploadRequest(
      localId: row.id,
      audioPath: row.audioPath,
      artworkPath: row.artworkPath,
      idempotencyKey: row.idempotencyKey,
      manifest: TrackManifest.fromJson(
        jsonDecode(row.manifestJson) as Map<String, dynamic>,
      ),
    ),
  );
}
