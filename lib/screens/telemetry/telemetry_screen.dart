import 'package:flutter/material.dart';
import 'telemetry_info_screen.dart';
import 'ble_radar_screen.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  int _currentTab = 0; // 0 = Info/Tempo Real, 1 = Radar BLE

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IndexedStack(
        index: _currentTab,
        children: [
          TelemetryInfoScreen(
            onNavigateToRadar: () => setState(() => _currentTab = 1),
          ),
          BleRadarScreen(
            onBackToInfo: () => setState(() => _currentTab = 0),
          ),
        ],
      ),
    );
  }
}

