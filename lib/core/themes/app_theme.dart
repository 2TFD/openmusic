import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Фоны
  static const Color bg = Color(0xFF080808); // основной фон

  static const Color surface = Color(0xFF111111); // карточки 1 уровня
  static const Color surface2 = Color(
    0xFF181818,
  ); // карточки 2 уровня (активные)
  static const Color surface3 = Color(0xFF222222); // ховер / выбранный элемент

  // Границы
  static const Color border = Color(0xFF1E1E1E); // обычная граница
  static const Color borderAct = Color(
    0xFF2E2E2E,
  ); // активная граница (seed chip)
  //error
  static const Color error = Color.fromARGB(255, 178, 11, 11);
  // Текст
  static const Color text = Color(0xFFF0F0F0); // основной текст
  static const Color textSub = Color(0xFF888888); // вторичный текст
  static const Color muted = Color(0xFF555555); // метки, плейсхолдеры
  static const Color muted2 = Color(0xFF333333); // совсем приглушённое

  // Акцент
  static const Color accent = Color(0xFFFFFFFF); // белый — единственный акцент

  // Glow (для BoxShadow и RadialGradient)
  static const Color glowWhite = Color(
    0x33FFFFFF,
  ); // белое свечение play-кнопки
  static const Color glowPurp = Color(
    0x4D503780,
  ); // фиолетовое свечение обложки
  static const Color glowGreen = Color(
    0x331E4A30,
  ); // зелёное — ambient/nature seed
}

class AppText {
  AppText._();

  // ── Display (Outfit) ──────────────────────────────────────
  /// 32px / w800 — главный заголовок экрана (Wave, Library…)
  static TextStyle get display1 => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.05,
    color: AppColors.text,
  );

  /// 24px / w700 — заголовки секций, названия треков в Now Playing
  static TextStyle get display2 => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.text,
  );

  /// 18px / w700 — название трека в плеере
  static TextStyle get display3 => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.text,
  );

  // ── Body (Figtree) ────────────────────────────────────────
  /// 14px / w500 — основной текст списков
  static TextStyle get bodyL => GoogleFonts.figtree(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  /// 13px / w400 — имя артиста, вторичные строки
  static TextStyle get bodyM => GoogleFonts.figtree(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
  );

  /// 12px / w400 — chip-лейблы (seeds)
  static TextStyle get bodyS => GoogleFonts.figtree(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  /// 11px / w400 — длительность, метаданные
  static TextStyle get bodyXS => GoogleFonts.figtree(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// 10px / w600 uppercase — лейблы секций ("NOW PLAYING", "SEEDS")
  static TextStyle get label => GoogleFonts.figtree(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.6,
    color: AppColors.muted,
  );

  /// 9px / w700 uppercase — nav labels, микро-метки
  static TextStyle get labelXS => GoogleFonts.figtree(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.text,
  );
}

// ──────────────────────────────────────────────────────────────
// 3. ОТСТУПЫ И РАДИУСЫ
// ──────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// Горизонтальный padding экранов
  static const double screenH = 24.0;

  /// Вертикальный padding между секциями
  static const EdgeInsets section = EdgeInsets.only(top: 20);

  /// Padding внутри карточек
  static const EdgeInsets card = EdgeInsets.all(20);
}

class AppRadius {
  AppRadius._();

  static const double xs = 6.0; // mini cover
  static const double s = 10.0; // обложка трека
  static const double m = 14.0; // seed chip (100px для pill)
  static const double l = 20.0; // карточки Now Playing, секции
  static const double xl = 28.0; // bottom sheet
  static const double pill = 100.0; // полностью округлый (chips, кнопки)

  static BorderRadius get cardBR => BorderRadius.circular(l);
  static BorderRadius get chipBR => BorderRadius.circular(pill);
  static BorderRadius get coverBR => BorderRadius.circular(s);
}

// ──────────────────────────────────────────────────────────────
// 4. ТЕНИ И GLOW
// ──────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  /// Тень обложки трека
  static const List<BoxShadow> cover = [
    BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Glow белой play-кнопки (пульсирует)
  static List<BoxShadow> playButtonGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: Color.fromRGBO(255, 255, 255, 0.20 * intensity),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Glow карточки Now Playing (через RadialGradient, не BoxShadow)
  // Используется как декоратор внутри Stack:
  // decoration: const BoxDecoration(gradient: AppShadows.nowPlayingGlow)
  static const RadialGradient nowPlayingGlow = RadialGradient(
    center: Alignment(-0.5, -0.2),
    radius: 1.2,
    colors: [AppColors.glowPurp, Colors.transparent],
  );
}

// ──────────────────────────────────────────────────────────────
// 5. АНИМАЦИИ
// ──────────────────────────────────────────────────────────────
//
// Стиль: snappy — быстрые входы, мгновенный отклик
// ──────────────────────────────────────────────────────────────

class AppAnim {
  AppAnim._();

  // Длительности
  static const Duration micro = Duration(milliseconds: 100); // tap feedback
  static const Duration fast = Duration(milliseconds: 180); // toggle, chip
  static const Duration normal = Duration(
    milliseconds: 280,
  ); // переходы экранов
  static const Duration slow = Duration(milliseconds: 500); // page load stagger

  // Кривые
  static const Curve enter = Curves.easeOut; // элементы появляются
  static const Curve exit = Curves.easeIn; // исчезают
  static const Curve spring = Curves.easeOutBack; // упругий вход
  static const Curve toggle = Curves.easeInOut; // chip toggle

  // Stagger delay для списков (умножь на индекс)
  static Duration stagger(int index) => Duration(milliseconds: 60 + index * 40);
}

// ──────────────────────────────────────────────────────────────
// 6. BLUR / FROSTED GLASS
// ──────────────────────────────────────────────────────────────
//
// Использование:
//   import 'dart:ui';
//   BackdropFilter(
//     filter: AppBlur.standard,
//     child: Container(color: AppBlur.overlayColor),
//   )
// ──────────────────────────────────────────────────────────────

class AppBlur {
  AppBlur._();

  // Значения sigma
  static const double light = 8.0; // subtle overlay
  static const double medium = 16.0; // mini player над контентом
  static const double heavy = 28.0; // full-screen overlay / sheet

  // Цвет подложки под blur
  static const Color overlayColor = Color(0xCC080808); // 80% opacity bg
  static const Color sheetColor = Color(0xE6111111); // 90% opacity surface
}

// ──────────────────────────────────────────────────────────────
// 7. THEMEDATA — подключение к MaterialApp
// ──────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.textSub,
        onSurface: AppColors.text,
        outline: AppColors.border,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      dividerColor: AppColors.border,
      splashColor: Colors.transparent,
      highlightColor: const Color.fromARGB(0, 110, 59, 59),

      // Текст через Figtree по умолчанию
      textTheme: GoogleFonts.figtreeTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),

      // Bottom nav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bg,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(AppText.labelXS),
      ),

      // Page transitions — slide up (snappy)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
