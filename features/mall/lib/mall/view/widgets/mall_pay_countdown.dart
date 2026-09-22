import 'dart:async';

import 'package:flutter/material.dart';
import 'package:module_mall/mall/model/mall_order.dart';
import 'package:module_mall/mall/theme/mall_theme.dart';

/// 待支付倒计时 `HH:MM:SS`；截止后回调 [onExpired]（至多一次）。
class MallPayCountdown extends StatefulWidget {
  const MallPayCountdown({
    super.key,
    required this.deadline,
    this.onExpired,
    this.style,
    this.prefix = '剩余 ',
  });

  final DateTime deadline;
  final VoidCallback? onExpired;
  final TextStyle? style;
  final String prefix;

  @override
  State<MallPayCountdown> createState() => _MallPayCountdownState();
}

class _MallPayCountdownState extends State<MallPayCountdown> {
  Timer? _timer;
  late Duration _left;
  var _expiredNotified = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant MallPayCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) {
      _expiredNotified = false;
      _tick();
    }
  }

  void _tick() {
    final left = widget.deadline.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _left = left);
    if (!left.isNegative && left > Duration.zero) return;
    if (_expiredNotified) return;
    _expiredNotified = true;
    widget.onExpired?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = '${widget.prefix}${formatPayCountdown(_left)}';
    return Text(
      text,
      style: widget.style ??
          MallTheme.caption.copyWith(
            color: MallTheme.price,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
