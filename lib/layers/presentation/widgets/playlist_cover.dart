import 'package:flutter/material.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';

class PlaylistCover extends StatelessWidget {
  const PlaylistCover({
    super.key,
    this.imageUrl,
    this.generatedImageUrls = const [],
    this.size = 120,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border,
    this.placeholderIconSize = 24,
    this.placeholder,
  });

  final String? imageUrl;
  final List<String> generatedImageUrls;
  final double size;
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final double placeholderIconSize;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final manualImageUrl = _normalizeUrl(imageUrl);
    final generatedUrls = _normalizeGeneratedUrls(generatedImageUrls);

    return SizedBox(
      width: width ?? size,
      height: height ?? size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: borderRadius,
          border: border,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final coverWidth = _resolveExtent(
                requested: width,
                constrained: constraints.maxWidth,
              );
              final coverHeight = _resolveExtent(
                requested: height,
                constrained: constraints.maxHeight,
              );

              if (manualImageUrl != null) {
                return _CoverImage(
                  url: manualImageUrl,
                  width: coverWidth,
                  height: coverHeight,
                );
              }

              if (generatedUrls.isEmpty) {
                return Center(
                  child:
                      placeholder ??
                      Icon(
                        Icons.music_note,
                        color: AppColors.muted2,
                        size: placeholderIconSize,
                      ),
                );
              }

              return _Collage(
                urls: generatedUrls,
                width: coverWidth,
                height: coverHeight,
              );
            },
          ),
        ),
      ),
    );
  }

  String? _normalizeUrl(String? url) {
    final value = url?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  List<String> _normalizeGeneratedUrls(List<String> urls) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final url in urls) {
      final value = _normalizeUrl(url);
      if (value == null || !seen.add(value)) continue;
      normalized.add(value);
      if (normalized.length == 4) break;
    }
    return normalized;
  }

  double _resolveExtent({double? requested, required double constrained}) {
    if (constrained.isFinite && constrained > 0) return constrained;
    if (requested != null && requested.isFinite && requested > 0) {
      return requested;
    }
    return size;
  }
}

class _Collage extends StatelessWidget {
  const _Collage({
    required this.urls,
    required this.width,
    required this.height,
  });

  final List<String> urls;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return _CoverImage(url: urls[0], width: width, height: height);
    }

    if (urls.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _CoverImage(url: urls[0], width: width / 2, height: height),
          ),
          Expanded(
            child: _CoverImage(url: urls[1], width: width / 2, height: height),
          ),
        ],
      );
    }

    if (urls.length == 3) {
      return Row(
        children: [
          Expanded(
            child: _CoverImage(url: urls[0], width: width / 2, height: height),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _CoverImage(
                    url: urls[1],
                    width: width / 2,
                    height: height / 2,
                  ),
                ),
                Expanded(
                  child: _CoverImage(
                    url: urls[2],
                    width: width / 2,
                    height: height / 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CoverImage(
                  url: urls[0],
                  width: width / 2,
                  height: height / 2,
                ),
              ),
              Expanded(
                child: _CoverImage(
                  url: urls[1],
                  width: width / 2,
                  height: height / 2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CoverImage(
                  url: urls[2],
                  width: width / 2,
                  height: height / 2,
                ),
              ),
              Expanded(
                child: _CoverImage(
                  url: urls[3],
                  width: width / 2,
                  height: height / 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final imageSize = width > height ? width : height;
    return CachedImage(url: url, size: imageSize, width: width, height: height);
  }
}
