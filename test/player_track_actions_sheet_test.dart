import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/track_external_actions.dart';
import 'package:openmusic/layers/presentation/widgets/sheets/track_context_sheets.dart';

void main() {
  const preferencesChannel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, (_) async => {});
    await EasyLocalization.ensureInitialized();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, null);
  });

  testWidgets('track menu starts Wave and exposes source actions', (
    tester,
  ) async {
    final externalActions = _FakeExternalActions();
    Track? waveSeed;

    await tester.pumpWidget(
      _TestApp(
        externalActions: externalActions,
        track: _track(SourceType.localFile),
        onStartWave: (track) => waveSeed = track,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open actions'));
    await tester.pumpAndSettle();

    expect(find.text('Start Wave'), findsOneWidget);
    expect(find.text('Share file'), findsOneWidget);
    expect(find.text('Open in SoundCloud'), findsNothing);

    await tester.tap(find.text('Start Wave'));
    await tester.pumpAndSettle();
    expect(waveSeed?.id, _track(SourceType.localFile).id);

    final soundCloudTrack = _track(SourceType.soundcloud);
    await tester.pumpWidget(
      _TestApp(
        externalActions: externalActions,
        track: soundCloudTrack,
        onStartWave: (track) => waveSeed = track,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open in SoundCloud'));
    await tester.pumpAndSettle();

    expect(externalActions.openedTrack, soundCloudTrack);
    expect(externalActions.sharePositionOrigin, isNotNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.externalActions,
    required this.track,
    required this.onStartWave,
  });

  final TrackExternalActions externalActions;
  final Track track;
  final ValueChanged<Track> onStartWave;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: Builder(
        builder: (context) => RepositoryProvider<TrackExternalActions>.value(
          value: externalActions,
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showPlayerTrackActions(
                    context,
                    track,
                    onStartWave: onStartWave,
                  ),
                  child: const Text('Open actions'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeExternalActions implements TrackExternalActions {
  Track? openedTrack;
  Rect? sharePositionOrigin;

  @override
  Future<void> openSource(Track track, {Rect? sharePositionOrigin}) async {
    openedTrack = track;
    this.sharePositionOrigin = sharePositionOrigin;
  }
}

Track _track(SourceType type) => Track(
  id: 'track-1',
  title: 'Track',
  artists: const [Artist(id: 'artist-1', name: 'Artist')],
  duration: const Duration(minutes: 3),
  source: Source(
    type: type,
    originalUrl: type == SourceType.soundcloud
        ? 'https://soundcloud.com/artist/track'
        : '/music/track.mp3',
  ),
  addedAt: DateTime.utc(2026),
  filePath: 'track.mp3',
);
