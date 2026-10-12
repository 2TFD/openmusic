import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_feature_card.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';

void main() {
  testWidgets('Wave and Mood Map use the same compact feature-card family', (
    tester,
  ) async {
    var selected = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: [
              OwlSonicFeatureCard(
                label: 'Wave',
                title: 'Start a Wave',
                description: 'Choose a track, artist, or mood',
                glyph: OwlSonicGlyphType.wave,
                onTap: () => selected = 'wave',
              ),
              OwlSonicFeatureCard(
                label: 'Mood Map',
                title: 'Explore by Mood',
                description: 'Move through your library by feeling',
                glyph: OwlSonicGlyphType.moodMap,
                moodField: true,
                onTap: () => selected = 'mood',
              ),
            ],
          ),
        ),
      ),
    );

    final cards = find.byType(OwlSonicFeatureCard);
    expect(cards, findsNWidgets(2));
    expect(tester.getSize(cards.at(0)).height, 110);
    expect(tester.getSize(cards.at(1)).height, 110);

    final glyphs = tester.widgetList<OwlSonicGlyph>(find.byType(OwlSonicGlyph));
    expect(glyphs.map((glyph) => glyph.type), [
      OwlSonicGlyphType.wave,
      OwlSonicGlyphType.moodMap,
    ]);
    expect(glyphs.map((glyph) => glyph.size), everyElement(40));

    await tester.tap(find.text('Explore by Mood'));
    expect(selected, 'mood');
  });
}
