import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter for the BLE radar animation.
/// Draws concentric circles, a sweeping scan line, and device dots.
class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final List<Offset> devicePositions;
  final Color primaryColor;
  final Color sweepColor;

  RadarPainter({
    required this.sweepAngle,
    this.devicePositions = const [],
    this.primaryColor = const Color(0xFF00E5FF),
    this.sweepColor = const Color(0xFFFF006E),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 4;

    // Draw concentric circles
    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * (i / 4);
      final circlePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.08 + (i * 0.03))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, radius, circlePaint);
    }

    // Draw crosshairs
    final crossPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      crossPaint,
    );

    // Draw sweep gradient (radar scan effect)
    final sweepGradient = SweepGradient(
      startAngle: sweepAngle - 0.6,
      endAngle: sweepAngle,
      colors: [
        sweepColor.withValues(alpha: 0.0),
        sweepColor.withValues(alpha: 0.05),
        sweepColor.withValues(alpha: 0.15),
        primaryColor.withValues(alpha: 0.35),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      transform: GradientRotation(0),
    );

    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: center, radius: maxRadius),
      );

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Draw sweep line
    final lineEndX = center.dx + maxRadius * math.cos(sweepAngle);
    final lineEndY = center.dy + maxRadius * math.sin(sweepAngle);
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, Offset(lineEndX, lineEndY), linePaint);

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerDotPaint);

    // Draw center glow
    final centerGlowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerGlowPaint);

    // Draw device dots
    for (final pos in devicePositions) {
      // pos is normalized (-1 to 1), map to canvas
      final dotX = center.dx + pos.dx * maxRadius;
      final dotY = center.dy + pos.dy * maxRadius;

      // Glow
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dotX, dotY), 5, glowPaint);

      // Dot
      final dotPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 3.5, dotPaint);

      // Bright center
      final brightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 1.5, brightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.devicePositions != devicePositions;
  }
}

/// Animated radar widget that manages its own AnimationController.
class AnimatedRadar extends StatefulWidget {
  final double size;
  final List<Offset> devicePositions;

  const AnimatedRadar({
    super.key,
    this.size = 220,
    this.devicePositions = const [
      Offset(0.35, -0.45),
      Offset(-0.55, 0.25),
      Offset(0.15, 0.6),
      Offset(-0.3, -0.55),
    ],
  });

  @override
  State<AnimatedRadar> createState() => _AnimatedRadarState();
}

class _AnimatedRadarState extends State<AnimatedRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A0E1A),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: RadarPainter(
              sweepAngle: _controller.value * 2 * math.pi,
              devicePositions: widget.devicePositions,
            ),
          ),
        );
      },
    );
  }
}
