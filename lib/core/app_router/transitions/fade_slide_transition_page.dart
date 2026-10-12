import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';

/// Fade + micro Y-slide page transition.
///
/// Entering screen fades in from opacity 0 → 1 while rising 12px upward
/// (from a slightly lower position). Duration and curves reuse the global
/// [AppAnim] tokens so the whole app stays consistent.
class FadeSlideTransitionPage<T> extends CustomTransitionPage<T> {
  FadeSlideTransitionPage({required super.child, super.key})
    : super(
        transitionDuration: AppAnim.normal,
        reverseTransitionDuration: AppAnim.fast,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (AppLayout.isDesktopPlatform) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: .99, end: 1).animate(animation),
                child: child,
              ),
            );
          }
          // Slightly dim the outgoing screen so focus stays on the new one.
          final fadeOut = CurvedAnimation(
            parent: secondaryAnimation,
            curve: AppAnim.exit,
          );
          // Fade the new screen in.
          final fadeIn = CurvedAnimation(
            parent: animation,
            curve: AppAnim.enter,
          );
          // Micro Y offset: slide up 12 logical pixels as the screen enters.
          final slideIn = Tween<Offset>(
            begin: const Offset(0, 0.04), // ~12px at typical screen height
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: AppAnim.enter));

          return FadeTransition(
            opacity: Tween<double>(begin: 0.85, end: 1).animate(fadeOut),
            child: FadeTransition(
              opacity: fadeIn,
              child: SlideTransition(position: slideIn, child: child),
            ),
          );
        },
      );
}
