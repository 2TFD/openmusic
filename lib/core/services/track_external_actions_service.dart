import 'dart:io';
import 'dart:ui';

import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/domain/entities/track.dart';
import 'package:openmusic/layers/domain/repositories/track_external_actions.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);
typedef LocalFileSharer =
    Future<void> Function(
      String filePath,
      String title,
      Rect? sharePositionOrigin,
    );

class TrackExternalActionsService implements TrackExternalActions {
  TrackExternalActionsService({
    required this.appDirectory,
    ExternalUrlLauncher? launchExternalUrl,
    LocalFileSharer? shareLocalFile,
  }) : _launchExternalUrl = launchExternalUrl ?? _defaultLaunchExternalUrl,
       _shareFile = shareLocalFile ?? _defaultShareLocalFile;

  final String appDirectory;
  final ExternalUrlLauncher _launchExternalUrl;
  final LocalFileSharer _shareFile;

  @override
  Future<void> openSource(Track track, {Rect? sharePositionOrigin}) async {
    switch (track.source.type) {
      case SourceType.soundcloud:
        await _openSoundCloud(track.source.originalUrl);
      case SourceType.youtube:
      case SourceType.spotify:
        await _openWebSource(track.source.originalUrl);
      case SourceType.localFile:
        await _shareTrackFile(track, sharePositionOrigin);
      case SourceType.unknown:
        throw UnsupportedSourceFailure(track.source.originalUrl);
    }
  }

  @override
  Future<void> openMediaSource(Track track) async {
    final media = track.source.media;
    if (media == null) throw UnsupportedSourceFailure(track.source.originalUrl);
    await _openWebSource(media.url);
  }

  Future<void> _openWebSource(String originalUrl) async {
    final uri = Uri.tryParse(originalUrl);
    if (uri == null || !{'http', 'https'}.contains(uri.scheme)) {
      throw UnsupportedSourceFailure(originalUrl);
    }
    if (!await _launchExternalUrl(uri)) {
      throw RemoteServiceFailure('open ${uri.host}');
    }
  }

  Future<void> _openSoundCloud(String originalUrl) async {
    final uri = Uri.tryParse(originalUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !{'http', 'https'}.contains(uri.scheme)) {
      throw UnsupportedSourceFailure(originalUrl);
    }

    final opened = await _launchExternalUrl(uri);
    if (!opened) throw const RemoteServiceFailure('open SoundCloud track');
  }

  Future<void> _shareTrackFile(Track track, Rect? sharePositionOrigin) async {
    final storedPath = track.filePath;
    if (storedPath == null || storedPath.trim().isEmpty) {
      throw const TrackNotReadyFailure();
    }

    final absolutePath = path.isAbsolute(storedPath)
        ? path.normalize(storedPath)
        : path.join(appDirectory, storedPath);
    if (!await File(absolutePath).exists()) throw const FileNotFoundFailure();

    await _shareFile(absolutePath, track.title, sharePositionOrigin);
  }

  static Future<bool> _defaultLaunchExternalUrl(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  static Future<void> _defaultShareLocalFile(
    String filePath,
    String title,
    Rect? sharePositionOrigin,
  ) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        title: title,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
