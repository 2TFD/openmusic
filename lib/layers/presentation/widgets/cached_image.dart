import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({super.key, this.url, this.filePath, required this.size});
  final String? url;
  final String? filePath;
  final double size;
  @override
  Widget build(BuildContext context) {
    if (filePath != null) {
      return Image.file(
        File(filePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
      );
    }

    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.image),
      );
    }

    return const Center(child: Icon(Icons.image));
  }
}
