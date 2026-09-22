import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// 社区公约：参考弹窗视觉；同一自然日最多弹一次（纯客户端）。
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
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '社区公约',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '欢迎来到社区。为维护友善、合法的交流环境，请遵守：\n\n'
                  '尊重他人：不侵权、不恶意攻击；\n'
                  '尊重事实：不传播不良价值观、不发营销广告；\n'
                  '尊重平台：不发布违法违规或违反金融法规的内容。',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF4D4D4D),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => UiKitInitializer.toast('完整社区公约页开发中'),
                    child: const Text(
                      '点击了解完整社区公约',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1677FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1677FF),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      await prefs.setString(prefsKey, today);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      '我知道了',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
