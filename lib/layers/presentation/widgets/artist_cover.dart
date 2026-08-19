import 'package:flutter/material.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/presentation/widgets/playlist_cover.dart';

class ArtistCover extends StatelessWidget {
  const ArtistCover({
    super.key,
    required this.artistName,
    this.imageUrls = const [],
    this.size = 120,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border,
  });

  final String artistName;
  final List<String> imageUrls;
  final double size;
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final normalizedName = artistName.trim();
    final initial = normalizedName.isEmpty
        ? '?'
        : normalizedName[0].toUpperCase();
    return PlaylistCover(
      generatedImageUrls: imageUrls,
      size: size,
      width: width,
      height: height,
      borderRadius: borderRadius,
      border: border,
      placeholder: Text(
        initial,
        style: AppText.display1.copyWith(
          color: AppColors.muted,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}
