import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis_task.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('more action does not trigger track selection', (tester) async {
    var selected = false;
    var openedMenu = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MusicAnalysisStatusCubit>.value(
          value: _FakeStatusCubit(const MusicAnalysisStatusState()),
          child: Scaffold(
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
        home: BlocProvider<MusicAnalysisStatusCubit>.value(
          value: _FakeStatusCubit(const MusicAnalysisStatusState()),
          child: Scaffold(
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
      ),
    );

    await tester.tap(find.byIcon(Icons.error_outline));
    await tester.pump();

    expect(openedFailure, isTrue);
    expect(selected, isFalse);
  });

  testWidgets('failed analysis icon opens details without selecting track', (
    tester,
  ) async {
    var selected = false;
    final failedTask = MusicAnalysisTask(
      id: 'analysis-1',
      trackId: 'track-1',
      requestedRepresentations: const {MusicAnalysisRepresentation.audioGlobal},
      audioRevision: 1,
      status: MusicAnalysisTaskStatus.failed,
      attemptCount: 1,
      lastErrorCode: 'invalidRepresentation',
      lastError: 'invalid audio embedding dimension: null',
      createdAt: DateTime.utc(2026, 10, 5),
      updatedAt: DateTime.utc(2026, 10, 5),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MusicAnalysisStatusCubit>.value(
          value: _FakeStatusCubit(
            MusicAnalysisStatusState(activeTasks: {'track-1': failedTask}),
          ),
          child: Scaffold(
            body: TrackItem(
              track: _track(),
              isCurrent: false,
              isPlaying: false,
              isAvailable: true,
              onTap: () => selected = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('track-analysis-failed-track-1')),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('invalid audio embedding dimension: null'),
      findsOneWidget,
    );
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

  testWidgets('shows analysis running status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MusicAnalysisStatusCubit>.value(
          value: _FakeStatusCubit(
            MusicAnalysisStatusState(
              activeTasks: {
                'track-1': MusicAnalysisTask(
                  id: '1',
                  trackId: 'track-1',
                  requestedRepresentations: const {},
                  audioRevision: 1,
                  status: MusicAnalysisTaskStatus.running,
                  attemptCount: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              },
            ),
          ),
          child: Scaffold(
            body: TrackItem(
              track: _track(),
              isCurrent: false,
              isPlaying: false,
              isAvailable: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows analysis ready status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MusicAnalysisStatusCubit>.value(
          value: _FakeStatusCubit(
            const MusicAnalysisStatusState(analyzedTracks: {'track-1'}),
          ),
          child: Scaffold(
            body: TrackItem(
              track: _track(),
              isCurrent: false,
              isPlaying: false,
              isAvailable: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
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

class _FakeStatusCubit extends Cubit<MusicAnalysisStatusState>
    implements MusicAnalysisStatusCubit {
  _FakeStatusCubit(super.initialState);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
