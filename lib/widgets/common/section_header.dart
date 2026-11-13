import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A section header with an icon, title, optional trailing widget,
/// and a neon bottom border line.
///
/// Used for sections like "BUZINA DE CORRIDA", "TELEMETRIA EM TEMPO REAL", etc.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor = SennaColors.cyan,
    this.trailing,
    this.borderColor = SennaColors.cyan,
    this.padding = const EdgeInsets.only(bottom: 10),
  });

  final String title;
  final IconData? icon;
  final Color iconColor;
  final Widget? trailing;
  final Color borderColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: SennaTextStyles.label.copyWith(
                color: SennaColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
