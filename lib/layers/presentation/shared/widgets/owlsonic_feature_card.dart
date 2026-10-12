import 'package:flutter/material.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/app_surface.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/owlsonic_glyph.dart';

/// Shared entry-card treatment for OwlSonic's flagship music features.
class OwlSonicFeatureCard extends StatelessWidget {
  const OwlSonicFeatureCard({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.glyph,
    required this.onTap,
    this.action,
    this.moodField = false,
    this.titleKey,
    this.descriptionKey,
  });

  final String label;
  final String title;
  final String description;
  final OwlSonicGlyphType glyph;
  final VoidCallback onTap;
  final Widget? action;
  final bool moodField;
  final Key? titleKey;
  final Key? descriptionKey;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      radius: AppRadius.card,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 110),
        child: Stack(
          children: [
            if (moodField)
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(.82, -.15),
                        radius: 1.15,
                        colors: [Color(0x221C654A), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 76, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: AppText.label),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    key: titleKey,
                    style: AppText.display3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    key: descriptionKey,
                    style: AppText.bodyM,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: OwlSonicGlyph(
                  type: glyph,
                  size: 40,
                  color: moodField
                      ? const Color(0xFF617A69)
                      : const Color(0xFF707070),
                ),
              ),
            ),
            if (action != null)
              Positioned(right: 10, bottom: 6, child: action!),
          ],
        ),
      ),
    );
  }
}
