import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/presentation/features/playlist/ui/widgets/playlist_components.dart';

import 'package:owlsonic/layers/domain/repositories/download_task_repository.dart';
import 'package:owlsonic/layers/domain/usecases/retry_track_download_use_case.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_screen.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';

import 'support/ux_harness.dart';

class _NoDownloads extends Fake implements DownloadTaskRepository {}

void main() {
  useTestLocalization();

  testWidgets('a song that is not synced offers "Sync this song"', (
    tester,
  ) async {
    var synced = 0;
    var removed = 0;
    await pumpApp(
      tester,
      home: Scaffold(
        body: PlaylistTrackOptionsSheet(
          track: localTrack('a', 'Local song'),
          onRemove: () => removed++,
          onSync: () => synced++,
        ),
      ),
    );

    expect(find.text('Sync this song'), findsOneWidget);
    await tester.tap(find.text('Sync this song'));
    expect(synced, 1);
    expect(removed, 0);
  });

  testWidgets('a synced song only offers removing', (tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: PlaylistTrackOptionsSheet(
          track: localTrack('a', 'Song'),
          onRemove: () {},
        ),
      ),
    );
    expect(find.text('Sync this song'), findsNothing);
    expect(find.text('Remove from playlist'), findsOneWidget);
  });

  testWidgets('the desktop table flags songs that are not synced', (
    tester,
  ) async {
    final downloads = DownloadStatusCubit(
      tasks: const Stream.empty(),
      retryDownload: RetryTrackDownloadUseCase(_NoDownloads()),
    );
    addTearDown(downloads.close);
    await pumpApp(
      tester,
      size: const Size(1280, 800),
      home: Scaffold(
        body: DesktopLibraryTrackTable(
          tracks: [localTrack('a', 'Synced one'), localTrack('b', 'Local one')],
          unsyncedTrackIds: const {'b'},
        ),
      ),
      providers: [
        BlocProvider<DownloadStatusCubit>.value(value: downloads),
        BlocProvider<PlayerBloc>.value(value: RecordingPlayerBloc()),
      ],
    );

    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(
      find.byTooltip('Not synced: this song is not in OwlSonic yet'),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
