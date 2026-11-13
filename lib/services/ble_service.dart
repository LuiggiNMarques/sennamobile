import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum BleConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
}

/// Service to handle Bluetooth Low Energy (BLE) scanning, connection,
/// and bidirectional communication with the ESP32-C3 Senninha Bot.
class BleService extends ChangeNotifier {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal() {
    _initAdapterListener();
  }

  // ── UUIDs matching the Senninha design (Nordic UART standard) ────────
  static final Guid serviceUuid =
      Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid rxCharUuid =
      Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E'); // Write
  static final Guid txCharUuid =
      Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E'); // Notify

  // ── State variables ──────────────────────────────────────────────────
  BleConnectionStatus _status = BleConnectionStatus.disconnected;
  BleConnectionStatus get status => _status;
  bool get isConnected => _status == BleConnectionStatus.connected;
  bool get isScanning => _status == BleConnectionStatus.scanning;

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;

  List<ScanResult> _scanResults = [];
  List<ScanResult> get scanResults => _scanResults;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  StreamSubscription<List<int>>? _telemetrySub;

  // ── Live Telemetry Data parsed from ESP32-C3 ────────────────────────
  double batteryVoltage = 8.4;
  int batteryPercent = 85;
  int motorsRpm = 6400;
  int motorL = 420;
  int motorR = 419;
  double chipTemp = 34.0;
  int latencyMs = 12;
  int rssi = -42;
  String robotName = 'SENNINHA-BOT #01';
  String macAddress = '48:27:E2:D9:A1:C0';

