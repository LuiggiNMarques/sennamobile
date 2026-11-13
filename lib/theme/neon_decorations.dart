import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Static helper methods for common neon-styled decorations.
class NeonDecorations {
  NeonDecorations._();

  // ── Neon border ─────────────────────────────────────────────────────
  /// Returns a [BoxDecoration] with a neon-glowing border.
  static BoxDecoration neonBorder({
    Color color = SennaColors.cyan,
    double width = 1.0,
    double radius = 12,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: color.withValues(alpha: 0.6),
        width: width,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.15),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // ── Neon card ───────────────────────────────────────────────────────
  /// Dark-surface card with a subtle neon border and outer glow.
  static BoxDecoration neonCard({
    Color borderColor = SennaColors.cyan,
    double borderWidth = 1.0,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: SennaColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withValues(alpha: 0.35),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: 0.08),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // ── Neon glow list ──────────────────────────────────────────────────
  /// Returns a list of [BoxShadow] to create a neon glow effect.
  static List<BoxShadow> neonGlow(Color color, {double spread = 2}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.40),
        blurRadius: 10,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.18),
        blurRadius: 22,
        spreadRadius: spread + 2,
      ),
    ];
  }

  // ── Gradient button ─────────────────────────────────────────────────
  /// Gradient [BoxDecoration] suitable for buttons.
  static BoxDecoration gradientButton(
    List<Color> colors, {
    double radius = 10,
    List<BoxShadow>? glow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: glow ??
          [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.30),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
    );
  }

  // ── Convenience presets ─────────────────────────────────────────────
  static BoxDecoration get cyanCard => neonCard(borderColor: SennaColors.cyan);
  static BoxDecoration get magentaCard =>
      neonCard(borderColor: SennaColors.magenta);
  static BoxDecoration get orangeCard =>
      neonCard(borderColor: SennaColors.orange);

  /// Subtle inner container used for sub-sections inside cards.
  static BoxDecoration innerContainer({
    Color borderColor = SennaColors.cyan,
    double radius = 8,
  }) {
    return BoxDecoration(
      color: SennaColors.background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withValues(alpha: 0.20),
        width: 1,
      ),
    );
  }
}
