import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/app_router/app_router.dart';

void main() {
  test('AppRouter exposes one stable router instance', () {
    final first = AppRouter.router;
    final second = AppRouter.router;

    expect(identical(first, second), isTrue);
  });
}
