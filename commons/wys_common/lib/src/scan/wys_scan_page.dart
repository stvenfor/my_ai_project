import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/wys_nav_bar.dart';
import 'wys_scan_config.dart';
import 'wys_scan_line.dart';

/// 通用全屏扫码页，基于 [mobile_scanner]。
///
/// UI / 交互对齐旧 Flutter [BarcodeScan]：
/// - 粉色扫描框 + 上下往复扫描线
/// - 右上角闪光灯 Material Icons，点击切换 Torch
/// - 标题「扫一扫」与框下提示文案
class WysScanPage extends StatefulWidget {
  const WysScanPage({super.key, this.config = const WysScanConfig()});

  final WysScanConfig config;

  @override
  State<WysScanPage> createState() => _WysScanPageState();
}

class _WysScanPageState extends State<WysScanPage> {
  late final MobileScannerController _controller;
  bool _flashOn = false;
  bool _captured = false;

  WysScanConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_captured) return;
    final value = capture.barcodes
        .map((b) => b.rawValue?.trim() ?? '')
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (value.isEmpty) return;

    _captured = true;
    if (_config.autoPopOnCapture) {
      Navigator.maybePop(context, value);
      return;
    }
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    try {
      await _controller.toggleTorch();
      if (!mounted) return;
      // 对齐旧 BarcodeScan：点击即翻转本地状态
      setState(() => _flashOn = !_flashOn);
    } catch (_) {
      // OHOS / 部分机型可能不支持 Torch，保持图标可点、不崩溃。
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = _config.resolveScanWindow(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            scanWindow: scanWindow,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '相机启动失败：${error.errorCode.name}\n请确认已授权相机，并重新编译安装',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            },
          ),
          // 蒙层 + 角标（对齐 ScanOverlayShape）
          CustomPaint(
            painter: _ScanOverlayPainter(
              scanWindow: scanWindow,
              borderColor: _config.borderColor,
              overlayColor: _config.overlayColor,
            ),
            child: const SizedBox.expand(),
          ),
          // 扫描线动画（对齐旧 ScanLine）
          Positioned(
            left: scanWindow.left,
            top: scanWindow.top,
            width: scanWindow.width,
            height: scanWindow.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: WysScanLine(color: _config.scanLineColor),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WysNavBar(
              title: _config.title,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              includeTopSafeArea: true,
              showBackButton: true,
              trailingWidth: 56,
              titleStyle: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              onBack: () => Navigator.maybePop(context),
              trailing: _config.showFlashButton
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: Icon(
                        _flashOn
                            ? _config.flashOnIcon
                            : _config.flashOffIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _toggleFlash,
                    )
                  : null,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: scanWindow.bottom + 16,
            child: Text(
              _config.hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({
    required this.scanWindow,
    required this.borderColor,
    required this.overlayColor,
  });

  final Rect scanWindow;
  final Color borderColor;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = overlayColor;
    final full = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, const Radius.circular(10)),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, cutout),
      overlayPaint,
    );

    // 四角 L 形描边（对齐 ScanOverlayShape 观感）
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    const cornerLen = 28.0;
    final l = scanWindow.left;
    final t = scanWindow.top;
    final r = scanWindow.right;
    final b = scanWindow.bottom;

    canvas.drawLine(Offset(l, t), Offset(l + cornerLen, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l, t + cornerLen), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r - cornerLen, t), cornerPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLen), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLen, b), cornerPaint);
    canvas.drawLine(Offset(l, b), Offset(l, b - cornerLen), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r - cornerLen, b), cornerPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.overlayColor != overlayColor;
  }
}
