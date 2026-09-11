import 'package:flutter/widgets.dart';

enum AppWindowSize { compact, medium, expanded }

abstract final class AppBreakpoints {
  /// Material's compact-to-medium boundary in logical pixels.
  static const double medium = 600;

  /// Width where the app can use an expanded, multi-column presentation.
  static const double expanded = 840;
}

abstract final class AppLayout {
  /// Prevents page content from becoming excessively wide on desktop windows.
  static const double maxContentWidth = 1200;

  /// Keeps the floating player readable instead of stretching edge to edge.
  static const double maxMiniPlayerWidth = 720;

  static AppWindowSize windowSizeFor(double width) {
    if (width >= AppBreakpoints.expanded) return AppWindowSize.expanded;
    if (width >= AppBreakpoints.medium) return AppWindowSize.medium;
    return AppWindowSize.compact;
  }

  static double horizontalPaddingFor(double width) {
    return switch (windowSizeFor(width)) {
      AppWindowSize.compact => width < 360 ? 16 : 24,
      AppWindowSize.medium => 32,
      AppWindowSize.expanded => 40,
    };
  }

  static int gridColumnCount({
    required double availableWidth,
    required double minItemWidth,
    double spacing = 12,
    int minColumns = 1,
    int maxColumns = 6,
  }) {
    final count = ((availableWidth + spacing) / (minItemWidth + spacing))
        .floor();
    return count.clamp(minColumns, maxColumns);
  }
}

class AppContentFrame extends StatelessWidget {
  const AppContentFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth.clamp(0, AppLayout.maxContentWidth),
            height: constraints.maxHeight,
            child: child,
          ),
        );
      },
    );
  }
}
