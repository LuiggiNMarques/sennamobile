import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/neon_decorations.dart';

/// Top app bar for the Senninha app.
///
/// Shows robot identity, connection status badges, battery level,
/// signal strength, and an uptime timer.
class SennaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SennaAppBar({
    super.key,
    this.robotName = 'SENNINHA',
    this.robotNumber = '#01',
    this.chipType = 'ESP32-C3',
    this.connectionType = 'BLE',
    this.batteryPercent = 85,
    this.signalStrength = 3, // 0‑4
    this.uptimeMinutes = 10,
    this.isConnected = true,
  });

  final String robotName;
  final String robotNumber;
  final String chipType;
  final String connectionType;
  final int batteryPercent;
  final int signalStrength; // 0‑4 bars
  final int uptimeMinutes;
  final bool isConnected;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.verticalGradient([
          SennaColors.surface,
          SennaColors.background,
        ]),
        border: Border(
          bottom: BorderSide(
            color: SennaColors.cyan.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // ── Left: logo ───────────────────────────────────────────
              _Logo(name: robotName),

              const SizedBox(width: 10),

              // ── Center: robot id + connection badges ─────────────────
              Expanded(child: _CenterSection(
                robotNumber: robotNumber,
                chipType: chipType,
                connectionType: connectionType,
                isConnected: isConnected,
              )),

              const SizedBox(width: 10),

              // ── Right: battery, signal, timer ────────────────────────
              _RightSection(
                batteryPercent: batteryPercent,
                signalStrength: signalStrength,
                uptimeMinutes: uptimeMinutes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

class _Logo extends StatelessWidget {
  const _Logo({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.smart_toy_outlined, color: SennaColors.cyan, size: 20),
        const SizedBox(width: 5),
        Text(
          name,
          style: SennaTextStyles.heading3.copyWith(
            color: SennaColors.cyan,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _CenterSection extends StatelessWidget {
  const _CenterSection({
    required this.robotNumber,
    required this.chipType,
    required this.connectionType,
    required this.isConnected,
  });

  final String robotNumber;
  final String chipType;
  final String connectionType;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Robot number badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: NeonDecorations.neonBorder(
            color: SennaColors.cyan,
            radius: 6,
            backgroundColor: SennaColors.cyan.withValues(alpha: 0.10),
          ),
          child: Text(
            robotNumber,
            style: SennaTextStyles.badge.copyWith(color: SennaColors.cyan),
          ),
        ),
        const SizedBox(width: 6),
        // Chip type badge
        _MiniChip(label: chipType, color: SennaColors.neonGreen),
        const SizedBox(width: 4),
        // Connection type badge
        _MiniChip(
          label: connectionType,
          color: isConnected ? SennaColors.cyan : SennaColors.red,
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 0.8),
      ),
      child: Text(
        label,
        style: SennaTextStyles.badge.copyWith(
          color: color,
          fontSize: 8,
        ),
      ),
    );
  }
}

class _RightSection extends StatelessWidget {
  const _RightSection({
    required this.batteryPercent,
    required this.signalStrength,
    required this.uptimeMinutes,
  });

  final int batteryPercent;
  final int signalStrength;
  final int uptimeMinutes;

  Color get _batteryColor {
    if (batteryPercent > 60) return SennaColors.neonGreen;
    if (batteryPercent > 25) return SennaColors.orange;
    return SennaColors.red;
  }

  IconData get _batteryIcon {
    if (batteryPercent > 80) return Icons.battery_full;
    if (batteryPercent > 60) return Icons.battery_5_bar;
    if (batteryPercent > 40) return Icons.battery_4_bar;
    if (batteryPercent > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Signal dots
        _SignalDots(strength: signalStrength),
        const SizedBox(width: 8),
        // Battery
        Icon(_batteryIcon, color: _batteryColor, size: 18),
        const SizedBox(width: 2),
        Text(
          '$batteryPercent%',
          style: SennaTextStyles.badge.copyWith(color: _batteryColor),
        ),
        const SizedBox(width: 8),
        // Timer
        Icon(Icons.timer_outlined, color: SennaColors.textSecondary, size: 13),
        const SizedBox(width: 2),
        Text(
          '${uptimeMinutes}m',
          style: SennaTextStyles.badge.copyWith(
            color: SennaColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SignalDots extends StatelessWidget {
  const _SignalDots({required this.strength});
  final int strength; // 0‑4

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final active = i < strength;
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? SennaColors.neonGreen
                : SennaColors.textDim.withValues(alpha: 0.3),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: SennaColors.neonGreen.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
