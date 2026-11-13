import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

/// Top cockpit panel shared across control modes (D-Pad, Joystick, Volante).
/// Displays live BLE connection telemetry and power mode toggles.
class CockpitTopPanel extends StatefulWidget {
  final int selectedPowerMode; // 0 = ECO, 1 = PISTA, 2 = SENNA 100%
  final ValueChanged<int> onPowerModeChanged;
  final bool isFarolOn;
  final VoidCallback onToggleFarol;

  const CockpitTopPanel({
    super.key,
    required this.selectedPowerMode,
    required this.onPowerModeChanged,
    required this.isFarolOn,
    required this.onToggleFarol,
  });

  @override
  State<CockpitTopPanel> createState() => _CockpitTopPanelState();
}

class _CockpitTopPanelState extends State<CockpitTopPanel> {
  final BleService _ble = BleService();

  @override
  void initState() {
    super.initState();
    _ble.addListener(_onBleUpdate);
  }

  @override
  void dispose() {
    _ble.removeListener(_onBleUpdate);
    super.dispose();
  }

  void _onBleUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color cyan = SennaColors.cyan;
    const Color magenta = SennaColors.magenta;
    const Color orange = SennaColors.orange;
    const Color yellow = SennaColors.yellow;
    const Color cardBg = SennaColors.surface;

    final isConnected = _ble.isConnected;
    final batVolt = _ble.batteryVoltage;
    final batPct = _ble.batteryPercent;
    final latency = _ble.latencyMs;
    final rpm = _ble.motorsRpm;
    final temp = _ble.chipTemp;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // ── 1. Top Bar: Robot identity & status badges ─────────────
          Row(
            children: [
              // Robot Avatar Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1838),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: magenta.withValues(alpha: 0.8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: magenta.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.sports_motorsports, color: yellow, size: 22),
                ),
              ),
              const SizedBox(width: 8),

              // Title and connection info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SENNINHA ',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Text(
                          '#01',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: magenta.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: magenta.withValues(alpha: 0.6), width: 0.8),
                          ),
                          child: const Text(
                            'DECABOT',
                            style: TextStyle(
                              color: magenta,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected ? const Color(0xFF00FF85) : yellow,
                            boxShadow: [
                              BoxShadow(
                                color: isConnected ? const Color(0xFF00FF85) : yellow,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isConnected ? 'ESP32-C3 · BLE CONECTADO' : 'ESP32-C3 · PRONTO P/ CONECTAR',
                          style: TextStyle(
                            color: isConnected ? const Color(0xFF00FF85) : yellow.withValues(alpha: 0.85),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right telemetry pills: Battery & Latency
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: yellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.battery_charging_full_rounded, color: yellow, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${batVolt.toStringAsFixed(1)}V ($batPct%)',
                      style: const TextStyle(
                        color: yellow,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(width: 1, height: 10, color: Colors.white24),
                    const SizedBox(width: 6),
                    const Icon(Icons.speed, color: magenta, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      '${latency}ms',
                      style: const TextStyle(
                        color: magenta,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Config/Fullscreen icon button
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.crop_free, color: yellow, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── 2. Telemetry mini-cards: Motores RPM, LED Matrix, Farol ─
          Row(
            children: [
              // Card 1: MOTORES RPM
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cyan.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'MOTORES RPM',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (rpm / 8000).clamp(0.0, 1.0),
                                minHeight: 3,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(orange),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'L/R',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 6.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (rpm / 8000).clamp(0.0, 1.0),
                                minHeight: 3,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(orange),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PWM: 255/255',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 7,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'TEMP: ${temp.toStringAsFixed(0)}°C',
                            style: TextStyle(
                              color: yellow.withValues(alpha: 0.9),
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
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

              // Card 2: LED MATRIX TURBO R
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: magenta.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0B1E),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: magenta.withValues(alpha: 0.5)),
                        ),
                        child: GridView.count(
                          crossAxisCount: 4,
                          padding: const EdgeInsets.all(2),
                          mainAxisSpacing: 1.5,
                          crossAxisSpacing: 1.5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(16, (i) {
                            final isOn = [0, 1, 2, 3, 5, 6, 9, 10, 12, 15].contains(i);
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isOn ? magenta : Colors.white10,
                                boxShadow: isOn
                                    ? [BoxShadow(color: magenta, blurRadius: 2)]
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'LED MATRIX',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 6.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'TURBO R',
                              style: TextStyle(
                                color: magenta,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Trocar ⟳',
                              style: TextStyle(
                                color: yellow.withValues(alpha: 0.9),
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Card 3: FAROL (ON/OFF)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    widget.onToggleFarol();
                    _ble.setFarol(!widget.isFarolOn);
                  },
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isFarolOn
                          ? yellow.withValues(alpha: 0.15)
                          : cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.isFarolOn ? yellow : Colors.white24,
                        width: widget.isFarolOn ? 1.5 : 1,
                      ),
                      boxShadow: widget.isFarolOn
                          ? [
                              BoxShadow(
                                color: yellow.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isFarolOn
                              ? Icons.wb_sunny
                              : Icons.wb_sunny_outlined,
                          color: widget.isFarolOn ? yellow : Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isFarolOn ? 'FAROL ON' : 'FAROL OFF',
                          style: TextStyle(
                            color: widget.isFarolOn ? yellow : Colors.white54,
                            fontSize: 7.5,
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

          const SizedBox(height: 10),

          // ── 3. Power Modes: ECO, PISTA, SENNA 100% TURBO BOOST ─────
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildPowerModeButton(
                  title: 'ECO',
                  subtitle: '35% PWM',
                  icon: Icons.eco_outlined,
                  isSelected: widget.selectedPowerMode == 0,
                  activeColor: yellow,
                  onTap: () {
                    widget.onPowerModeChanged(0);
                    _ble.setPowerMode(0);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildPowerModeButton(
                  title: 'PISTA',
                  subtitle: '75% PWM',
                  icon: Icons.sports_score_rounded,
                  isSelected: widget.selectedPowerMode == 1,
                  activeColor: magenta,
                  onTap: () {
                    widget.onPowerModeChanged(1);
                    _ble.setPowerMode(1);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _buildTurboModeButton(
                  isSelected: widget.selectedPowerMode == 2,
                  onTap: () {
                    widget.onPowerModeChanged(2);
                    _ble.setPowerMode(2);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : SennaColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? activeColor : Colors.white38, size: 12),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? activeColor : Colors.white60,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? activeColor.withValues(alpha: 0.8) : Colors.white30,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurboModeButton({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF007A), Color(0xFFFF9500)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : SennaColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFFF007A).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF007A).withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: isSelected ? Colors.black : const Color(0xFFFF007A),
                  size: 13,
                ),
                const SizedBox(width: 3),
                Text(
                  'SENNA 100%',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'TURBO BOOST',
              style: TextStyle(
                color: isSelected ? Colors.black87 : const Color(0xFFFF007A),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
