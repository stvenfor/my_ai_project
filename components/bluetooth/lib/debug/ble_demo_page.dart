import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:module_bluetooth/ble/ble_connection_controller.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// 蓝牙 BLE 连接示例页。
class BleDemoPage extends StatefulWidget {
  const BleDemoPage({super.key});

  @override
  State<BleDemoPage> createState() => _BleDemoPageState();
}

class _BleDemoPageState extends State<BleDemoPage> {
  late final BleConnectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(BleConnectionController());
  }

  @override
  void dispose() {
    Get.delete<BleConnectionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '蓝牙连接示例', showBackButton: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusPanel(controller: _controller),
          _ActionBar(controller: _controller),
          const Divider(height: 1),
          Expanded(child: _DeviceList(controller: _controller)),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.controller});

  final BleConnectionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('适配器: ${_adapterLabel(controller.adapterState.value)}'),
            const SizedBox(height: 4),
            Text('状态: ${_uiLabel(controller.uiState.value)}'),
            if (controller.statusMessage.value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                controller.statusMessage.value,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
            if (controller.isConnected) ...[
              const SizedBox(height: 8),
              Text(
                '已连接: ${controller.connectedDevice.value?.platformName.isNotEmpty == true ? controller.connectedDevice.value!.platformName : controller.connectedDevice.value?.remoteId.str}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('服务数: ${controller.discoveredServices.length}'),
            ],
          ],
        ),
      ),
    );
  }

  String _adapterLabel(BluetoothAdapterState state) => switch (state) {
        BluetoothAdapterState.on => '蓝牙已开启',
        BluetoothAdapterState.off => '蓝牙已关闭',
        BluetoothAdapterState.turningOn => '蓝牙开启中',
        BluetoothAdapterState.turningOff => '蓝牙关闭中',
        BluetoothAdapterState.unauthorized => '未授权',
        BluetoothAdapterState.unavailable => '不可用',
        _ => '未知',
      };

  String _uiLabel(BleUiState state) => switch (state) {
        BleUiState.idle => '空闲',
        BleUiState.scanning => '扫描中',
        BleUiState.connecting => '连接中',
        BleUiState.connected => '已连接',
        BleUiState.error => '异常',
      };
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.controller});

  final BleConnectionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: controller.isScanning ? null : controller.startScan,
                icon: controller.isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(controller.isScanning ? '扫描中…' : '扫描设备'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: controller.isConnected ? controller.disconnect : controller.stopScan,
              child: Text(controller.isConnected ? '断开' : '停止'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.controller});

  final BleConnectionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.scanResults.isEmpty) {
          return Center(
            child: Text(
              controller.isScanning ? '正在搜索 BLE 设备…' : '点击「扫描设备」开始',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.scanResults.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final result = controller.scanResults[index];
            final device = result.device;
            final name = device.platformName.isNotEmpty
                ? device.platformName
                : result.advertisementData.advName.isNotEmpty
                    ? result.advertisementData.advName
                    : '未命名设备';
            final connected = controller.connectedDevice.value?.remoteId == device.remoteId &&
                controller.isConnected;

            return ListTile(
              leading: Icon(
                connected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: connected ? Colors.blue : null,
              ),
              title: Text(name),
              subtitle: Text('${device.remoteId.str} · RSSI ${result.rssi} dBm'),
              trailing: connected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : TextButton(
                      onPressed: controller.uiState.value == BleUiState.connecting
                          ? null
                          : () => controller.connect(result),
                      child: const Text('连接'),
                    ),
              onTap: connected
                  ? null
                  : controller.uiState.value == BleUiState.connecting
                      ? null
                      : () => controller.connect(result),
            );
          },
        );
      },
    );
  }
}
