import 'dart:math';

import 'package:flutter/material.dart';

import '../wys_toast.dart';

/// 本地图形验证码弹窗，对齐 Android `CheckCodeDialog` / `CodeUtils`。
class WysCheckCodeDialog extends StatefulWidget {
  const WysCheckCodeDialog({super.key});

  @override
  State<WysCheckCodeDialog> createState() => _WysCheckCodeDialogState();
}

class _WysCheckCodeDialogState extends State<WysCheckCodeDialog> {
  final _inputController = TextEditingController();
  late String _code;
  var _canConfirm = false;
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    _code = _generateCode();
    _inputController.addListener(_syncConfirmState);
  }

  @override
  void dispose() {
    _inputController.removeListener(_syncConfirmState);
    _inputController.dispose();
    super.dispose();
  }

  void _syncConfirmState() {
    final canConfirm = _inputController.text.isNotEmpty;
    if (canConfirm != _canConfirm) {
      setState(() => _canConfirm = canConfirm);
    }
  }

  String _generateCode() {
    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      List.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _refreshCode() => setState(() => _code = _generateCode());

  void _submit() {
    if (!_canConfirm) return;
    if (_inputController.text.toLowerCase() == _code.toLowerCase()) {
      Navigator.of(context).pop(true);
      return;
    }
    // Android 输错后保留当前验证码和输入，只提示错误。
    WysToast.show('验证码错误');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '请输入图形验证码',
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 18, right: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEEEE)),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        hintText: '请输入图形中的验证码',
                        hintStyle: TextStyle(
                          color: Color(0xFFC8C9CE),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _refreshCode,
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: 92,
                        height: 42,
                        child: CustomPaint(
                          painter: _AndroidCaptchaPainter(_code),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final opacity = !_canConfirm ? 0.38 : (_pressed ? 0.5 : 1.0);
    return Semantics(
      button: true,
      enabled: _canConfirm,
      child: GestureDetector(
        onTap: _canConfirm ? _submit : null,
        onTapDown: _canConfirm ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _canConfirm ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _canConfirm
            ? () => setState(() => _pressed = false)
            : null,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: double.infinity,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: const Color(0xFFFF7272),
            ),
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AndroidCaptchaPainter extends CustomPainter {
  _AndroidCaptchaPainter(this.code) : random = Random(code.hashCode);

  final String code;
  final Random random;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEEEEEE),
    );

    var left = 0.0;
    for (final char in code.characters) {
      left += 10 + random.nextDouble() * 15;
      final decoration = random.nextBool()
          ? (random.nextBool()
                ? TextDecoration.underline
                : TextDecoration.lineThrough)
          : TextDecoration.none;
      final painter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            color: _randomColor(),
            fontSize: 27,
            fontWeight: random.nextBool() ? FontWeight.bold : FontWeight.normal,
            fontStyle: random.nextBool() ? FontStyle.italic : FontStyle.normal,
            decoration: decoration,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(left - painter.width / 2, 30 - painter.height / 2),
      );
    }

    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        Paint()
          ..color = _randomColor()
          ..strokeWidth = 1,
      );
    }
  }

  Color _randomColor() => Color.fromARGB(
    255,
    random.nextInt(0xEE),
    random.nextInt(0xEE),
    random.nextInt(0xEE),
  );

  @override
  bool shouldRepaint(covariant _AndroidCaptchaPainter oldDelegate) =>
      oldDelegate.code != code;
}
