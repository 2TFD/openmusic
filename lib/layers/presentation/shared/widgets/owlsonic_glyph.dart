import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Small signature glyphs for OwlSonic's primary music concepts.
///
/// They intentionally use a single stroke and no enclosing shape so they can
/// sit quietly beside music artwork and typography.
enum OwlSonicGlyphType { wave, moodMap, library, history, queue, favorite }

class OwlSonicGlyph extends StatelessWidget {
  const OwlSonicGlyph({
    super.key,
    required this.type,
    this.size = 24,
    this.color,
    this.filled = false,
  });

  final OwlSonicGlyphType type;
  final double size;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _OwlSonicGlyphPainter(
          type: type,
          color: color ?? IconTheme.of(context).color ?? Colors.white,
          filled: filled,
        ),
      ),
    ),
  );
}

class _OwlSonicGlyphPainter extends CustomPainter {
  const _OwlSonicGlyphPainter({
    required this.type,
    required this.color,
    required this.filled,
  });

  final OwlSonicGlyphType type;
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final s = size.width;
    switch (type) {
      case OwlSonicGlyphType.wave:
        for (final y in [s * .31, s * .50, s * .69]) {
          final path = Path()
            ..moveTo(s * .10, y)
            ..cubicTo(s * .24, y - s * .11, s * .38, y + s * .11, s * .50, y)
            ..cubicTo(s * .62, y - s * .11, s * .76, y + s * .11, s * .90, y);
          canvas.drawPath(path, stroke);
        }
      case OwlSonicGlyphType.moodMap:
        // An asymmetric topographic field: recognisable as a space to move
        // through, without reading as a generic graph or location pin.
        final outer = Path()
          ..moveTo(s * .12, s * .55)
          ..cubicTo(s * .10, s * .27, s * .34, s * .12, s * .58, s * .17)
          ..cubicTo(s * .86, s * .22, s * .94, s * .47, s * .83, s * .70)
          ..cubicTo(s * .70, s * .94, s * .31, s * .89, s * .17, s * .72)
          ..close();
        final inner = Path()
          ..moveTo(s * .28, s * .57)
          ..cubicTo(s * .27, s * .38, s * .43, s * .27, s * .60, s * .31)
          ..cubicTo(s * .77, s * .35, s * .81, s * .51, s * .73, s * .64)
          ..cubicTo(s * .64, s * .78, s * .39, s * .75, s * .30, s * .65)
          ..close();
        canvas.drawPath(outer, stroke);
        canvas.drawPath(inner, stroke);
        canvas.drawCircle(Offset(s * .57, s * .52), s * .055, fill);
      case OwlSonicGlyphType.library:
        for (final x in [s * .25, s * .50, s * .75]) {
          canvas.drawLine(Offset(x, s * .20), Offset(x, s * .80), stroke);
        }
        canvas.drawCircle(Offset(s * .25, s * .38), s * .055, fill);
        canvas.drawCircle(Offset(s * .50, s * .62), s * .055, fill);
        canvas.drawCircle(Offset(s * .75, s * .31), s * .055, fill);
      case OwlSonicGlyphType.history:
        final rect = Rect.fromLTWH(s * .18, s * .18, s * .64, s * .64);
        canvas.drawArc(rect, -math.pi * .62, math.pi * 1.55, false, stroke);
        final path = Path()
          ..moveTo(s * .18, s * .30)
          ..lineTo(s * .18, s * .12)
          ..lineTo(s * .36, s * .12);
        canvas.drawPath(path, stroke);
        canvas.drawLine(
          Offset(s * .50, s * .34),
          Offset(s * .50, s * .51),
          stroke,
        );
        canvas.drawLine(
          Offset(s * .50, s * .51),
          Offset(s * .64, s * .59),
          stroke,
        );
      case OwlSonicGlyphType.queue:
        for (final y in [s * .29, s * .50, s * .71]) {
          canvas.drawLine(Offset(s * .16, y), Offset(s * .62, y), stroke);
        }
        canvas.drawCircle(Offset(s * .78, s * .29), s * .055, fill);
        canvas.drawCircle(Offset(s * .78, s * .50), s * .055, fill);
        canvas.drawCircle(Offset(s * .78, s * .71), s * .055, fill);
      case OwlSonicGlyphType.favorite:
        final path = Path()
          ..moveTo(s * .50, s * .79)
          ..cubicTo(s * .20, s * .61, s * .18, s * .40, s * .31, s * .28)
          ..cubicTo(s * .42, s * .18, s * .54, s * .25, s * .50, s * .36)
          ..cubicTo(s * .46, s * .25, s * .58, s * .18, s * .69, s * .28)
          ..cubicTo(s * .82, s * .40, s * .80, s * .61, s * .50, s * .79);
        canvas.drawPath(path, filled ? fill : stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _OwlSonicGlyphPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.filled != filled;
}
