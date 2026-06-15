import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/core/utils/locale_keys.dart';

class CustomSnackBar {
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_rounded,
      iconColor: const Color(0xFF4ADE80),
      iconBg: const Color(0x1A4ADE80),
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.close_rounded,
      iconColor: const Color(0xFFFF6B6B),
      iconBg: const Color(0x1AFF6B6B),
    );
  }

  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF888888),
      iconBg: const Color(0x1A888888),
    );
  }

  static void loading(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: null,
      iconColor: AppColors.text,
      iconBg: const Color(0x1AFFFFFF),
      isLoading: true,
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFFBBF24),
      iconBg: const Color(0x1AFBBF24),
    );
  }

  static void trackAdded(BuildContext context, String trackTitle) {
    _show(
      context,
      message: LocaleKeys.snackTrackAdded.tr(),
      subtitle: trackTitle,
      icon: Icons.music_note_rounded,
      iconColor: AppColors.text,
      iconBg: const Color(0x1AFFFFFF),
    );
  }

  static void downloading(BuildContext context, String trackTitle) {
    _show(
      context,
      message: LocaleKeys.snackDownloading.tr(),
      subtitle: trackTitle,
      icon: null,
      iconColor: AppColors.text,
      iconBg: const Color(0x1AFFFFFF),
      isLoading: true,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    String? subtitle,
    required IconData? icon,
    required Color iconColor,
    required Color iconBg,
    bool isLoading = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          content: _SnackBarContent(
            message: message,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            iconBg: iconBg,
            isLoading: isLoading,
          ),
        ),
      );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final Color iconColor;
  final Color iconBg;
  final bool isLoading;

  const _SnackBarContent({
    required this.message,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor,
                      ),
                    )
                  : Icon(icon, color: iconColor, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: GoogleFonts.figtree(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
