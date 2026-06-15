import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/presentation/widgets/add_track_sheet.dart';
import 'package:openmusic/layers/presentation/blocs/clipboard/clipboard_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/add_track/add_track_bloc.dart';

class ClipboardDetector extends StatefulWidget {
  final Widget child;
  const ClipboardDetector({super.key, required this.child});

  @override
  State<ClipboardDetector> createState() => _ClipboardDetectorState();
}

class _ClipboardDetectorState extends State<ClipboardDetector>
    with WidgetsBindingObserver {
  String? _lastCheckedClip;
  OverlayEntry? _bannerEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerEntry?.remove();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  Future<bool> _checkClipboard() async {
    if (!mounted) return false;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) return false;
      if (text == _lastCheckedClip) return false;
      _lastCheckedClip = text;
      if (mounted) _showBanner(text);
      return true;
    } catch (e) {
      log(
        'Error occurred while checking clipboard',
        error: e,
        name: 'ClipboardDetector',
      );
      return false;
    }
  }

  void _showBanner(String url) {
    _bannerEntry?.remove();
    _bannerEntry = null;
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;
    _bannerEntry = OverlayEntry(
      builder: (_) => _ClipboardBanner(
        url: url,
        onAdd: () {
          _dismissBanner();
          _openAddSheet(url);
        },
        onDismiss: _dismissBanner,
      ),
    );
    Overlay.of(context).insert(_bannerEntry!);
  }

  void _dismissBanner() {
    context.read<AddTrackBloc>().add(const ResetAddTrack());
    _bannerEntry?.remove();
    _bannerEntry = null;
  }

  void _openAddSheet(String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        context.read<AddTrackBloc>().add(FetchTrackPreview(url));
        return AddTrackSheet(url: url);
      },
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ClipboardBloc, ClipboardState>(
        listener: (context, state) {
          if (state is ClipboardStateRequest) {
            _checkClipboard();
          }
        },
        child: widget.child,
      );
}

class _ClipboardBanner extends StatefulWidget {
  final String url;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  const _ClipboardBanner({
    required this.url,
    required this.onAdd,
    required this.onDismiss,
  });

  @override
  State<_ClipboardBanner> createState() => _ClipboardBannerState();
}

class _ClipboardBannerState extends State<_ClipboardBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss(VoidCallback cb) async {
    await _ctrl.reverse();
    if (mounted) cb();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 12,
      right: 12,
      bottom: bottomPad + 80,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slide.value),
          child: Opacity(opacity: _fade.value, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x60000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 0, 0),
                        Color.fromARGB(255, 130, 130, 130),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.link, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('track.linkInClipboard'),
                        style: GoogleFonts.figtree(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.url,
                        style: GoogleFonts.figtree(
                          fontSize: 11,
                          color: AppColors.text.withValues(alpha: 0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _dismiss(widget.onAdd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.tr('track.add'),
                      style: GoogleFonts.figtree(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bg,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _dismiss(widget.onDismiss),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.muted,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
