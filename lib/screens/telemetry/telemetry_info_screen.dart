import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

class TelemetryInfoScreen extends StatefulWidget {
  final VoidCallback onNavigateToRadar;

  const TelemetryInfoScreen({super.key, required this.onNavigateToRadar});

  @override
  State<TelemetryInfoScreen> createState() => _TelemetryInfoScreenState();
}

class _TelemetryInfoScreenState extends State<TelemetryInfoScreen> {
  final BleService _ble = BleService();
  double _trimValue = 0.0;

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

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
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;
    const Color cardBg = SennaColors.surface;

    final isConnected = _ble.isConnected;
    final batVolt = _ble.batteryVoltage;
    final batPct = _ble.batteryPercent;
    final rpm = _ble.motorsRpm;
    final motorL = _ble.motorL;
    final motorR = _ble.motorR;
    final temp = _ble.chipTemp;
    final latency = _ble.latencyMs;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Top Header: SENNINHA Cyber Telemetria ───────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1A3A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: yellow.withValues(alpha: 0.6)),
                ),
                child: const Icon(Icons.hub_outlined, color: magenta, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SENNINHA',
                    style: TextStyle(
                      color: yellow,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Cyber Telemetria',
                    style: TextStyle(
                      color: yellow,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: magenta,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('03', style: TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                    const SizedBox(width: 6),
                    Text('${latency}ms', style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
                    const SizedBox(width: 6),
                    const Icon(Icons.battery_5_bar_rounded, color: yellow, size: 13),
                    Text('$batPct%', style: const TextStyle(color: yellow, fontSize: 9, fontFamily: 'monospace')),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  border: Border.all(color: magenta.withValues(alpha: 0.6)),
                ),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white70, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Bot Connected Hero Banner ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: magenta.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              const SizedBox(width: 6),
                              Text(
                                isConnected ? 'ESP32-C3 CONECTADO' : 'ESP32-C3 DESCONECTADO',
                                style: TextStyle(
                                  color: isConnected ? const Color(0xFF00FF85) : yellow,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _ble.robotName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isConnected
                                ? 'Pronto para a largada · Pista Cyber Speed'
                                : 'Aguardando pareamento BLE no grid',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 82,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2140),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: magenta.withValues(alpha: 0.6)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.smart_toy_rounded,
                              color: yellow,
                              size: 34,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: yellow, width: 0.5),
                            ),
                            child: const Text(
                              'v2.6',
                              style: TextStyle(
                                color: yellow,
                                fontSize: 6.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.gamepad, color: yellow, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'Sessão BLE Ativa\n(2.4GHz)' : 'Varredura ativa\n(2.4GHz)',
                      style: const TextStyle(
                        color: yellow,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _triggerHaptic();
                        _ble.startScan();
                        widget.onNavigateToRadar();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF007A), Color(0xFFFF9500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: magenta.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.radar, color: Colors.white, size: 13),
                            SizedBox(width: 6),
                            Text(
                              'Buscar\nRobôs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
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

          const SizedBox(height: 14),

          // ── DISPOSITIVOS BLE DETECTADOS Section ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bluetooth_searching, color: magenta, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'DISPOSITIVOS BLE DETECTADOS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                '${_ble.scanResults.length + (isConnected ? 1 : 0)} Encontrados',
                style: const TextStyle(
                  color: yellow,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Card: Current Connected Senninha
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF131733),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: magenta.withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: magenta.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: magenta, size: 20),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: const Icon(Icons.lock, color: yellow, size: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _ble.robotName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isConnected ? magenta : Colors.white24,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  isConnected ? 'ATUAL' : 'OFFLINE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'MAC: ${_ble.macAddress}  ·  BLE 5.0',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 7.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '📶 ${_ble.rssi} dBm',
                          style: const TextStyle(
                            color: yellow,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Text(
                          '0.02% perda',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 7,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lock, color: yellow, size: 11),
                        SizedBox(width: 4),
                        Text(
                          'SESSÃO FIXADA  ·  CONEXÃO BLOQUEADA',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        _triggerHaptic();
                        if (isConnected) {
                          _ble.disconnect();
                        } else {
                          widget.onNavigateToRadar();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: magenta.withValues(alpha: 0.8)),
                        ),
                        child: Row(
                          children: [
                            Icon(isConnected ? Icons.link_off : Icons.link, color: magenta, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              isConnected ? 'Desconectar' : 'Conectar',
                              style: const TextStyle(
                                color: magenta,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
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

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: yellow.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_clock, color: yellow, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trava de Conexão Ativa: Desconecte do Senninha atual para buscar ou selecionar outro robô no grid.',
                    style: TextStyle(
                      color: yellow.withValues(alpha: 0.9),
                      fontSize: 7.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          _buildBlockedDeviceTile(
            title: 'GRID-IOT-02',
            mac: '48:76:4E:33:88:32',
            dbm: '-78 dBm',
            icon: Icons.cell_tower,
          ),

          const SizedBox(height: 4),

          _buildBlockedDeviceTile(
            title: 'TURBO-PIT-STOP-BEACON',
            mac: '24:DC:C3:99:55:01',
            dbm: '-89 dBm',
            icon: Icons.radar,
          ),

          const SizedBox(height: 14),

          // ── TELEMETRIA EM TEMPO REAL Section ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.speed, color: yellow, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'TELEMETRIA EM TEMPO REAL',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    '• ',
                    style: TextStyle(color: yellow, fontSize: 10),
                  ),
                  Text(
                    'Taxa: 50Hz',
                    style: TextStyle(
                      color: yellow,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2x2 Telemetry Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'MOTORES L / R',
                  icon: Icons.refresh,
                  value: '$rpm',
                  unit: 'RPM',
                  progress: (rpm / 8000).clamp(0.0, 1.0),
                  accentColor: yellow,
                  footerLeft: 'L: $motorL',
                  footerRight: 'R: $motorR',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'LIPO 2S PACK',
                  icon: Icons.battery_charging_full,
                  value: batVolt.toStringAsFixed(2),
                  unit: 'V',
                  progress: (batPct / 100).clamp(0.0, 1.0),
                  accentColor: yellow,
                  footerLeft: 'Célula: ${(batVolt / 2).toStringAsFixed(2)}V',
                  footerRight: '$batPct%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'ESP32 CORE',
                  icon: Icons.thermostat,
                  value: temp.toStringAsFixed(1),
                  unit: '°C',
                  progress: (temp / 100).clamp(0.0, 1.0),
                  accentColor: magenta,
                  footerLeft: 'RISC-V 160MHz',
                  footerRight: 'Normal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  title: 'LATÊNCIA BLE',
                  icon: Icons.podcasts,
                  value: '$latency',
                  unit: 'ms',
                  progress: (latency / 100).clamp(0.0, 1.0),
                  accentColor: magenta,
                  footerLeft: 'Buffer: 0',
                  footerRight: 'Perda: 0%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Calibração de Trim Section ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calibração de Trim',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Garante tração perfeitamente alinhada',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 7.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1430),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: magenta.withValues(alpha: 0.7)),
                      ),
                      child: Text(
                        _trimValue == 0.0
                            ? '0.0 (Neutro)'
                            : '${_trimValue.toStringAsFixed(1)} (${_trimValue < 0 ? "Esq" : "Dir"})',
                        style: const TextStyle(
                          color: magenta,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildTrimButton(
                        '<< Esquerda',
                        () {
                          _triggerHaptic();
                          setState(() => _trimValue = (_trimValue - 0.2).clamp(-5.0, 5.0));
                          _ble.setTrim(_trimValue);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildTrimButton(
                        'Reset',
                        () {
                          _triggerHaptic();
                          setState(() => _trimValue = 0.0);
                          _ble.setTrim(0.0);
                        },
                        isNeutral: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: _buildTrimButton(
                        'Direita >>',
                        () {
                          _triggerHaptic();
                          setState(() => _trimValue = (_trimValue + 0.2).clamp(-5.0, 5.0));
                          _ble.setTrim(_trimValue);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MOTOR L: ${(98 - _trimValue * 2).toInt()}%',
                      style: const TextStyle(
                        color: magenta,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            activeTrackColor: magenta,
                            inactiveTrackColor: Colors.white12,
                            thumbColor: yellow,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: _trimValue,
                            min: -5.0,
                            max: 5.0,
                            onChanged: (val) {
                              _triggerHaptic();
                              setState(() => _trimValue = val);
                              _ble.setTrim(val);
                            },
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'MOTOR R: ${(100 + _trimValue * 2).toInt()}%',
                      style: const TextStyle(
                        color: yellow,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBlockedDeviceTile({
    required String title,
    required String mac,
    required String dbm,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101326),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.lock, color: Colors.white24, size: 9),
                  ],
                ),
                Text(
                  'MAC: $mac',
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 7,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Text(
            dbm,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 7.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock, color: Colors.white38, size: 8),
                SizedBox(width: 2),
                Text(
                  'Bloqueado',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required IconData icon,
    required String value,
    required String unit,
    required double progress,
    required Color accentColor,
    required String footerLeft,
    required String footerRight,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF12162E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: accentColor, size: 12),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footerLeft,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 7,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                footerRight,
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.9),
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrimButton(String label, VoidCallback onTap, {bool isNeutral = false}) {
    const Color magenta = SennaColors.magenta;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1832),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isNeutral ? Colors.white24 : magenta.withValues(alpha: 0.6),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isNeutral ? Colors.white70 : magenta,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
