import 'package:drift/drift.dart';

import '../../domain/entities/lyrics_resolution_state.dart';
import '../../domain/entities/track_lyrics.dart';
import '../../domain/repositories/track_lyrics_repository.dart';
import '../database/app_database.dart';

class TrackLyricsRepositoryImpl implements TrackLyricsRepository {
  TrackLyricsRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Future<TrackLyrics?> getForTrack(String trackId) async {
    final row = await (database.select(
      database.trackLyricsTable,
    )..where((table) => table.trackId.equals(trackId))).getSingleOrNull();
    return row == null ? null : _lyrics(row);
  }

  @override
  Future<void> save(TrackLyrics lyrics) => database
      .into(database.trackLyricsTable)
      .insertOnConflictUpdate(
        TrackLyricsTableCompanion.insert(
          trackId: lyrics.trackId,
          source: lyrics.source.name,
          sourceId: Value(lyrics.sourceId),
          plainText: lyrics.plainText,
          syncedText: Value(lyrics.syncedText),
          language: Value(lyrics.language),
          contentHash: lyrics.contentHash,
          isInstrumental: Value(lyrics.isInstrumental),
          matchConfidence: Value(lyrics.matchConfidence),
          matchedTitle: Value(lyrics.matchedTitle),
          matchedArtist: Value(lyrics.matchedArtist),
          matchedDurationMs: Value(lyrics.matchedDurationMs),
          fetchedAt: lyrics.fetchedAt,
          updatedAt: lyrics.updatedAt,
        ),
      );

  @override
  Future<LyricsResolutionState?> getResolutionState(String trackId) async {
    final row = await (database.select(
      database.lyricsResolutionStateTable,
    )..where((table) => table.trackId.equals(trackId))).getSingleOrNull();
    return row == null ? null : _state(row);
  }

  @override
  Future<void> saveResolutionState(LyricsResolutionState state) => database
      .into(database.lyricsResolutionStateTable)
      .insertOnConflictUpdate(
        LyricsResolutionStateTableCompanion.insert(
          trackId: state.trackId,
          status: state.status.name,
          provider: Value(state.source?.name),
          metadataRevision: Value(state.metadataRevision),
          attemptCount: Value(state.attemptCount),
          lastErrorCode: Value(state.failureCode),
          lastError: Value(state.failureMessage),
          nextRetryAt: Value(state.retryAt),
          lastAttemptAt: Value(state.lastAttemptAt),
          updatedAt: state.updatedAt,
        ),
      );

  @override
  Future<void> deleteForTrack(String trackId) => database.transaction(() async {
    await (database.delete(
      database.trackLyricsTable,
    )..where((table) => table.trackId.equals(trackId))).go();
    await (database.delete(
      database.lyricsResolutionStateTable,
    )..where((table) => table.trackId.equals(trackId))).go();
  });

  static TrackLyrics _lyrics(TrackLyricsTableData row) => TrackLyrics(
    trackId: row.trackId,
    source: LyricsSource.values.byName(row.source),
    sourceId: row.sourceId,
    plainText: row.plainText,
    syncedText: row.syncedText,
    language: row.language,
    contentHash: row.contentHash,
    isInstrumental: row.isInstrumental,
    matchConfidence: row.matchConfidence,
    matchedTitle: row.matchedTitle,
    matchedArtist: row.matchedArtist,
    matchedDurationMs: row.matchedDurationMs,
    fetchedAt: row.fetchedAt,
    updatedAt: row.updatedAt,
  );

  static LyricsResolutionState _state(LyricsResolutionStateTableData row) =>
      LyricsResolutionState(
        trackId: row.trackId,
        status: LyricsResolutionStatus.values.byName(row.status),
        source: row.provider == null
            ? null
            : LyricsSource.values.byName(row.provider!),
        metadataRevision: row.metadataRevision,
        attemptCount: row.attemptCount,
        lastAttemptAt: row.lastAttemptAt,
        retryAt: row.nextRetryAt,
        failureCode: row.lastErrorCode,
        failureMessage: row.lastError,
        updatedAt: row.updatedAt,
      );
}
