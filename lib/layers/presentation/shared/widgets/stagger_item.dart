import 'package:flutter/material.dart';
import 'package:owlsonic/core/themes/app_theme.dart';

/// Wraps a list item with a staggered fade + rise entrance animation.
///
/// Usage inside a list builder:
/// ```dart
/// itemBuilder: (context, index) => StaggerItem(
///   index: index,
///   child: TrackItem(track: tracks[index]),
/// ),
/// ```
///
/// Visible items above [maxStaggered] skip the delay so fast scrolling
/// never feels sluggish.
class StaggerItem extends StatefulWidget {
  const StaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.maxStaggered = 12,
  });

  final int index;
  final Widget child;

  /// Items beyond this index appear instantly (avoids delay during fast scroll).
  final int maxStaggered;

  @override
  State<StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppAnim.normal);

    _opacity = CurvedAnimation(parent: _controller, curve: AppAnim.enter);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AppAnim.enter));

    final delay = widget.index < widget.maxStaggered
        ? Duration(milliseconds: widget.index * 35)
        : Duration.zero;

    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
