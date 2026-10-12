import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_logo.dart';

void main() {
  testWidgets('brand logo uses the canonical asset and semantic name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OwlSonicLogo(width: 80))),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, OwlSonicLogo.assetPath);
    expect(image.width, 80);

    final semantics = tester.getSemantics(find.byType(OwlSonicLogo));
    expect(semantics.label, 'OwlSonic');
  });
}
