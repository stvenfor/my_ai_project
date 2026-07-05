import 'package:flutter/material.dart';
import 'package:scan/scan.dart';

/// 扫码配置。
class ScanOptions {
  const ScanOptions({
    this.scanAreaScale = 0.7,
    this.scanLineColor = Colors.green,
    this.showTorchButton = true,
  });

  final double scanAreaScale;
  final Color scanLineColor;
  final bool showTorchButton;
}

/// 全屏相机扫码页，由 [ScanUtils.scanWithCamera] 打开。
class ScanPage extends StatefulWidget {
  const ScanPage({super.key, this.options = const ScanOptions()});

  final ScanOptions options;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late final ScanController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = ScanController();
  }

  @override
  void dispose() {
    _controller.pause();
    super.dispose();
  }

  void _onCapture(String data) {
    if (_handled || !mounted) return;
    _handled = true;
    _controller.pause();
    Navigator.of(context).pop<String>(data);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('扫码'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop<String>(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ScanView(
            controller: _controller,
            scanAreaScale: options.scanAreaScale,
            scanLineColor: options.scanLineColor,
            onCapture: _onCapture,
          ),
          if (options.showTorchButton)
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Center(
                child: FilledButton.icon(
                  onPressed: _controller.toggleTorchMode,
                  icon: const Icon(Icons.flashlight_on),
                  label: const Text('手电筒'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
