import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/bootstrap/app_initializer.dart';
import 'package:openmusic/core/bootstrap/bootstrap_host.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    const preferencesChannel = MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          preferencesChannel,
          (_) async => <String, Object>{},
        );
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('fatal bootstrap screen retries the failed step', (tester) async {
    var attempts = 0;
    final initializer = AppInitializer([
      BootstrapStep(BootstrapPhase.audio, () async {
        attempts++;
        if (attempts == 1) throw StateError('audio unavailable');
      }),
    ]);

    await tester.pumpWidget(
      BootstrapHost(
        initializer: initializer,
        appBuilder: (_) => const MaterialApp(home: Text('ready')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('bootstrap-failure')), findsOneWidget);
    expect(find.byKey(const ValueKey('bootstrap-retry')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bootstrap-retry')));
    await tester.pumpAndSettle();

    expect(find.text('ready'), findsOneWidget);
    expect(attempts, 2);
  });
}
