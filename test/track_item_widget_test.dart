import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('more action does not trigger track selection', (tester) async {
    var selected = false;
    var openedMenu = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrackItem(
            track: _track(),
            isCurrent: false,
            isPlaying: false,
            isAvailable: true,
            onTap: () => selected = true,
            onMoreTap: () => openedMenu = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump();

    expect(openedMenu, isTrue);
    expect(selected, isFalse);
  });

  testWidgets('failed download action does not trigger track selection', (
    tester,
  ) async {
    var selected = false;
    var openedFailure = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrackItem(
            track: _track(filePath: null),
            isCurrent: false,
            isPlaying: false,
            isAvailable: false,
            downloadTask: DownloadTrackTask(
              trackId: 'track-1',
              originalUrl: 'https://example.com/track',
              status: DownloadStatus.failed,
              createdAt: DateTime.utc(2026, 8, 18),
            ),
            onTap: () => selected = true,
            onDownloadStatusTap: () => openedFailure = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.error_outline));
    await tester.pump();

    expect(openedFailure, isTrue);
    expect(selected, isFalse);
  });

  testWidgets('artwork fallback honors the requested dimensions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CachedImage(size: 36))),
    );

    expect(tester.getSize(find.byType(CachedImage)), const Size.square(36));
  });

  testWidgets('artwork accepts a custom fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CachedImage(size: 36, fallback: Icon(Icons.music_note_rounded)),
        ),
      ),
    );

    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });
}

Track _track({String? filePath = 'track.mp3'}) => Track(
  id: 'track-1',
  title: 'Track',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: const Source(
    type: SourceType.localFile,
    originalUrl: '/music/track.mp3',
  ),
  addedAt: DateTime.utc(2026),
  filePath: filePath,
);
