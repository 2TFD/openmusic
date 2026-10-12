import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/repositories/track_external_actions.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/sheets/track_context_sheets.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => {});
    await EasyLocalization.ensureInitialized();
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('desktop track actions use an anchored menu', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final track = Track(
      id: 'track-1',
      title: 'Track',
      artists: const [Artist(id: 'artist-1', name: 'Artist')],
      duration: const Duration(minutes: 3),
      source: const Source(
        type: SourceType.soundcloud,
        originalUrl: 'https://soundcloud.com/artist/track',
      ),
      addedAt: DateTime.utc(2026),
      filePath: 'track.mp3',
    );
    Track? waveSeed;
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => RepositoryProvider<TrackExternalActions>.value(
            value: _FakeExternalActions(),
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
                      onStartWave: (seed) => waveSeed = seed,
                    ),
                    child: const Text('Open actions'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open actions'));
    await tester.pumpAndSettle();
    expect(find.text('Open in SoundCloud'), findsOneWidget);
    expect(find.text('Track'), findsNothing);
    await tester.tap(find.text('Start Wave'));
    await tester.pumpAndSettle();
    expect(waveSeed?.id, 'track-1');
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });
}

class _FakeExternalActions implements TrackExternalActions {
  @override
  Future<void> openSource(Track track, {Rect? sharePositionOrigin}) async {}

  @override
  Future<void> openMediaSource(Track track) async {}
}
