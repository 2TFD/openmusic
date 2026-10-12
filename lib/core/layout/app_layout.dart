import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum DesktopWindowSize { compact, standard, large }

enum AppWindowSize { compact, medium, desktop, largeDesktop }

abstract final class AppBreakpoints {
  static const double medium = 720;
  static const double desktop = 1100;
  static const double largeDesktop = 1440;
}

abstract final class AppLayout {
  static bool get isDesktopPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => true,
    _ => false,
  };

  static DesktopWindowSize desktopSizeFor(double width) => switch (width) {
    < 900 => DesktopWindowSize.compact,
    < 1400 => DesktopWindowSize.standard,
    _ => DesktopWindowSize.large,
  };

  static bool isCompactDesktop(double width) =>
      desktopSizeFor(width) == DesktopWindowSize.compact;

  static double desktopPaddingFor(double width) =>
      switch (desktopSizeFor(width)) {
        DesktopWindowSize.compact => 20,
        DesktopWindowSize.standard => 28,
        DesktopWindowSize.large => 36,
      };

  static const double readableContentWidth = 820;
  static const double wideContentWidth = 1480;
  static const double compactRailWidth = 72;

  /// Prevents page content from becoming excessively wide on desktop windows.
  static const double maxContentWidth = 1200;

  /// Keeps the floating player readable instead of stretching edge to edge.
  static const double maxMiniPlayerWidth = 720;

  static const double sidebarWidth = 232;
  static const double queuePanelWidth = 320;
  static const double contextPanelWidth = 340;
  static const double desktopPlayerHeight = 80;

  /// Below this window width the context panel is a dialog, not a docked pane.
  static const double contextPanelDockWidth = 1280;

  /// From this width the panel opens on its own while something is playing.
  static const double contextPanelAutoWidth = 1440;

  /// Max width of desktop page content (the "content rail").
  static const double desktopRailWidth = 1240;

  static bool isDesktop(double width) => width >= AppBreakpoints.desktop;

  static AppWindowSize windowSizeFor(double width) {
    if (width >= AppBreakpoints.largeDesktop) {
      return AppWindowSize.largeDesktop;
    }
    if (width >= AppBreakpoints.desktop) return AppWindowSize.desktop;
    if (width >= AppBreakpoints.medium) return AppWindowSize.medium;
    return AppWindowSize.compact;
  }

  static double horizontalPaddingFor(double width) {
    return switch (windowSizeFor(width)) {
      AppWindowSize.compact => width < 360 ? 16 : 24,
      AppWindowSize.medium => 32,
      AppWindowSize.desktop || AppWindowSize.largeDesktop => 40,
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
