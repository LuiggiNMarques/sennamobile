import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Semantic variant for [StatusBadge].
enum StatusVariant {
  connected,
  disconnected,
  active,
  warning,
}

/// A small, reusable neon status badge.
///
/// Typically shows an icon and a short label inside a rounded rectangle
/// with a coloured neon border glow.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = StatusVariant.active,
    this.customColor,
  });

  final String label;
  final IconData? icon;
  final StatusVariant variant;

  /// Overrides the variant colour when provided.
  final Color? customColor;

  Color get _color {
    if (customColor != null) return customColor!;
    switch (variant) {
      case StatusVariant.connected:
        return SennaColors.neonGreen;
      case StatusVariant.disconnected:
        return SennaColors.red;
      case StatusVariant.active:
        return SennaColors.cyan;
      case StatusVariant.warning:
        return SennaColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.50), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: SennaTextStyles.badge.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
