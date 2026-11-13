import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

class DpadControl extends StatefulWidget {
  const DpadControl({super.key});

  @override
  State<DpadControl> createState() => _DpadControlState();
}

class _DpadControlState extends State<DpadControl> {
  final BleService _ble = BleService();
  String? _activeButton;
  bool _isHonking = false;

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _onDirectionDown(String dir) {
    _triggerHaptic();
    setState(() => _activeButton = dir);
    _ble.drive(direction: dir, speedPercent: 100);
  }

  void _onDirectionUp() {
    setState(() => _activeButton = null);
    _ble.drive(direction: 'STOP', speedPercent: 0);
  }

  void _onEmergencyStop() {
    _triggerHaptic();
    setState(() => _activeButton = 'STOP');
    _ble.emergencyStop();
  }

  void _onBuzzer(bool on) {
    _triggerHaptic();
    setState(() => _isHonking = on);
    _ble.setBuzzer(on);
  }

  @override
  Widget build(BuildContext context) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;
    const Color orange = SennaColors.orange;
    const Color green = SennaColors.neonGreen;

    return Column(
      children: [
        const SizedBox(height: 10),

        // ── Main Directional D-Pad Circular Pad ───────────────────────
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padSize = min(constraints.maxWidth - 24, constraints.maxHeight - 20)
                    .clamp(240.0, 360.0);

                return SizedBox(
                  width: padSize,
                  height: padSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(padSize, padSize),
                        painter: _DpadDialPainter(),
                      ),

                      Positioned(
                        top: padSize * 0.05,
                        child: Text(
                          '+ AVANÇO MÁXIMO',
                          style: TextStyle(
                            color: yellow.withValues(alpha: 0.8),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: padSize * 0.05,
                        child: Text(
                          '- MARCHA RÉ',
                          style: TextStyle(
                            color: yellow.withValues(alpha: 0.8),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      // ── UP BUTTON (FRENTE) ───────────────────────────
                      Positioned(
                        top: padSize * 0.12,
                        child: _buildDirectionKey(
                          id: 'FRENTE',
                          label: 'FRENTE',
                          arrowIcon: Icons.keyboard_arrow_up_rounded,
                          width: padSize * 0.28,
                          height: padSize * 0.23,
                        ),
                      ),

                      // ── LEFT BUTTON (ESQ) ────────────────────────────
                      Positioned(
                        left: padSize * 0.08,
                        child: _buildDirectionKey(
                          id: 'ESQ',
                          label: 'ESQ',
                          arrowIcon: Icons.keyboard_arrow_left_rounded,
                          width: padSize * 0.24,
                          height: padSize * 0.26,
                        ),
                      ),

                      // ── RIGHT BUTTON (DIR) ───────────────────────────
                      Positioned(
                        right: padSize * 0.08,
                        child: _buildDirectionKey(
                          id: 'DIR',
                          label: 'DIR',
                          arrowIcon: Icons.keyboard_arrow_right_rounded,
                          width: padSize * 0.24,
                          height: padSize * 0.26,
                        ),
                      ),

                      // ── DOWN BUTTON (RÉ) ─────────────────────────────
                      Positioned(
                        bottom: padSize * 0.12,
                        child: _buildDirectionKey(
                          id: 'RE',
                          label: 'RÉ',
                          arrowIcon: Icons.keyboard_arrow_down_rounded,
                          width: padSize * 0.28,
                          height: padSize * 0.23,
                        ),
                      ),

                      // ── CENTER STOP BUTTON ───────────────────────────
                      GestureDetector(
                        onTapDown: (_) => _onEmergencyStop(),
                        onTapUp: (_) => setState(() => _activeButton = null),
                        onTapCancel: () => setState(() => _activeButton = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: padSize * 0.26,
                          height: padSize * 0.26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: _activeButton == 'STOP'
                                  ? [Colors.white, orange, const Color(0xFFFF2200)]
                                  : [
                                      const Color(0xFFFF6A00),
                                      const Color(0xFFFF2200),
                                      const Color(0xFF990000),
                                    ],
                            ),
                            border: Border.all(
                              color: yellow,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: yellow.withValues(alpha: 0.6),
                                blurRadius: 18,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: orange.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pan_tool_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'STOP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: padSize * 0.038,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ── Buzina de Corrida Card ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GestureDetector(
            onTapDown: (_) => _onBuzzer(true),
            onTapUp: (_) => _onBuzzer(false),
            onTapCancel: () => _onBuzzer(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141933),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHonking ? yellow : yellow.withValues(alpha: 0.7),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: yellow.withValues(alpha: _isHonking ? 0.35 : 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF222036),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: yellow.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: yellow,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'BUZINA DE CORRIDA',
                              style: TextStyle(
                                color: yellow,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: yellow,
                                boxShadow: [
                                  BoxShadow(color: yellow, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buzzer PWM 2.4kHz · Toque Rápido',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.volume_up_rounded, color: yellow, size: 20),
                      SizedBox(width: 2),
                      Icon(Icons.graphic_eq_rounded, color: magenta, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Cockpit Ready Status Footer ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1528),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, color: green, size: 14),
                const SizedBox(width: 8),
                Text(
                  'READY',
                  style: TextStyle(
                    color: green,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  _ble.isConnected
                      ? '  ·  ESP32-C3 CONECTADO'
                      : '  ·  COCKPIT SENNINHA AGUARDANDO BLE',
                  style: TextStyle(
                    color: yellow,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const Spacer(),
                const Text(
                  'BLE v5.2',
                  style: TextStyle(
                    color: magenta,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildDirectionKey({
    required String id,
    required String label,
    required IconData arrowIcon,
    required double width,
    required double height,
  }) {
    final isPressed = _activeButton == id;
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;

    return GestureDetector(
      onTapDown: (_) => _onDirectionDown(id),
      onTapUp: (_) => _onDirectionUp(),
      onTapCancel: () => _onDirectionUp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isPressed
              ? magenta.withValues(alpha: 0.3)
              : const Color(0xFF1E1738).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPressed ? yellow : magenta.withValues(alpha: 0.8),
            width: isPressed ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isPressed ? yellow : magenta).withValues(alpha: 0.35),
              blurRadius: isPressed ? 14 : 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              arrowIcon,
              color: isPressed ? yellow : yellow.withValues(alpha: 0.9),
              size: 26,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DpadDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final glowPaint = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius - 6, glowPaint);

    final outerRing = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 6, outerRing);

    final innerRing = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.62, innerRing);

    final linePaint = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx, 10),
      Offset(center.dx, size.height - 10),
      linePaint,
    );
    canvas.drawLine(
      Offset(10, center.dy),
      Offset(size.width - 10, center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
