import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/services/track_external_actions_service.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'openmusic-external-actions-',
    );
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true);
  });

  test('opens the original SoundCloud URL externally', () async {
    Uri? launchedUri;
    final service = TrackExternalActionsService(
      appDirectory: tempDirectory.path,
      launchExternalUrl: (uri) async {
        launchedUri = uri;
        return true;
      },
      shareLocalFile: (_, _, _) async => fail('must not share a URL'),
    );

    await service.openSource(
      _track(
        source: const Source(
          type: SourceType.soundcloud,
          originalUrl: 'https://soundcloud.com/artist/track',
        ),
      ),
    );

    expect(launchedUri, Uri.parse('https://soundcloud.com/artist/track'));
  });

  test('reports a SoundCloud URL that the platform cannot open', () async {
    final service = TrackExternalActionsService(
      appDirectory: tempDirectory.path,
      launchExternalUrl: (_) async => false,
    );

    expect(
      () => service.openSource(
        _track(
          source: const Source(
            type: SourceType.soundcloud,
            originalUrl: 'https://soundcloud.com/artist/track',
          ),
        ),
      ),
      throwsA(isA<RemoteServiceFailure>()),
    );
  });

  test('shares a relative local path from the app directory', () async {
    final audioFile = File('${tempDirectory.path}/track.mp3');
    await audioFile.writeAsBytes([1, 2, 3]);
    String? sharedPath;
    String? sharedTitle;
    Rect? sharedOrigin;
    const origin = Rect.fromLTWH(10, 20, 44, 44);
    final service = TrackExternalActionsService(
      appDirectory: tempDirectory.path,
      launchExternalUrl: (_) async => fail('must not launch a local file'),
      shareLocalFile: (filePath, title, sharePositionOrigin) async {
        sharedPath = filePath;
        sharedTitle = title;
        sharedOrigin = sharePositionOrigin;
      },
    );

    await service.openSource(
      _track(
        source: const Source(
          type: SourceType.localFile,
          originalUrl: '/old/import/path.mp3',
        ),
        filePath: 'track.mp3',
      ),
      sharePositionOrigin: origin,
    );

    expect(sharedPath, audioFile.path);
    expect(sharedTitle, 'Track');
    expect(sharedOrigin, origin);
  });

  test('reports a missing local copy instead of using the original path', () {
    final service = TrackExternalActionsService(
      appDirectory: tempDirectory.path,
    );

    expect(
      () => service.openSource(
        _track(
          source: const Source(
            type: SourceType.localFile,
            originalUrl: '/old/import/path.mp3',
          ),
          filePath: 'missing.mp3',
        ),
      ),
      throwsA(isA<FileNotFoundFailure>()),
    );
  });

  test('rejects an unknown source', () {
    final service = TrackExternalActionsService(
      appDirectory: tempDirectory.path,
    );

    expect(
      () => service.openSource(
        _track(
          source: const Source(
            type: SourceType.unknown,
            originalUrl: 'unknown',
          ),
        ),
      ),
      throwsA(isA<UnsupportedSourceFailure>()),
    );
  });
}

Track _track({required Source source, String? filePath = 'track.mp3'}) => Track(
  id: 'track-1',
  title: 'Track',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: source,
  addedAt: DateTime.utc(2026),
  filePath: filePath,
);
