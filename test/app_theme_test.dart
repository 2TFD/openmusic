import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;
import 'package:owlsonic/core/themes/app_theme.dart';

/// Pretends Figtree is bundled with the app, which is how google_fonts looks
/// fonts up before it considers the network.
class _BundledFigtree implements AssetManifest {
  static const _weights = [
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
    'Black',
  ];

  static final _assets = [
    for (final weight in _weights) ...[
      'google_fonts/Figtree-$weight.ttf',
      'google_fonts/Figtree-${weight == 'Regular' ? '' : weight}Italic.ttf',
    ],
  ];

  @override
  List<String> listAssets() => _assets;

  @override
  List<AssetMetadata>? getAssetVariants(String key) => _assets.contains(key)
      ? [AssetMetadata(key: key, targetDevicePixelRatio: null, main: true)]
      : null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetChannel = 'flutter/assets';
  late bool previousFetching;
  late AssetManifest? previousManifest;

  setUpAll(() {
    // The theme asks google_fonts for Figtree. Tests must never reach the
    // network for it, so fetching is off and the font is served locally.
    previousFetching = GoogleFonts.config.allowRuntimeFetching;
    previousManifest = google_fonts_base.assetManifest;
    GoogleFonts.config.allowRuntimeFetching = false;
    google_fonts_base.assetManifest = _BundledFigtree();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(assetChannel, (message) async {
          // Not a real font: enough for the loader, no network involved.
          return ByteData.sublistView(Uint8List(16));
        });
  });

  tearDownAll(() {
    GoogleFonts.config.allowRuntimeFetching = previousFetching;
    google_fonts_base.assetManifest = previousManifest;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(assetChannel, null);
  });

  group('AppTheme Tests', () {
    test('AppTheme.dark should be instantiated without errors', () async {
      final theme = AppTheme.dark;
      // Let google_fonts finish (or fail) loading before the test ends, so an
      // error cannot surface after it.
      await GoogleFonts.pendingFonts();

      expect(theme.scaffoldBackgroundColor, AppColors.bg);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.outline, AppColors.border);
      expect(theme.appBarTheme.elevation, 0);
      expect(AppSpacing.pageMaxWidth, 760);
      expect(AppRadius.card, 24);
      expect(theme.textTheme.bodyMedium?.fontFamily, contains('Figtree'));
    });
  });
}
