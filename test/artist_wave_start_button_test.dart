import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/presentation/screens/artist_screen.dart';

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

  testWidgets('Artist card exposes one Start Wave action', (tester) async {
    var started = false;
    const artist = ArtistSummary(
      id: 'artist',
      name: 'Wave Artist',
      trackCount: 2,
      totalDuration: Duration(minutes: 6),
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: ArtistWaveStartButton(
                artist: artist,
                onPressed: () => started = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('start-artist-wave')), findsOneWidget);
    expect(find.text('Start Wave'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('start-artist-wave')));
    expect(started, isTrue);
  });
}
