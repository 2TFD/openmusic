import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openmusic/core/themes/app_theme.dart';

class GooTransitionPage<T> extends CustomTransitionPage<T> {
  GooTransitionPage({required super.child, super.key})
    : super(
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _GooTransition(animation: animation, child: child);
        },
      );
}

class _GooTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _GooTransition({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final t4 = ((t - 0.15) / 0.85).clamp(0.0, 1.0);
        final r4 = Tween(
          begin: 0.0,
          end: 280.0,
        ).transform(Curves.easeOutExpo.transform(t4));

        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: GooPainter([
                GooBlob(
                  center: Offset(size.width * 0.2, size.height * 0.5),
                  radius: r4,
                ),
                GooBlob(
                  center: Offset(size.width * 1, size.height * 0.6),
                  radius: r4,
                ),
                GooBlob(
                  center: Offset(size.width * 0.4, size.height),
                  radius: r4,
                ),
                GooBlob(
                  center: Offset(size.width * 0.6, size.height * 0.1),
                  radius: r4,
                ),
              ]),
            ),
            AnimatedOpacity(
              opacity: t < 0.5 ? 0 : 1,
              duration: Duration(milliseconds: 400),
              child: child,
            ),
          ],
        );
      },
    );
  }
}

class GooPainter extends CustomPainter {
  final List<GooBlob> blobs;

  GooPainter(this.blobs);

  @override
  void paint(Canvas canvas, Size size) {
    // saveLayer с ColorFilter — аналог feColorMatrix
    // multiply=22, shift=-9 по альфа = порог слияния
    final layerPaint = Paint()
      ..colorFilter = const ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 22, -9 * 255, // порог альфа
      ]);

    canvas.saveLayer(Offset.zero & size, layerPaint);

    for (final blob in blobs) {
      final blobPaint = Paint()
        ..color = AppColors.bg
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        ); // feGaussianBlur

      canvas.drawCircle(blob.center, blob.radius, blobPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(GooPainter old) => old.blobs != blobs;
}

class GooBlob {
  final Offset center;
  final double radius;
  const GooBlob({required this.center, required this.radius});
}
