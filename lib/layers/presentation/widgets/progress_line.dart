import 'package:flutter/material.dart';

class ProgressLine extends StatefulWidget {
  final double progress;
  final ValueChanged<double>? onSeek;

  const ProgressLine({super.key, required this.progress, this.onSeek});

  @override
  State<ProgressLine> createState() => _ProgressLineState();
}

class _ProgressLineState extends State<ProgressLine> {
  double? _draggingProgress;

  double get _displayProgress => _draggingProgress ?? widget.progress;

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    final progress = (details.localPosition.dx / maxWidth).clamp(0.0, 1.0);
    setState(() => _draggingProgress = progress);
  }

  void _onDragEnd(DragEndDetails _) {
    if (_draggingProgress != null) {
      widget.onSeek?.call(_draggingProgress!);
      setState(() => _draggingProgress = null);
    }
  }

  void _onTapUp(TapUpDetails details, double maxWidth) {
    final progress = (details.localPosition.dx / maxWidth).clamp(0.0, 1.0);
    widget.onSeek?.call(progress);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _onTapUp(d, maxWidth),
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxWidth),
          onHorizontalDragEnd: _onDragEnd,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Stack(
              children: [
                Container(
                  height: 2,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                AnimatedContainer(
                  duration: _draggingProgress != null
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.linear,
                  height: 2,
                  width: maxWidth * _displayProgress,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: _draggingProgress != null ? 0.7 : 0.35,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
                if (_draggingProgress != null)
                  Positioned(
                    left: maxWidth * _displayProgress - 6,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
