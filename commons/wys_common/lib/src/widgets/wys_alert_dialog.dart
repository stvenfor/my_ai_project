import 'package:flutter/material.dart';

/// 通用确认弹框，对齐 Android `BaseTipsDialog`。
Future<bool?> showAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = '取消',
  String confirmText = '确定',
  bool barrierDismissible = false,
  bool confirmIsDestructive = false,
  Color? cancelColor,
  Color? confirmColor,
  double contentExtraHeight = 0,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0x80000000),
    builder: (context) => Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty) ...[
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
              ),
            ),
            SizedBox(height: 15 + contentExtraHeight),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  if (cancelText.isNotEmpty) ...[
                    Expanded(
                      child: _DialogButton(
                        text: cancelText,
                        color: cancelColor ?? const Color(0xFF333333),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                    ),
                  ],
                  Expanded(
                    child: _DialogButton(
                      text: confirmText,
                      color:
                          confirmColor ??
                          (confirmIsDestructive
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFFF39801)),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(text, style: TextStyle(color: color, fontSize: 16)),
        ),
      ),
    );
  }
}
