import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wys_router/src/route/route_path.dart';

/// 社区公约摘要弹窗：视觉对齐示例图；同一自然日最多弹一次（纯客户端）。
abstract final class CommunityConventionDialog {
  static const prefsKey = 'community_convention_ack_date';

  static const _titleColor = Color(0xFF1A1A1A);
  static const _bodyColor = Color(0xFF333333);
  static const _linkColor = Color(0xFF1677FF);
  static const _btnColor = Color(0xFF1677FF);

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
      barrierColor: const Color(0x99000000),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '社区公约',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _titleColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                const _ConventionCopy(),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(RoutePath.communityConvention),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '点击了解完整社区公约',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: _linkColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _btnColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      await prefs.setString(prefsKey, today);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      '我知道了',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

/// 与示例图一致的正文（三条原则标题加粗）。
class _ConventionCopy extends StatelessWidget {
  const _ConventionCopy();

  static const _body = TextStyle(
    fontSize: 14,
    height: 1.65,
    color: CommunityConventionDialog._bodyColor,
  );
  static const _bold = TextStyle(
    fontSize: 14,
    height: 1.65,
    fontWeight: FontWeight.w600,
    color: CommunityConventionDialog._titleColor,
  );

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          style: _body,
          children: [
            TextSpan(text: '亲爱的用户，您好：\n\n'),
            TextSpan(
              text:
                  '欢迎来到支付宝理财社区-盘友圈，我们希望打造一个友善、有趣、有料的理财社区。\n\n'
                  '为了更好的体验，期待大家都能做到：\n',
            ),
            TextSpan(text: '尊重他人', style: _bold),
            TextSpan(text: '：请勿侵权和恶意行为；\n'),
            TextSpan(text: '尊重事实', style: _bold),
            TextSpan(text: '：请勿传播不良价值观、营销广告；\n'),
            TextSpan(text: '尊重平台', style: _bold),
            TextSpan(text: '：请勿发布违反法律法规、金融法规的内容。\n\n'),
            TextSpan(text: '一个友善温暖的理财社区，需要大家一起来守护，感谢～'),
          ],
        ),
      ),
    );
  }
}
