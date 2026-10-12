import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/utils/app_logger.dart';

/// Accepts music files dropped anywhere on the desktop window. It never
/// imports on its own: it hands the paths over so the review step can run.
class DesktopDropTarget extends StatefulWidget {
  const DesktopDropTarget({
    super.key,
    required this.child,
    required this.onPaths,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<List<String>> onPaths;
  final bool enabled;

  @override
  State<DesktopDropTarget> createState() => _DesktopDropTargetState();
}

class _DesktopDropTargetState extends State<DesktopDropTarget> {
  bool _dragging = false;
  final List<Uint8List> _scopedBookmarks = [];

  @override
  void dispose() {
    for (final bookmark in _scopedBookmarks) {
      DesktopDrop.instance
          .stopAccessingSecurityScopedResource(bookmark: bookmark)
          .catchError((_) => false);
    }
    super.dispose();
  }

  Future<void> _onDone(DropDoneDetails details) async {
    setState(() => _dragging = false);
    final paths = <String>[];
    for (final item in details.files) {
      final bookmark = item.extraAppleBookmark;
      if (defaultTargetPlatform == TargetPlatform.macOS &&
          bookmark != null &&
          bookmark.isNotEmpty) {
        // Sandboxed macOS only grants read access to dropped files through a
        // security-scoped bookmark.
        try {
          if (await DesktopDrop.instance.startAccessingSecurityScopedResource(
            bookmark: bookmark,
          )) {
            _scopedBookmarks.add(bookmark);
          }
        } catch (error, stackTrace) {
          await AppLogger.warning(
            'Could not open security-scoped drop access.',
            operation: 'import.drop',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      if (item.path.isNotEmpty) paths.add(item.path);
    }
    if (paths.isNotEmpty && mounted) widget.onPaths(paths);
  }

  @override
  Widget build(BuildContext context) => DropTarget(
    enable: widget.enabled,
    onDragEntered: (_) => setState(() => _dragging = true),
    onDragExited: (_) => setState(() => _dragging = false),
    onDragDone: _onDone,
    child: Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _dragging ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: ColoredBox(
                color: const Color(0xD9090909),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderAct),
                      color: AppColors.surface,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.library_add_outlined,
                          size: 28,
                          color: AppColors.textSub,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('import.dropOverlay'),
                          style: AppText.display3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
