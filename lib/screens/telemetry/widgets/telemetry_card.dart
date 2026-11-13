import 'package:flutter/material.dart';

/// Reusable telemetry data card for displaying sensor readings.
/// Supports large value + unit, optional progress bar, and status dot.
class TelemetryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String? subtitle;
  final double? progress;
  final Color? statusColor;
  final IconData? icon;
  final Color accentColor;
  final Widget? trailing;

  const TelemetryCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.subtitle,
    this.progress,
    this.statusColor,
    this.icon,
    this.accentColor = const Color(0xFF00E5FF),
    this.trailing,
  });

  static const _cardBg = Color(0xFF121830);
  static const _darkBg = Color(0xFF0A0E1A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with optional status dot
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: accentColor, size: 14),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (statusColor != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor!.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Large value + unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Optional subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Optional progress bar
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: _darkBg,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ],

          // Optional trailing widget
          if (trailing != null) ...[
            const SizedBox(height: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
