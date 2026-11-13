import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/neon_decorations.dart';

/// Semantic variant for [NeonButton].
enum NeonButtonVariant {
  primary, // cyan
  danger, // magenta / red
  warning, // orange
  success, // neon green
}

/// A reusable neon-styled button with optional icon, glow-on-press,
/// and multiple colour variants.
class NeonButton extends StatefulWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = NeonButtonVariant.primary,
    this.expanded = false,
    this.height = 44,
    this.useGradient = false,
    this.customColors,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NeonButtonVariant variant;

  /// When true the button stretches to fill available width.
  final bool expanded;
  final double height;

  /// Use a gradient background instead of solid colour.
  final bool useGradient;

  /// Override the default variant colours ([start, end] for gradient).
  final List<Color>? customColors;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _pressed = false;

  List<Color> get _colors {
    if (widget.customColors != null) return widget.customColors!;
    switch (widget.variant) {
      case NeonButtonVariant.primary:
        return [SennaColors.cyan, const Color(0xFF00B8D4)];
      case NeonButtonVariant.danger:
        return [SennaColors.magenta, SennaColors.red];
      case NeonButtonVariant.warning:
        return [SennaColors.orange, SennaColors.yellow];
      case NeonButtonVariant.success:
        return [SennaColors.neonGreen, const Color(0xFF00C853)];
    }
  }

  Color get _baseColor => _colors.first;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final opacity = enabled ? 1.0 : 0.4;

    final decoration = widget.useGradient
        ? NeonDecorations.gradientButton(
            _colors,
            radius: 10,
            glow: _pressed ? NeonDecorations.neonGlow(_baseColor, spread: 3) : null,
          )
        : BoxDecoration(
            color: _baseColor.withValues(alpha: _pressed ? 0.35 : 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _baseColor.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: _pressed
                ? NeonDecorations.neonGlow(_baseColor, spread: 2)
                : [
                    BoxShadow(
                      color: _baseColor.withValues(alpha: 0.10),
                      blurRadius: 8,
                    ),
                  ],
          );

    final child = Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: decoration,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize:
                widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.useGradient
                      ? SennaColors.background
                      : _baseColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: SennaTextStyles.button.copyWith(
                  color: widget.useGradient
                      ? SennaColors.background
                      : _baseColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return widget.expanded
        ? SizedBox(width: double.infinity, child: child)
        : child;
  }
}
