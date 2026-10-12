import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:owlsonic/core/di/di.dart';
import 'package:owlsonic/core/services/cloud/signed_url_cache.dart';
import 'package:owlsonic/layers/data/repositories/cloud_local_store.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    this.url,
    this.filePath,
    required this.size,
    this.width,
    this.height,
    this.fallback,
  });
  final String? url;
  final String? filePath;
  final double size;
  final double? width;
  final double? height;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = width ?? size;
    final resolvedHeight = height ?? size;

    final cloudTrackId = cloudArtworkTrackId(url);
    if (cloudTrackId != null) {
      return _CloudArtwork(
        trackId: cloudTrackId,
        width: resolvedWidth,
        height: resolvedHeight,
        fallback: fallback ?? const Icon(Icons.image),
      );
    }

    // Local imports store the extracted artwork as a plain file path in
    // `url`; CachedNetworkImage cannot load those.
    final localPath =
        filePath ??
        (url != null && !url!.startsWith(RegExp(r'https?://')) ? url : null);

    if (localPath != null) {
      return Image.file(
        File(localPath),
        width: resolvedWidth,
        height: resolvedHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? const Icon(Icons.image),
      );
    }

    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url!,
        width: resolvedWidth,
        height: resolvedHeight,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) =>
            fallback ?? const Icon(Icons.image),
      );
    }

    return SizedBox(
      width: resolvedWidth,
      height: resolvedHeight,
      child: Center(child: fallback ?? const Icon(Icons.image)),
    );
  }
}

/// Artwork of an OwlSonic cloud track: a short-lived signed URL from
/// `GET /v1/library/{id}/artwork`, never persisted. The image cache key is the
/// track id, so a fresh signed URL does not re-download cached bytes.
class _CloudArtwork extends StatefulWidget {
  const _CloudArtwork({
    required this.trackId,
    required this.width,
    required this.height,
    required this.fallback,
  });

  final String trackId;
  final double width;
  final double height;
  final Widget fallback;

  static SignedUrlCache? get _urls =>
      getIt.isRegistered<SignedUrlCache>(instanceName: 'cloudArtworkUrls')
      ? getIt<SignedUrlCache>(instanceName: 'cloudArtworkUrls')
      : null;

  @override
  State<_CloudArtwork> createState() => _CloudArtworkState();
}

class _CloudArtworkState extends State<_CloudArtwork> {
  Future<Uri?>? _url;
  bool _retried = false;

  @override
  void initState() {
    super.initState();
    _url = _resolve();
  }

  @override
  void didUpdateWidget(covariant _CloudArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId) {
      _retried = false;
      _url = _resolve();
    }
  }

  Future<Uri?> _resolve() async {
    final urls = _CloudArtwork._urls;
    if (urls == null) return null;
    try {
      return (await urls.get(widget.trackId)).url;
    } catch (_) {
      return null; // offline / no artwork: show the placeholder
    }
  }

  void _onImageError() {
    if (_retried) return;
    _retried = true;
    // Expired or rejected signed URL: re-acquire once.
    _CloudArtwork._urls?.invalidate(widget.trackId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _url = _resolve());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uri?>(
      future: _url,
      builder: (context, snapshot) {
        final uri = snapshot.data;
        if (uri == null) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(child: widget.fallback),
          );
        }
        return CachedNetworkImage(
          imageUrl: uri.toString(),
          cacheKey: cloudArtworkUri(widget.trackId),
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorWidget: (context, _, _) {
            _onImageError();
            return widget.fallback;
          },
        );
      },
    );
  }
}
