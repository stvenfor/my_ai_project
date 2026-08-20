import 'package:flutter/material.dart';

/// 对齐旧 `scan` 包 [ScanLine]：扫描框内上下往复的渐变扫描线。
class WysScanLine extends StatefulWidget {
  const WysScanLine({
    super.key,
    this.color = const Color.fromARGB(255, 255, 20, 147),
  });

  final Color color;

  @override
  State<WysScanLine> createState() => _WysScanLineState();
}

class _WysScanLineState extends State<WysScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              widget.color.withAlpha(0x00),
              widget.color.withAlpha(0x94),
              widget.color,
              widget.color.withAlpha(0x94),
              widget.color.withAlpha(0x00),
            ],
          ),
        ),
      ),
    );
  }
}
