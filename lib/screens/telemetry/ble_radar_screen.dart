import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../theme/app_theme.dart';
import '../../services/ble_service.dart';

class BleRadarScreen extends StatefulWidget {
  final VoidCallback onBackToInfo;

  const BleRadarScreen({super.key, required this.onBackToInfo});

  @override
  State<BleRadarScreen> createState() => _BleRadarScreenState();
}

class _BleRadarScreenState extends State<BleRadarScreen> with SingleTickerProviderStateMixin {
  final BleService _ble = BleService();
  late AnimationController _radarController;
  int _selectedFilter = 0; // 0=TODOS, 1=DECABOTS, 2=BEACONS
  bool _autoReconnect = true;
  bool _lowLatency = true;

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ble.addListener(_onBleUpdate);
  }

  @override
  void dispose() {
    _ble.removeListener(_onBleUpdate);
    _radarController.dispose();
    super.dispose();
  }

  void _onBleUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color magenta = SennaColors.magenta;
    const Color yellow = SennaColors.yellow;
    const Color orange = SennaColors.orange;
    const Color cardBg = SennaColors.surface;

    final isScanning = _ble.isScanning;
    final isConnected = _ble.isConnected;
    final scanResults = _ble.scanResults;
    final latency = _ble.latencyMs;
    final batPct = _ble.batteryPercent;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Top Header ──────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBackToInfo,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1A3A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: yellow.withValues(alpha: 0.6)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: yellow, size: 20),
                ),
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
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: magenta),
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

          // ── Radar Header Bar ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: magenta.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bluetooth_searching, color: magenta, size: 16),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Radar BLE 2.4GHz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      isScanning ? 'ADAPTER: ESCANEANDO ATIVO...' : 'ADAPTER: ATIVO (CH 37-39)',
                      style: const TextStyle(
                        color: yellow,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: isScanning,
                  activeColor: yellow,
                  activeTrackColor: orange,
                  onChanged: (val) {
                    _triggerHaptic();
                    if (val) {
                      _ble.startScan();
                      _radarController.repeat();
                    } else {
                      _ble.stopScan();
                      _radarController.stop();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Radar 360° Visual Animated Display ──────────────────────
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1225),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: magenta.withValues(alpha: 0.3)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 160),
                      painter: _RadarScreenPainter(
                        scanAngle: isScanning ? _radarController.value * 2 * pi : 0,
                        discoveredCount: scanResults.length,
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: yellow, size: 6),
                      const SizedBox(width: 4),
                      Text(
                        isScanning
                            ? 'VARREDURA CONTÍNUA: ${scanResults.length} DISPOSITIVOS ENCONTRADOS'
                            : 'SCAN FINALIZADO: ${scanResults.length} DISPOSITIVOS',
                        style: const TextStyle(
                          color: yellow,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── PARAR / INICIAR BUSCA NO GRID button ────────────────────
          GestureDetector(
            onTap: () {
              _triggerHaptic();
              if (isScanning) {
                _ble.stopScan();
              } else {
                _ble.startScan();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isScanning
                      ? [const Color(0xFFFF007A), const Color(0xFFFF69B4)]
                      : [const Color(0xFFFF9500), const Color(0xFFFF007A)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: magenta.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isScanning ? Icons.stop_circle_outlined : Icons.refresh, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isScanning ? 'PARAR BUSCA NO GRID' : 'INICIAR BUSCA NO GRID (BLE)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── ROBÔ PAREADO Section (SLOT ATIVO) ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.sports_esports, color: yellow, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'ROBÔ PAREADO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isConnected ? magenta.withValues(alpha: 0.25) : Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isConnected ? 'SLOT ATIVO' : 'SLOT VAZIO',
                  style: TextStyle(
                    color: isConnected ? magenta : Colors.white38,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141733),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isConnected ? magenta.withValues(alpha: 0.6) : Colors.white24,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF221F40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.smart_toy_rounded, color: yellow, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, color: isConnected ? yellow : Colors.white38, size: 8),
                              const SizedBox(width: 4),
                              Text(
                                _ble.robotName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: magenta,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'ESP32-C3 PP3#',
                                  style: TextStyle(color: Colors.white, fontSize: 6.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: yellow.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'ITOSI CERT',
                                  style: TextStyle(color: yellow, fontSize: 6.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '📶 ${_ble.rssi} dBm',
                          style: const TextStyle(color: yellow, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                        Text(
                          isConnected ? 'SINAL FORTE' : 'DESCONECTADO',
                          style: TextStyle(
                            color: isConnected ? yellow : Colors.white38,
                            fontSize: 6.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0F22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('MAC HARDWARE:', style: TextStyle(color: Colors.white54, fontSize: 7.5)),
                          Text('TAXA GATT:', style: TextStyle(color: Colors.white54, fontSize: 7.5)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_ble.macAddress, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          const Text('50 Hz (20ms Low-Lag)', style: TextStyle(color: yellow, fontSize: 8.5, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('UUID DE CORRIDA (SPEED TELEMETRY):', style: TextStyle(color: Colors.white54, fontSize: 7)),
                      const Text(
                        '6E400001-B5A3-F393-E0A9-E50E24DCCA9E',
                        style: TextStyle(color: yellow, fontSize: 7.5, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: magenta.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: magenta, size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sessão exclusiva bloqueada. Para alternar para outro robô concorrente ou beacon da pista, desconecte a sessão atual com segurança.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    _triggerHaptic();
                    if (isConnected) {
                      _ble.disconnect();
                    } else {
                      _ble.startScan();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: magenta.withValues(alpha: 0.8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isConnected ? Icons.link_off : Icons.bluetooth_searching, color: magenta, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          isConnected ? 'DESCONECTAR ROBÔ ATUAL' : 'PROCURAR DISPOSITIVOS NO GRID',
                          style: const TextStyle(color: magenta, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── DISPOSITIVOS NO GRID Section ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.radar, color: magenta, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'DISPOSITIVOS NO GRID',
                    style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Text(
                isScanning ? 'SCAN: ATIVO' : 'SCAN: PRONTO',
                style: const TextStyle(color: yellow, fontSize: 7.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildFilterTab('TODOS (${scanResults.length + 1})', 0),
              const SizedBox(width: 6),
              _buildFilterTab('DECABOTS', 1),
              const SizedBox(width: 6),
              _buildFilterTab('BEACONS', 2),
            ],
          ),

          const SizedBox(height: 8),

          // Live Discovered Devices list from BLE Scan
          if (scanResults.isNotEmpty) ...[
            ...scanResults.map((r) {
              final name = r.device.platformName.isNotEmpty ? r.device.platformName : r.device.remoteId.str;
              final isTarget = name.toUpperCase().contains('SENNINHA') || name.toUpperCase().contains('ESP32');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () async {
                    _triggerHaptic();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Conectando a $name...')),
                    );
                    await _ble.connect(r.device);
                  },
                  child: _buildGridDeviceItem(
                    name: name,
                    desc: 'MAC: ${r.device.remoteId.str}\nToque para Conectar',
                    dbm: '${r.rssi} dBm',
                    icon: isTarget ? Icons.smart_toy_rounded : Icons.bluetooth,
                    statusBadge: 'CONECTAR',
                    isConnected: false,
                    isSelectable: true,
                  ),
                ),
              );
            }),
          ] else ...[
            // Default demo mock items when offline/no physical devices scanned yet
            _buildGridDeviceItem(
              name: 'SENNINHA-ESP32-C3',
              desc: 'SEU ROBÔ · SESSÃO EM ANDAMENTO',
              dbm: '-42 dBm',
              icon: Icons.sports_esports,
              statusBadge: isConnected ? 'CONECTADO' : 'CONECTAR',
              isConnected: isConnected,
            ),
            const SizedBox(height: 4),
            _buildGridDeviceItem(
              name: 'DECABOT-TURBO',
              desc: 'Equipe PB v2.1\nNível 1',
              dbm: '-69 dBm',
              icon: Icons.precision_manufacturing,
              statusBadge: 'BLOQUEADO',
            ),
            const SizedBox(height: 4),
            _buildGridDeviceItem(
              name: 'DECABOT-VELOX',
              desc: 'Equipe PB v2.0\nNível 2',
              dbm: '-74 dBm',
              icon: Icons.precision_manufacturing,
              statusBadge: 'BLOQUEADO',
            ),
            const SizedBox(height: 4),
            _buildGridDeviceItem(
              name: 'PIT-STOP-BEACON',
              desc: 'Sensor Pista PPD01 -\nVolta 01',
              dbm: '-85 dBm',
              icon: Icons.place,
              statusBadge: 'BLOQUEADO',
            ),
          ],

          const SizedBox(height: 12),

          // ── PREFERÊNCIAS BLE Section ────────────────────────────────
          Row(
            children: const [
              Icon(Icons.tune, color: yellow, size: 14),
              SizedBox(width: 6),
              Text(
                'PREFERÊNCIAS BLE',
                style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildPreferenceTile(
            title: 'Auto-Reconectar ao Senninha',
            subtitle: 'Sincroniza automaticamente ao ligar o carrinho',
            value: _autoReconnect,
            onChanged: (val) => setState(() => _autoReconnect = val),
            activeColor: magenta,
          ),

          const SizedBox(height: 6),

          _buildPreferenceTile(
            title: 'Modo Baixa Latência (Corrida)',
            subtitle: 'Taxa de amostragem agressiva (Intervalo 15ms)',
            value: _lowLatency,
            onChanged: (val) => setState(() => _lowLatency = val),
            activeColor: orange,
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: magenta, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Ajuda de Pareamento ESP32-C3',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Guia Oficial de Bancada PPDM & ITCOI',
                        style: TextStyle(color: Colors.white38, fontSize: 7.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, int index) {
    final isSelected = _selectedFilter == index;
    const Color magenta = SennaColors.magenta;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _triggerHaptic();
          setState(() => _selectedFilter = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? magenta : const Color(0xFF141730),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? magenta : Colors.white12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridDeviceItem({
    required String name,
    required String desc,
    required String dbm,
    required IconData icon,
    required String statusBadge,
    bool isConnected = false,
    bool isSelectable = false,
  }) {
    const Color yellow = SennaColors.yellow;
    const Color magenta = SennaColors.magenta;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF101328),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected
              ? magenta.withValues(alpha: 0.8)
              : (isSelectable ? yellow.withValues(alpha: 0.5) : Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isConnected
                  ? magenta.withValues(alpha: 0.2)
                  : (isSelectable ? yellow.withValues(alpha: 0.15) : Colors.white10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: isConnected ? magenta : (isSelectable ? yellow : Colors.white54),
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                    ),
                    if (isConnected) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle_outline, color: yellow, size: 10),
                    ],
                  ],
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white38, fontSize: 7),
                ),
              ],
            ),
          ),
          Text(
            dbm,
            style: const TextStyle(color: yellow, fontSize: 8, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.transparent
                  : (isSelectable ? yellow.withValues(alpha: 0.2) : Colors.white10),
              borderRadius: BorderRadius.circular(4),
              border: (isConnected || isSelectable) ? Border.all(color: isSelectable ? yellow : Colors.white24) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.lock_open : (isSelectable ? Icons.bluetooth_connected : Icons.lock),
                  color: isConnected ? Colors.white70 : (isSelectable ? yellow : Colors.white38),
                  size: 8,
                ),
                const SizedBox(width: 2),
                Text(
                  statusBadge,
                  style: TextStyle(
                    color: isConnected ? Colors.white70 : (isSelectable ? yellow : Colors.white38),
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SennaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 7),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: activeColor,
            onChanged: (val) {
              _triggerHaptic();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}

class _RadarScreenPainter extends CustomPainter {
  final double scanAngle;
  final int discoveredCount;

  _RadarScreenPainter({required this.scanAngle, this.discoveredCount = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width / 2, size.height / 2) - 10;

    final ringPaint = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3), ringPaint);
    }

    if (scanAngle > 0) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0,
          endAngle: pi / 2,
          colors: [
            const Color(0xFFFF9500).withValues(alpha: 0.0),
            const Color(0xFFFF9500).withValues(alpha: 0.35),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(scanAngle);
      canvas.drawCircle(Offset.zero, maxRadius, sweepPaint);
      canvas.restore();
    }

    // Dynamic or static blips
    _drawBlip(canvas, Offset(center.dx + 25, center.dy - 30), const Color(0xFFFF007A));
    _drawBlip(canvas, Offset(center.dx - 35, center.dy - 10), const Color(0xFFFF9500));
    _drawBlip(canvas, Offset(center.dx + 45, center.dy + 35), const Color(0xFFFFD600));
    if (discoveredCount >= 4) {
      _drawBlip(canvas, Offset(center.dx - 20, center.dy + 40), const Color(0xFFFF007A));
    }

    final centerDot = Paint()..color = const Color(0xFFFF9500);
    canvas.drawCircle(center, 6, centerDot);
  }

  void _drawBlip(Canvas canvas, Offset pos, Color color) {
    final glow = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pos, 5, glow);

    final dot = Paint()..color = color;
    canvas.drawCircle(pos, 3, dot);
  }

  @override
  bool shouldRepaint(covariant _RadarScreenPainter oldDelegate) =>
      oldDelegate.scanAngle != scanAngle || oldDelegate.discoveredCount != discoveredCount;
}