  void _initAdapterListener() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on && isConnected) {
        _handleDisconnect();
      }
    });
  }

  /// Request runtime permissions for Android 12+ (BLUETOOTH_SCAN, CONNECT)
  /// and Location for older versions.
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true; // Desktop / Web fallback
    }

    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? true;
      final connGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? true;

      return scanGranted && connGranted;
    } catch (e) {
      debugPrint('[BLE] Permission request error: $e');
      return false;
    }
  }

  /// Start scanning for nearby BLE devices (especially ESP32-C3)
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    await requestPermissions();

    try {
      _scanResults.clear();
      _status = BleConnectionStatus.scanning;
      notifyListeners();

      _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        notifyListeners();
      });

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      // When scan finishes
      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
      if (_status == BleConnectionStatus.scanning) {
        _status = BleConnectionStatus.disconnected;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[BLE] Scan error: $e');
      _status = BleConnectionStatus.disconnected;
      notifyListeners();
    }
  }

  /// Stop active scan
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _scanSub?.cancel();
      if (_status == BleConnectionStatus.scanning) {
        _status = BleConnectionStatus.disconnected;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[BLE] Stop scan error: $e');
    }
  }

  /// Connect to an ESP32-C3 Bluetooth device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await stopScan();

      _status = BleConnectionStatus.connecting;
      notifyListeners();

      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;
      robotName = device.platformName.isNotEmpty ? device.platformName : 'SENNINHA-BOT #01';
      macAddress = device.remoteId.str;

      // Listen to connection state
      _connStateSub?.cancel();
      _connStateSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnect();
        }
      });

      // Request higher MTU for fast telemetry throughput
      if (Platform.isAndroid) {
        try {
          await device.requestMtu(512);
        } catch (_) {}
      }

      // Discover GATT Services
      final services = await device.discoverServices();
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.write || char.properties.writeWithoutResponse) {
            _rxCharacteristic ??= char;
          }
          if (char.properties.notify || char.properties.indicate) {
            _txCharacteristic ??= char;
            await _subscribeToTelemetry(char);
          }
        }
      }

      _status = BleConnectionStatus.connected;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[BLE] Connect error: $e');
      _handleDisconnect();
      return false;
    }
  }

  /// Subscribe to telemetry notifications from ESP32-C3 TX characteristic
  Future<void> _subscribeToTelemetry(BluetoothCharacteristic txChar) async {
    try {
      await txChar.setNotifyValue(true);
      _telemetrySub?.cancel();
      _telemetrySub = txChar.lastValueStream.listen((data) {
        if (data.isEmpty) return;
        try {
          final text = utf8.decode(data).trim();
          _parseTelemetryData(text);
        } catch (e) {
          debugPrint('[BLE] Telemetry decode error: $e');
        }
      });
    } catch (e) {
      debugPrint('[BLE] Notify subscription error: $e');
    }
  }

  /// Parse telemetry string from ESP32. Example: "RPM:6400;BAT:7.62;TEMP:34.2;L:420;R:419;MS:12"
  void _parseTelemetryData(String raw) {
    try {
      final parts = raw.split(';');
      for (final part in parts) {
        final kv = part.split(':');
        if (kv.length == 2) {
          final key = kv[0].toUpperCase().trim();
          final val = kv[1].trim();
          switch (key) {
            case 'RPM':
              motorsRpm = int.tryParse(val) ?? motorsRpm;
              break;
            case 'BAT':
              batteryVoltage = double.tryParse(val) ?? batteryVoltage;
              batteryPercent = ((batteryVoltage - 6.6) / (8.4 - 6.6) * 100).clamp(0, 100).toInt();
              break;
            case 'TEMP':
              chipTemp = double.tryParse(val) ?? chipTemp;
              break;
            case 'L':
              motorL = int.tryParse(val) ?? motorL;
              break;
            case 'R':
              motorR = int.tryParse(val) ?? motorR;
              break;
            case 'MS':
              latencyMs = int.tryParse(val) ?? latencyMs;
              break;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[BLE] Telemetry parse error: $e');
    }
  }

  /// Disconnect from ESP32-C3
  Future<void> disconnect() async {
    try {
      await _connectedDevice?.disconnect();
    } catch (e) {
      debugPrint('[BLE] Disconnect error: $e');
    } finally {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _telemetrySub?.cancel();
    _connStateSub?.cancel();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _status = BleConnectionStatus.disconnected;
    notifyListeners();
  }

  // ── Send Control Commands to ESP32-C3 ────────────────────────────────

  /// Send string command to ESP32-C3 (e.g. "FRENTE:100", "STOP", "HONK:1")
  Future<void> sendCommand(String command) async {
    if (!isConnected || _rxCharacteristic == null) {
      debugPrint('[BLE Mock/Offline] Sent command: $command');
      return;
    }

    try {
      final bytes = utf8.encode('$command\n');
      await _rxCharacteristic!.write(
        bytes,
        withoutResponse: _rxCharacteristic!.properties.writeWithoutResponse,
      );
    } catch (e) {
      debugPrint('[BLE] Error sending command "$command": $e');
    }
  }

  /// Send directional drive command
  void drive({required String direction, required int speedPercent}) {
    sendCommand('DRIVE:$direction:$speedPercent');
  }

  /// Send continuous joystick command
  void sendJoystick({required double angle, required double force, required double throttle}) {
    sendCommand('JOY:${angle.toInt()}:${force.toInt()}:${(throttle * 100).toInt()}');
  }

  /// Emergency stop
  void emergencyStop() {
    sendCommand('STOP');
  }

  /// Honk horn
  void setBuzzer(bool on) {
    sendCommand('BUZZER:${on ? 1 : 0}');
  }

  /// Set drive power mode: 0=ECO, 1=PISTA, 2=SENNA
  void setPowerMode(int mode) {
    final modeName = mode == 0 ? 'ECO' : (mode == 1 ? 'PISTA' : 'SENNA');
    sendCommand('MODE:$modeName');
  }

  /// Set headlight on/off
  void setFarol(bool on) {
    sendCommand('LIGHT:${on ? 1 : 0}');
  }

  /// Set steering trim calibration
  void setTrim(double trim) {
    sendCommand('TRIM:${trim.toStringAsFixed(1)}');
  }

  /// Envia expressão do rostinho para o display OLED do ESP32-C3
  void sendFace(String faceName) {
    sendCommand('FACE:$faceName');
  }
}

