import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/domain/repositories/local_track_picker.dart';
import 'package:openmusic/layers/domain/usecases/import_local_tracks_use_case.dart';
import 'package:openmusic/layers/domain/usecases/pick_local_tracks_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/embedding_status/embedding_status_cubit.dart';
import 'package:openmusic/layers/presentation/blocs/import_music/import_music_cubit.dart';

void main() {
  group('ImportMusicCubit', () {
    test('publishes selected local tracks', () async {
      final previews = [_preview('first'), _preview('second')];
      final cubit = _buildImportCubit(_FakeLocalTrackPicker(previews));
      final states = <ImportMusicState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.pickLocalTracks();
      await Future<void>.delayed(Duration.zero);

      expect(states, [isA<LocalTracksPicking>(), isA<LocalTracksPicked>()]);
      expect((cubit.state as LocalTracksPicked).previews, previews);

      await subscription.cancel();
      await cubit.close();
    });

    test('reports an empty file selection', () async {
      final cubit = _buildImportCubit(const _FakeLocalTrackPicker([]));

      await cubit.pickLocalTracks();

      expect(cubit.state, isA<LocalTracksSelectionEmpty>());
      await cubit.close();
    });

    test('counts successful and failed imports outside the widget', () async {
      final cubit = ImportMusicCubit(
        pickLocalTracks: const PickLocalTracksUseCase(
          _FakeLocalTrackPicker([]),
        ),
        importLocalTracks: ImportLocalTracksUseCase((input) async {
          if (input.firstTrack.id == 'failed') {
            throw StateError('failed import');
          }
        }),
      );

      await cubit.importLocalTracks([_preview('added'), _preview('failed')]);

      final state = cubit.state as LocalTracksImported;
      expect(state.result.added, 1);
      expect(state.result.failed, 1);
      await cubit.close();
    });
  });

  test(
    'EmbeddingStatusCubit owns and cancels the pending-count subscription',
    () async {
      final controller = StreamController<int>();
      final cubit = EmbeddingStatusCubit(pendingCounts: controller.stream);
      final states = <int>[];
      final subscription = cubit.stream.listen(states.add);

      controller.add(3);
      controller.add(1);
      await Future<void>.delayed(Duration.zero);

      expect(states, [3, 1]);
      expect(cubit.state, 1);

      await subscription.cancel();
      await cubit.close();
      await controller.close();
    },
  );
}

ImportMusicCubit _buildImportCubit(LocalTrackPicker picker) {
  return ImportMusicCubit(
    pickLocalTracks: PickLocalTracksUseCase(picker),
    importLocalTracks: ImportLocalTracksUseCase((_) async {}),
  );
}

TrackPreview _preview(String id) {
  return TrackPreview(
    id: id,
    title: id,
    artist: 'artist',
    source: SourceType.localFile,
    originalUrl: id,
    urlFile: id,
  );
}

class _FakeLocalTrackPicker implements LocalTrackPicker {
  const _FakeLocalTrackPicker(this.previews);

  final List<TrackPreview> previews;

  @override
  Future<List<TrackPreview>> pickTracks() async => previews;
}
