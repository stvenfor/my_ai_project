import 'package:flutter/material.dart';

import '../wys_app_navigator.dart';
import 'wys_base_url_sheet.dart';
import 'wys_mock_sheet.dart';
import 'wys_test_ball_policy.dart';

/// 对齐 iOS `+[TFTestBall startTest]`：右侧绿球，全 App 顶层（含登录页）。
///
/// 使用 [Stack] 叠在 [MaterialApp.builder] 的 child 之上（GetX 下 Overlay 常插不进去）。
class WysTestBall extends StatefulWidget {
  const WysTestBall({
    super.key,
    required this.child,
    this.enabled,
    this.onEnvironmentChanged,
    this.onTestFaceAuth,
    this.onTestPush,
    this.onTestVersionUpdate,
  });

  final Widget child;
  final bool? enabled;
  final void Function(String message)? onEnvironmentChanged;

  /// 调试按钮：拉起人脸识别。返回 `true` 表示成功，`false` 表示失败。
  final Future<bool> Function()? onTestFaceAuth;

  /// 调试按钮：发送一条极光推送。返回 `true` 表示成功，`false` 表示失败。
  final Future<bool> Function()? onTestPush;

  /// 调试按钮：拉起版本更新弹窗。
  final VoidCallback? onTestVersionUpdate;

  @override
  State<WysTestBall> createState() => _WysTestBallState();
}

class _WysTestBallState extends State<WysTestBall> {
  static const double _ballSize = 60;

  Offset? _offset;

  bool get _show => widget.enabled ?? WysTestBallPolicy.show;

  /// iOS: `CGRectMake(ScreenWidth-60, 200, 60, 60)`
  Offset _defaultPosition(Size size) {
    return Offset(size.width - _ballSize, 200);
  }

  Offset _clamp(Offset p, Size size) {
    final maxX = (size.width - _ballSize).clamp(0.0, double.infinity);
    final maxY = (size.height - _ballSize).clamp(0.0, double.infinity);
    return Offset(p.dx.clamp(0.0, maxX), p.dy.clamp(0.0, maxY));
  }

  Future<void> _showTools(BuildContext context) async {
    final navContext = WysAppNavigator.overlayContext ?? context;
    if (!navContext.mounted) return;
    await showDialog<void>(
      context: navContext,
      barrierDismissible: true,
      builder: (ctx) => SimpleDialog(
        title: const Text('调试工具'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              showWysBaseUrlSheet(
                navContext,
                onApplied: widget.onEnvironmentChanged,
              );
            },
            child: const Text('修改链接'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              showWysMockSheet(navContext);
            },
            child: const Text('Mock 开关'),
          ),
          if (widget.onTestFaceAuth != null)
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(ctx);
                bool ok = false;
                try {
                  ok = await widget.onTestFaceAuth!();
                } catch (_) {
                  ok = false;
                }
                if (!navContext.mounted) return;
                await _showResult(
                  navContext,
                  ok: ok,
                  successTitle: '人脸识别',
                  successMessage: '人脸识别成功',
                  failureTitle: '人脸识别',
                  failureMessage: '人脸识别失败，请重试',
                );
              },
              child: const Text('人脸识别'),
            ),
          if (widget.onTestPush != null)
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(ctx);
                bool ok = false;
                try {
                  ok = await widget.onTestPush!();
                } catch (_) {
                  ok = false;
                }
                if (!navContext.mounted) return;
                await _showResult(
                  navContext,
                  ok: ok,
                  successTitle: '极光推送',
                  successMessage: '测试推送已发送',
                  failureTitle: '极光推送',
                  failureMessage: '推送发送失败',
                );
              },
              child: const Text('极光推送'),
            ),
          if (widget.onTestVersionUpdate != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onTestVersionUpdate!();
              },
              child: const Text('版本更新弹窗'),
            ),
        ],
      ),
    );
  }

  /// 统一展示成功/失败弹窗。
  Future<void> _showResult(
    BuildContext context, {
    required bool ok,
    required String successTitle,
    required String successMessage,
    required String failureTitle,
    required String failureMessage,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ok ? successTitle : failureTitle),
        content: Text(ok ? successMessage : failureMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _ball(BuildContext context, Size size) {
    final pos = _clamp(_offset ?? _defaultPosition(size), size);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          setState(() {
            _offset = _clamp(
              (_offset ?? _defaultPosition(size)) + d.delta,
              size,
            );
          });
        },
        onTap: () => _showTools(context),
        child: Material(
          color: Colors.green,
          elevation: 8,
          shadowColor: Colors.black38,
          shape: const CircleBorder(),
          child: const SizedBox(
            width: _ballSize,
            height: _ballSize,
            child: Center(
              child: Text(
                '修改链接',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = constraints.biggest;
        if (!size.width.isFinite || size.width <= 0) {
          size = MediaQuery.sizeOf(context);
        }

        return Stack(
          alignment: Alignment.topLeft,
          textDirection: TextDirection.ltr,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: widget.child),
            if (_show) _ball(context, size),
          ],
        );
      },
    );
  }
}
