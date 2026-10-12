import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';

/// Keeps presentation family tied to the operating system, even in a narrow window.
abstract final class AdaptivePresentation {
  /// Closes the surface [context] lives in, handing [result] to the caller of
  /// [showSurface]. `GoRouter.pop` is not usable for this: a desktop dialog or
  /// a bottom sheet sits on the root navigator, while go_router pops the shell
  /// navigator and throws "There is nothing to pop". When the screen was
  /// opened with `go` (no history), it falls back to Home.
  static void close<T>(BuildContext context, [T? result]) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(result);
      return;
    }
    context.goNamed(AppRouterNames.home);
  }

  static Future<T?> showSurface<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    double maxWidth = 520,
    double maxHeight = 700,
    bool scrollControlledMobile = true,
  }) {
    if (!AppLayout.isDesktopPlatform) {
      return showModalBottomSheet<T>(
        context: context,
        useRootNavigator: true,
        backgroundColor: AppColors.sheetSurface,
        showDragHandle: false,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        isScrollControlled: scrollControlledMobile,
        builder: builder,
      );
    }
    final size = MediaQuery.sizeOf(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, _, _) => Center(
        child: Dialog(
          backgroundColor: AppColors.sheetSurface,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth.clamp(0, size.width - 48),
              maxHeight: maxHeight.clamp(0, size.height - 48),
            ),
            child: builder(dialogContext),
          ),
        ),
      ),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .98, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
