import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 轻提示；商城等业务统一调用全局 [toast]，底层仍走 fluttertoast。
abstract final class WysToast {
  WysToast._();

  static final FToast _fToast = FToast();
  static bool _initialized = false;
  static void Function(String message)? _handler;

  static void configure(void Function(String message) handler) {
    _handler = handler;
  }

  static void init(BuildContext context) {
    _fToast.init(context);
    _initialized = true;
  }

  static Widget withToast(BuildContext context, Widget child) {
    return FToastBuilder()(
      context,
      Builder(
        builder: (toastContext) {
          init(toastContext);
          return child;
        },
      ),
    );
  }

  /// 与旧代码 `toast(msg)` 兼容：居中黑底纯文字。
  static void show(String message) {
    if (message.isEmpty) return;
    final custom = _handler;
    if (custom != null) {
      custom(message);
      return;
    }
    if (_initialized) {
      _fToast.removeQueuedCustomToasts();
      _fToast.showToast(
        child: _CenterToastContent(message: message),
        gravity: ToastGravity.CENTER,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// 底部白底带品牌图标 Toast。
  ///
  /// 对齐 Android 弹幕空输入等场景的系统 Toast（底部）观感，并补齐 App 内常见带图标样式。
  /// 不走 [_handler]，避免被默认居中逻辑覆盖。
  static void showBottom(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    if (message.isEmpty) return;
    if (_initialized) {
      _fToast.removeQueuedCustomToasts();
      _fToast.showToast(
        child: _BottomBrandToastContent(message: message),
        gravity: ToastGravity.BOTTOM,
        toastDuration: duration,
      );
      return;
    }
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.white,
      textColor: const Color(0xFF333333),
      fontSize: 14,
    );
  }
}

/// 兼容旧全局函数名。
void toast(String message) => WysToast.show(message);

class _CenterToastContent extends StatelessWidget {
  const _CenterToastContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _BottomBrandToastContent extends StatelessWidget {
  const _BottomBrandToastContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F3FF),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF2196F3),
              ),
            ),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                softWrap: true,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
