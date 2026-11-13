import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

class SteeringControl extends StatefulWidget {
  const SteeringControl({super.key});

  @override
  State<SteeringControl> createState() => _SteeringControlState();
}

class _SteeringControlState extends State<SteeringControl> {
  final BleService _ble = BleService();
  int _rotaryMode = 2; // 0=ECO, 1=PISTA, 2=SENNA
  String? _activePaddle;
  bool _isHonking = false;
  bool _isFarolOn = false;

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _onDriveDown(String dir) {
    _triggerHaptic();
    _ble.drive(direction: dir, speedPercent: 100);
  }

  void _onDriveUp() {
    _ble.drive(direction: 'STOP', speedPercent: 0);
  }

  @override
  Widget build(BuildContext context) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;
    const Color orange = SennaColors.orange;
    const Color green = SennaColors.neonGreen;
    const Color cardBg = SennaColors.surface;

    final rpm = _ble.motorsRpm;
    final temp = _ble.chipTemp;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),

          // ── Header: LAYOUT DE PILOTAGEM ─────────────────────────────
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: magenta,
                  boxShadow: [BoxShadow(color: magenta, blurRadius: 4)],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'LAYOUT DE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'PILOTAGEM:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: yellow.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'VOLANTE F1\nCOMPETIÇÃO',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: yellow,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: const [
                  Icon(Icons.sports_esports, color: magenta, size: 16),
                  SizedBox(height: 2),
                  Text(
                    'MODO\nPILOTO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: magenta,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Telemetria RPM (F1 Shift Lights Bar) & Cards ────────────
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
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
                                'TELEMETRIA RPM',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$rpm RPM',
                            style: const TextStyle(
                              color: yellow,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildShiftDot(green, rpm > 2000),
                          _buildShiftDot(green, rpm > 3500),
                          _buildShiftDot(green, rpm > 5000),
                          _buildShiftDot(yellow, rpm > 6000),
                          _buildShiftDot(yellow, rpm > 6800),
                          _buildShiftDot(magenta, rpm > 7200),
                          _buildShiftDot(magenta, rpm > 7400),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TEMP: ${temp.toStringAsFixed(0)}°C',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 7,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Text(
                            'TORQUE: 100%',
                            style: TextStyle(
                              color: yellow,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  setState(() => _isFarolOn = !_isFarolOn);
                  _ble.setFarol(_isFarolOn);
                },
                child: Container(
                  width: 58,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _isFarolOn ? yellow.withValues(alpha: 0.15) : cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isFarolOn ? yellow : Colors.white24,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isFarolOn ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                        color: _isFarolOn ? yellow : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isFarolOn ? 'FAROL ON' : 'FAROL OFF',
                        style: TextStyle(
                          color: _isFarolOn ? yellow : Colors.white54,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 68,
                height: 64,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LED ROSTO\nTURBO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: magenta,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trocar ⟳',
                      style: TextStyle(
                        color: yellow.withValues(alpha: 0.8),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Main Module: SENNINHA CORSE - F1 STEERING SYSTEM MK-II ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111429),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: magenta.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: magenta.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: magenta,
                        boxShadow: [BoxShadow(color: magenta, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SENNINHA CORSE',
                      style: TextStyle(
                        color: magenta,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'F1 STEERING SYSTEM ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: magenta,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'MK-II',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── FRENTE BUTTON ─────────────────────────────────────
                GestureDetector(
                  onTapDown: (_) => _onDriveDown('FRENTE'),
                  onTapUp: (_) => _onDriveUp(),
                  onTapCancel: () => _onDriveUp(),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F3A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: yellow, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: yellow.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: yellow, width: 1.2),
                          ),
                          child: const Icon(Icons.arrow_upward_rounded, color: yellow, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: const [
                            Text(
                              'FRENTE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'ACELERADOR +100%',
                              style: TextStyle(
                                color: yellow,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── MIDDLE ROW: PADDLE ESQ, ROTARY, PADDLE DIR ────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildPaddleButton(
                      side: 'ESQ',
                      arrows: '<<',
                      isPressed: _activePaddle == 'ESQ',
                      onTapDown: () {
                        _triggerHaptic();
                        setState(() => _activePaddle = 'ESQ');
                        _ble.drive(direction: 'ESQ', speedPercent: 80);
                      },
                      onTapUp: () {
                        setState(() => _activePaddle = null);
                        _ble.drive(direction: 'STOP', speedPercent: 0);
                      },
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C0F22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'ROTARY\nDIAL:',
                                  style: TextStyle(
                                    color: yellow,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '100% SENNA\nBOOST',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: magenta,
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171A30),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  _buildRotaryPill('ECO', 0, yellow),
                                  _buildRotaryPill('PISTA', 1, orange),
                                  _buildRotaryPill('SENNA', 2, magenta),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _triggerHaptic();
                                    _ble.emergencyStop();
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: yellow, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: yellow.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: magenta,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.cancel_outlined, color: Colors.white, size: 14),
                                            Text(
                                              'STOP',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 6.5,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

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
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isHonking ? yellow.withValues(alpha: 0.3) : const Color(0xFF1E1F38),
                                      border: Border.all(color: yellow, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: yellow.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.campaign, color: yellow, size: 16),
                                        Text(
                                          'BUZINA',
                                          style: TextStyle(
                                            color: yellow,
                                            fontSize: 6.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    _buildPaddleButton(
                      side: 'DIR',
                      arrows: '>>',
                      isPressed: _activePaddle == 'DIR',
                      onTapDown: () {
                        _triggerHaptic();
                        setState(() => _activePaddle = 'DIR');
                        _ble.drive(direction: 'DIR', speedPercent: 80);
                      },
                      onTapUp: () {
                        setState(() => _activePaddle = null);
                        _ble.drive(direction: 'STOP', speedPercent: 0);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── MARCHA RÉ BUTTON ──────────────────────────────────
                GestureDetector(
                  onTapDown: (_) => _onDriveDown('RE'),
                  onTapUp: (_) => _onDriveUp(),
                  onTapCancel: () => _onDriveUp(),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F3A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: yellow, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: yellow.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: yellow, width: 1.2),
                          ),
                          child: const Icon(Icons.arrow_downward_rounded, color: yellow, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: const [
                            Text(
                              'MARCHA RÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'RETROCESSO -60%',
                              style: TextStyle(
                                color: yellow,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_open_rounded, color: yellow, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        _ble.isConnected ? 'PILOTO PRONTO  ·  VOLANTE CALIBRADO' : 'AGUARDANDO CONEXÃO BLE',
                        style: const TextStyle(
                          color: yellow,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _ble.isConnected ? 'CAN-BUS OK' : 'OFFLINE',
                        style: TextStyle(
                          color: magenta.withValues(alpha: 0.8),
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_tethering, color: yellow, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ESTRUTURA DE TRAÇÃO: DUPLO MOTOR DC + ESC 30A',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'POTÊNCIA ATIVA:',
                      style: TextStyle(
                        color: yellow,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        color: yellow,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaddleButton({
    required String side,
    required String arrows,
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;

    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 54,
        height: 130,
        decoration: BoxDecoration(
          color: isPressed ? magenta.withValues(alpha: 0.3) : const Color(0xFF1E1738),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPressed ? yellow : magenta,
            width: isPressed ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: magenta.withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'PADDLE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  arrows,
                  style: const TextStyle(
                    color: yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  side,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'RETENÇÃO >',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotaryPill(String title, int index, Color color) {
    final isSelected = _rotaryMode == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _triggerHaptic();
          setState(() => _rotaryMode = index);
          _ble.setPowerMode(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white60,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.black : Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftDot(Color color, bool active) {
    return Container(
      width: 14,
      height: 7,
      decoration: BoxDecoration(
        color: active ? color : Colors.white10,
        borderRadius: BorderRadius.circular(3),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}
