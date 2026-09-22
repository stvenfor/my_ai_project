import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 社区公约：同一自然日最多弹一次（纯客户端）。
abstract final class CommunityConventionDialog {
  static const prefsKey = 'community_convention_ack_date';

  static String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 若当日未确认过，则展示公约弹窗；点「我知道了」后写入当天日期。
  static Future<void> maybeShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    if (prefs.getString(prefsKey) == today) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('社区公约'),
          content: const SingleChildScrollView(
            child: Text(
              '欢迎来到社区。请文明发言，尊重他人，不传播违法违规内容。'
              '发布内容请真实友善；违规内容将被处理。',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setString(prefsKey, today);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('我知道了'),
            ),
          ],
        );
      },
    );
  }
}
