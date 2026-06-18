import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:module_bluetooth/ble/ble_permission_helper.dart';

enum BleUiState { idle, scanning, connecting, connected, error }

/// BLE 扫描 / 连接控制器（示例页专用）。
class BleConnectionController extends GetxController {
  final adapterState = BluetoothAdapterState.unknown.obs;
  final uiState = BleUiState.idle.obs;
  final scanResults = <ScanResult>[].obs;
  final connectedDevice = Rxn<BluetoothDevice>();
  final discoveredServices = <BluetoothService>[].obs;
  final statusMessage = ''.obs;

  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  bool get isScanning => uiState.value == BleUiState.scanning;
  bool get isConnected => uiState.value == BleUiState.connected;

  @override
  void onInit() {
    super.onInit();
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      adapterState.value = state;
    });
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      scanResults.assignAll(results);
    });
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
    if (isScanning) return;

    final granted = await BlePermissionHelper.ensureGranted();
    if (!granted) {
      uiState.value = BleUiState.error;
      statusMessage.value = '蓝牙或定位权限未授予';
      return;
    }

    if (adapterState.value != BluetoothAdapterState.on) {
      uiState.value = BleUiState.error;
      statusMessage.value = '请先打开手机蓝牙';
      return;
    }

    try {
      uiState.value = BleUiState.scanning;
      statusMessage.value = '正在扫描附近设备…';
      scanResults.clear();
      await FlutterBluePlus.startScan(timeout: timeout);
      await Future<void>.delayed(timeout);
      await FlutterBluePlus.stopScan();
      uiState.value = BleUiState.idle;
      statusMessage.value = '扫描完成，共 ${scanResults.length} 台设备';
    } catch (e) {
      uiState.value = BleUiState.error;
      statusMessage.value = '扫描失败: $e';
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    if (uiState.value == BleUiState.scanning) {
      uiState.value = BleUiState.idle;
      statusMessage.value = '已停止扫描';
    }
  }

  Future<void> connect(ScanResult result) async {
    final device = result.device;
    if (connectedDevice.value?.remoteId == device.remoteId &&
        uiState.value == BleUiState.connected) {
      return;
    }

    final granted = await BlePermissionHelper.ensureGranted();
    if (!granted) {
      uiState.value = BleUiState.error;
      statusMessage.value = '蓝牙权限未授予';
      return;
    }

    await stopScan();
    await _connSub?.cancel();
    _connSub = null;

    try {
      uiState.value = BleUiState.connecting;
      statusMessage.value = '正在连接 ${device.platformName.isNotEmpty ? device.platformName : device.remoteId.str}…';

      await device.connect(
        license: License.nonprofit,
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );

      _connSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      final services = await device.discoverServices();
      connectedDevice.value = device;
      discoveredServices.assignAll(services);
      uiState.value = BleUiState.connected;
      statusMessage.value = '已连接，发现 ${services.length} 个服务';
    } catch (e) {
      uiState.value = BleUiState.error;
      statusMessage.value = '连接失败: $e';
      await device.disconnect().catchError((_) {});
    }
  }

  Future<void> disconnect() async {
    final device = connectedDevice.value;
    if (device == null) return;
    try {
      await device.disconnect();
    } catch (e) {
      statusMessage.value = '断开失败: $e';
    } finally {
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    connectedDevice.value = null;
    discoveredServices.clear();
    if (uiState.value != BleUiState.scanning) {
      uiState.value = BleUiState.idle;
    }
    statusMessage.value = '已断开连接';
  }

  @override
  void onClose() {
    _adapterSub?.cancel();
    _scanSub?.cancel();
    _connSub?.cancel();
    FlutterBluePlus.stopScan();
    connectedDevice.value?.disconnect().catchError((_) {});
    super.onClose();
  }
}
