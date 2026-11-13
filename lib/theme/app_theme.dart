import 'package:flutter/material.dart';

/// Core color palette for the Senninha cyberpunk/racing theme.
class SennaColors {
  SennaColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF121830);
  static const Color surfaceLight = Color(0xFF1A2240);

  // ── Primary accent colours ───────────────────────────────────────────
  static const Color cyan = Color(0xFF00E5FF);
  static const Color magenta = Color(0xFFFF006E);
  static const Color orange = Color(0xFFFF6B00);
  static const Color yellow = Color(0xFFFFD600);
  static const Color neonGreen = Color(0xFF00FF85);
  static const Color red = Color(0xFFFF1744);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8A8FA8);
  static const Color textDim = Color(0xFF4A5068);

  // ── Glow helpers ─────────────────────────────────────────────────────
  static Color cyanGlow([double opacity = 0.35]) =>
      cyan.withValues(alpha: opacity);
  static Color magentaGlow([double opacity = 0.35]) =>
      magenta.withValues(alpha: opacity);
  static Color orangeGlow([double opacity = 0.35]) =>
      orange.withValues(alpha: opacity);
  static Color greenGlow([double opacity = 0.35]) =>
      neonGreen.withValues(alpha: opacity);
  static Color redGlow([double opacity = 0.35]) =>
      red.withValues(alpha: opacity);
}

/// Pre-built text styles used across the app.
class SennaTextStyles {
  SennaTextStyles._();

  static const String _mono = 'RobotoMono';

  // ── Headings ─────────────────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: SennaColors.textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: SennaColors.textPrimary,
    letterSpacing: 1.0,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: SennaColors.textPrimary,
    letterSpacing: 0.8,
  );

  // ── Body ─────────────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: SennaColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: SennaColors.textSecondary,
  );

  // ── Labels ───────────────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: SennaColors.textSecondary,
    letterSpacing: 1.4,
  );

  static const TextStyle labelCyan = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: SennaColors.cyan,
    letterSpacing: 1.4,
  );

  // ── Data / value readouts (monospace) ────────────────────────────────
  static const TextStyle dataLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: _mono,
    color: SennaColors.textPrimary,
    letterSpacing: 1.0,
  );

  static const TextStyle dataMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: _mono,
    color: SennaColors.textPrimary,
  );

  static const TextStyle dataSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: _mono,
    color: SennaColors.textPrimary,
  );

  // ── Badges / chips ──────────────────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  // ── Button text ─────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );
}

/// Global ThemeData for the app.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SennaColors.background,
      colorScheme: const ColorScheme.dark(
        primary: SennaColors.cyan,
        secondary: SennaColors.magenta,
        surface: SennaColors.surface,
        error: SennaColors.red,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: SennaColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: SennaTextStyles.heading2,
        iconTheme: IconThemeData(color: SennaColors.cyan),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SennaColors.background,
        selectedItemColor: SennaColors.cyan,
        unselectedItemColor: SennaColors.textDim,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: SennaTextStyles.badge,
        unselectedLabelStyle: SennaTextStyles.badge,
      ),
      cardTheme: CardThemeData(
        color: SennaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: SennaColors.cyan.withValues(alpha: 0.25)),
        ),
      ),
      iconTheme: const IconThemeData(color: SennaColors.cyan, size: 20),
      dividerColor: SennaColors.cyan.withValues(alpha: 0.15),
    );
  }

  // ── Decoration helpers ──────────────────────────────────────────────

  /// Standard card decoration with a subtle neon border glow.
  static BoxDecoration neonCard({
    Color borderColor = SennaColors.cyan,
    double borderWidth = 1.0,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: SennaColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withValues(alpha: 0.4),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: 0.10),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Intense neon glow used around focused / active elements.
  static List<BoxShadow> neonGlow(Color color, {double spread = 2}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.45),
        blurRadius: 12,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: 24,
        spreadRadius: spread + 2,
      ),
    ];
  }

  /// Horizontal gradient (left→right) for buttons / banners.
  static LinearGradient horizontalGradient(List<Color> colors) {
    return LinearGradient(colors: colors);
  }

  /// Vertical gradient used for subtle background washes.
  static LinearGradient verticalGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
