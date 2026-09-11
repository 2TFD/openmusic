import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/layout/app_layout.dart';

void main() {
  group('AppLayout', () {
    test('classifies widths at the shared breakpoints', () {
      expect(AppLayout.windowSizeFor(599), AppWindowSize.compact);
      expect(AppLayout.windowSizeFor(600), AppWindowSize.medium);
      expect(AppLayout.windowSizeFor(839), AppWindowSize.medium);
      expect(AppLayout.windowSizeFor(840), AppWindowSize.expanded);
    });

    test('uses smaller gutters only on very narrow screens', () {
      expect(AppLayout.horizontalPaddingFor(320), 16);
      expect(AppLayout.horizontalPaddingFor(390), 24);
      expect(AppLayout.horizontalPaddingFor(700), 32);
      expect(AppLayout.horizontalPaddingFor(1000), 40);
    });

    test('calculates bounded grid column counts', () {
      expect(
        AppLayout.gridColumnCount(
          availableWidth: 288,
          minItemWidth: 145,
          minColumns: 2,
        ),
        2,
      );
      expect(
        AppLayout.gridColumnCount(
          availableWidth: 760,
          minItemWidth: 145,
          minColumns: 2,
        ),
        4,
      );
      expect(
        AppLayout.gridColumnCount(
          availableWidth: 2000,
          minItemWidth: 145,
          minColumns: 2,
        ),
        6,
      );
    });
  });

  group('AppContentFrame', () {
    Future<Size> pumpAtWidth(WidgetTester tester, double width) async {
      const contentKey = Key('content');
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: AppContentFrame(
            child: ColoredBox(key: contentKey, color: Colors.black),
          ),
        ),
      );
      return tester.getSize(find.byKey(contentKey));
    }

    testWidgets('uses all available width on phones and tablets', (
      tester,
    ) async {
      expect((await pumpAtWidth(tester, 320)).width, 320);
      expect((await pumpAtWidth(tester, 600)).width, 600);
      expect((await pumpAtWidth(tester, 840)).width, 840);
    });

    testWidgets('caps and centers content on wide windows', (tester) async {
      final size = await pumpAtWidth(tester, 1600);

      expect(size.width, AppLayout.maxContentWidth);
      expect(tester.getCenter(find.byKey(const Key('content'))).dx, 800);
    });
  });
}
