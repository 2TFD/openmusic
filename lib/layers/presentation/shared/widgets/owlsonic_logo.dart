import 'package:flutter/material.dart';

class OwlSonicLogo extends StatelessWidget {
  const OwlSonicLogo({super.key, this.width = 112, this.opacity = 1});

  // Cropped, lossless derivative of the canonical source asset. Keeping the
  // source untouched avoids carrying its large transparent margins into UI.
  static const assetPath = 'assets/icon/owlsonic_wordmark.png';

  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'OwlSonic',
    image: true,
    child: Opacity(
      opacity: opacity,
      child: Image.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true,
      ),
    ),
  );
}
