import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/repositories/track_lyrics_repository_impl.dart';
import 'package:openmusic/layers/domain/entities/lyrics_resolution_state.dart';
import 'package:openmusic/layers/domain/entities/track_lyrics.dart';

const _hashA =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _hashB =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

void main() {
  late AppDatabase database;
  late TrackLyricsRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = TrackLyricsRepositoryImpl(database);
    await _insertTrack(database, 'track-1');
  });

  tearDown(() => database.close());

  test('lyrics and resolution state round-trip all persisted fields', () async {
    final fetchedAt = DateTime.utc(2026, 8, 20, 10);
    final updatedAt = DateTime.utc(2026, 8, 20, 11);
    final lyrics = TrackLyrics(
      trackId: 'track-1',
      source: LyricsSource.lrclib,
      sourceId: 'lrclib-42',
      plainText: 'Привет, мир\nHello, world',
      syncedText: '[00:01.00]Привет, мир\n[00:03.50]Hello, world',
      language: 'ru',
      contentHash: _hashA,
      matchConfidence: 0.97,
      matchedTitle: 'Song',
      matchedArtist: 'Artist',
      matchedDurationMs: 183000,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
    );
    final state = LyricsResolutionState(
      trackId: 'track-1',
      status: LyricsResolutionStatus.found,
      source: LyricsSource.lrclib,
      metadataRevision: 3,
      attemptCount: 2,
      lastAttemptAt: fetchedAt,
      retryAt: DateTime.utc(2026, 8, 21),
      failureCode: 'previous-timeout',
      failureMessage: 'Previous attempt timed out',
      updatedAt: updatedAt,
    );

    await repository.save(lyrics);
    await repository.saveResolutionState(state);

    final storedLyrics = await repository.getForTrack('track-1');
    expect(storedLyrics?.plainText, lyrics.plainText);
    expect(storedLyrics?.syncedText, lyrics.syncedText);
    expect(storedLyrics?.contentHash, lyrics.contentHash);
    expect(storedLyrics?.fetchedAt.isAtSameMomentAs(lyrics.fetchedAt), isTrue);
    expect(storedLyrics?.updatedAt.isAtSameMomentAs(lyrics.updatedAt), isTrue);
    final storedState = await repository.getResolutionState('track-1');
    expect(storedState?.status, state.status);
    expect(storedState?.metadataRevision, state.metadataRevision);
    expect(storedState?.attemptCount, state.attemptCount);
    expect(storedState?.retryAt?.isAtSameMomentAs(state.retryAt!), isTrue);
  });

  test('saving new lyrics updates the one-to-one row', () async {
    await repository.save(_lyrics(contentHash: _hashA));
    final replacement = _lyrics(
      source: LyricsSource.sidecarLrc,
      plainText: 'Changed lyrics',
      syncedText: '[00:01.00]Changed lyrics',
      contentHash: _hashB,
      updatedAt: DateTime.utc(2026, 8, 22),
    );

    await repository.save(replacement);

    final stored = await repository.getForTrack('track-1');
    expect(stored?.plainText, replacement.plainText);
    expect(stored?.source, replacement.source);
    expect(stored?.contentHash, replacement.contentHash);
    expect(stored?.updatedAt.isAtSameMomentAs(replacement.updatedAt), isTrue);
    expect(
      await database.select(database.trackLyricsTable).get(),
      hasLength(1),
    );
  });

  test('resolution terminal states stay distinct when updated', () async {
    for (final status in const [
      LyricsResolutionStatus.notFound,
      LyricsResolutionStatus.ambiguous,
      LyricsResolutionStatus.instrumental,
      LyricsResolutionStatus.failed,
    ]) {
      final state = LyricsResolutionState(
        trackId: 'track-1',
        status: status,
        attemptCount: 1,
        failureCode: status == LyricsResolutionStatus.failed ? 'network' : null,
        updatedAt: DateTime.utc(2026, 8, 20),
      );
      await repository.saveResolutionState(state);
      expect((await repository.getResolutionState('track-1'))?.status, status);
    }

    expect(
      await database.select(database.lyricsResolutionStateTable).get(),
      hasLength(1),
    );
  });

  test('track deletion cascades to lyrics and resolution state', () async {
    await repository.save(_lyrics(contentHash: _hashA));
    await repository.saveResolutionState(
      LyricsResolutionState(
        trackId: 'track-1',
        status: LyricsResolutionStatus.found,
        updatedAt: DateTime.utc(2026, 8, 20),
      ),
    );

    await database.customStatement(
      "DELETE FROM track_table WHERE id = 'track-1'",
    );

    expect(await repository.getForTrack('track-1'), isNull);
    expect(await repository.getResolutionState('track-1'), isNull);
  });
}

TrackLyrics _lyrics({
  LyricsSource source = LyricsSource.embedded,
  String plainText = 'Original lyrics',
  String? syncedText,
  required String contentHash,
  DateTime? updatedAt,
}) => TrackLyrics(
  trackId: 'track-1',
  source: source,
  plainText: plainText,
  syncedText: syncedText,
  contentHash: contentHash,
  fetchedAt: DateTime.utc(2026, 8, 20),
  updatedAt: updatedAt ?? DateTime.utc(2026, 8, 20),
);

Future<void> _insertTrack(AppDatabase database, String id) =>
    database.customStatement(
      'INSERT INTO track_table (id, title, source_type, source_uri) '
      'VALUES (?, ?, ?, ?)',
      [id, id, 'localFile', '/$id.mp3'],
    );
