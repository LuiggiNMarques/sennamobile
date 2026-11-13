import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

class JoystickControl extends StatefulWidget {
  const JoystickControl({super.key});

  @override
  State<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends State<JoystickControl> {
  final BleService _ble = BleService();
  Offset _joystickOffset = Offset.zero;
  double _gasValue = 0.0;
  bool _isBraking = false;
  bool _isHonking = false;

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  double get _angleDegrees {
    if (_joystickOffset == Offset.zero) return 0.0;
    double angle = atan2(_joystickOffset.dx, -_joystickOffset.dy) * 180 / pi;
    if (angle < 0) angle += 360;
    return angle;
  }

  double get _forcePercent {
    return (_joystickOffset.distance.clamp(0.0, 1.0) * 100);
  }

  void _sendBleJoystick() {
    _ble.sendJoystick(
      angle: _angleDegrees,
      force: _forcePercent,
      throttle: _gasValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;
    const Color orange = SennaColors.orange;
    const Color cardBg = SennaColors.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // ── Main Interactive Split Area ─────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT: 360° Joystick ───────────────────────────────
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore_outlined, color: yellow, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            'DIREÇÃO 360°',
                            style: TextStyle(
                              color: yellow,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dialSize = min(constraints.maxWidth, constraints.maxHeight) - 8;
                            final radius = dialSize / 2;

                            return Center(
                              child: GestureDetector(
                                onPanStart: (details) {
                                  _updateJoystick(details.localPosition, radius);
                                  _sendBleJoystick();
                                },
                                onPanUpdate: (details) {
                                  _updateJoystick(details.localPosition, radius);
                                  _sendBleJoystick();
                                },
                                onPanEnd: (_) {
                                  setState(() => _joystickOffset = Offset.zero);
                                  _sendBleJoystick();
                                },
                                child: SizedBox(
                                  width: dialSize,
                                  height: dialSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: Size(dialSize, dialSize),
                                        painter: _JoystickDialPainter(),
                                      ),

                                      Positioned(
                                        top: 10,
                                        child: Text(
                                          '0° ^',
                                          style: TextStyle(
                                            color: yellow.withValues(alpha: 0.8),
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        child: Text(
                                          '90° >',
                                          style: TextStyle(
                                            color: yellow.withValues(alpha: 0.8),
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        child: Text(
                                          '180° v',
                                          style: TextStyle(
                                            color: yellow.withValues(alpha: 0.8),
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        child: Text(
                                          '< 270°',
                                          style: TextStyle(
                                            color: yellow.withValues(alpha: 0.8),
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      Transform.translate(
                                        offset: Offset(
                                          _joystickOffset.dx * (radius * 0.55),
                                          _joystickOffset.dy * (radius * 0.55),
                                        ),
                                        child: Container(
                                          width: dialSize * 0.32,
                                          height: dialSize * 0.32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                yellow,
                                                orange,
                                                const Color(0xFF1E1738),
                                              ],
                                            ),
                                            border: Border.all(color: yellow, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: yellow.withValues(alpha: 0.6),
                                                blurRadius: 16,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.sports_motorsports,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'ANG: ${_angleDegrees.toStringAsFixed(0).padLeft(3, '0')}°  ·  FORÇA: ${_forcePercent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: yellow,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // ── RIGHT: Gas vertical slider, Freio, and STOP ───────
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: magenta.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.speed, color: yellow, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'GÁS',
                                        style: TextStyle(
                                          color: yellow,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${(_gasValue * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: magenta,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 18,
                                        activeTrackColor: magenta,
                                        inactiveTrackColor: const Color(0xFF1B1B32),
                                        thumbColor: yellow,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 10,
                                        ),
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 18,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _gasValue,
                                        onChanged: (val) {
                                          _triggerHaptic();
                                          setState(() => _gasValue = val);
                                          _sendBleJoystick();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '▲ ACELERA',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Center(
                                child: Text(
                                  'GATILHO TÁTIL VERTICAL',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            // FREIO
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (_) {
                                  _triggerHaptic();
                                  setState(() => _isBraking = true);
                                  _ble.drive(direction: 'RE', speedPercent: 50);
                                },
                                onTapUp: (_) {
                                  setState(() => _isBraking = false);
                                  _ble.drive(direction: 'STOP', speedPercent: 0);
                                },
                                onTapCancel: () {
                                  setState(() => _isBraking = false);
                                  _ble.drive(direction: 'STOP', speedPercent: 0);
                                },
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: _isBraking
                                        ? magenta.withValues(alpha: 0.3)
                                        : const Color(0xFF1B1C33),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _isBraking ? magenta : magenta.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.refresh, color: magenta, size: 20),
                                      SizedBox(height: 2),
                                      Text(
                                        'FREIO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        'RÉ 50%',
                                        style: TextStyle(
                                          color: yellow,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // STOP
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _triggerHaptic();
                                  setState(() {
                                    _joystickOffset = Offset.zero;
                                    _gasValue = 0.0;
                                  });
                                  _ble.emergencyStop();
                                },
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: const RadialGradient(
                                      colors: [
                                        Color(0xFFFFD600),
                                        Color(0xFFFF6A00),
                                        Color(0xFFFF2200),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: yellow, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: yellow.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.pan_tool_rounded, color: Colors.black, size: 20),
                                      SizedBox(height: 2),
                                      Text(
                                        'STOP',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        'EMERGÊNCIA',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 6.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Buzina de Fliperama Arcade Card ─────────────────────────
          GestureDetector(
            onTapDown: (_) {
              _triggerHaptic();
              setState(() => _isHonking = true);
              _ble.setBuzzer(true);
            },
            onTapUp: (_) {
              setState(() => _isHonking = false);
              _ble.setBuzzer(false);
            },
            onTapCancel: () {
              setState(() => _isHonking = false);
              _ble.setBuzzer(false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF141933),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHonking ? yellow : yellow.withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF222036),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: yellow.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.campaign_rounded, color: yellow, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BUZINA DE FLIPERAMA ARCADE',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Feedback: Sonoro & Vibração Háptica',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 8.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2734),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '2.4 KHZ',
                      style: TextStyle(
                        color: yellow,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: const [
                      Icon(Icons.graphic_eq_rounded, color: magenta, size: 18),
                      Icon(Icons.volume_up_rounded, color: yellow, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1528),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.gamepad_outlined, color: magenta, size: 14),
                const SizedBox(width: 8),
                Text(
                  _ble.isConnected ? 'JOYSTICK VIRTUAL ATIVO  ·  ESP32-C3 CONECTADO' : 'JOYSTICK PRONTO  ·  AGUARDANDO BLE',
                  style: const TextStyle(
                    color: yellow,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  void _updateJoystick(Offset localPos, double radius) {
    _triggerHaptic();
    final center = Offset(radius, radius);
    final diff = localPos - center;
    final dist = diff.distance;

    if (dist <= radius * 0.7) {
      setState(() {
        _joystickOffset = Offset(diff.dx / (radius * 0.7), diff.dy / (radius * 0.7));
      });
    } else {
      final unit = diff / dist;
      setState(() {
        _joystickOffset = unit;
      });
    }
  }
}

class _JoystickDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final glow = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius - 4, glow);

    final outerRing = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 4, outerRing);

    final midRing = Paint()
      ..color = const Color(0xFFFFD600).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.65, midRing);

    final innerRing = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * 0.35, innerRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
