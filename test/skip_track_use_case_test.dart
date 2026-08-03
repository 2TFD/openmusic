import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/usecases/skip_track_use_case.dart';

void main() {
  const skip = SkipTrackUseCase();

  SkipAction next({bool hasNext = true}) => skip(
    SkipDirection.next,
    position: Duration.zero,
    hasNext: hasNext,
    hasPrev: true,
  );

  SkipAction previous({
    Duration position = Duration.zero,
    bool hasPrev = true,
  }) => skip(
    SkipDirection.previous,
    position: position,
    hasNext: true,
    hasPrev: hasPrev,
  );

  group('next', () {
    test('advances while there is a next track', () {
      expect(next(), isA<AdvanceToNextTrack>());
    });

    test('is rejected at the end of the queue', () {
      expect(next(hasNext: false), isA<SkipRejected>());
    });
  });

  group('previous', () {
    test('goes back within the restart threshold', () {
      expect(
        previous(position: const Duration(seconds: 3)),
        isA<AdvanceToPreviousTrack>(),
      );
    });

    test('restarts the track past the restart threshold', () {
      expect(
        previous(position: const Duration(milliseconds: 3001)),
        isA<RestartCurrentTrack>(),
      );
    });

    test('restarts instead of doing nothing on the first track', () {
      expect(previous(hasPrev: false), isA<RestartCurrentTrack>());
    });

    test('honours a custom threshold', () {
      const eager = SkipTrackUseCase(restartThreshold: Duration(seconds: 10));
      expect(
        eager(
          SkipDirection.previous,
          position: const Duration(seconds: 5),
          hasNext: true,
          hasPrev: true,
        ),
        isA<AdvanceToPreviousTrack>(),
      );
    });
  });
}
