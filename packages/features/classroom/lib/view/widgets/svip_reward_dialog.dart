import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_route/route/route_path.dart';

/// SVIP 卡领取弹窗。
class SvipRewardDialog extends StatelessWidget {
  const SvipRewardDialog({
    super.key,
    this.cardCount = 5,
  });

  final int cardCount;

  static Future<void> show(BuildContext context, {int cardCount = 5}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => SvipRewardDialog(cardCount: cardCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: ClassroomColors.titleBlack,
                    ),
                    children: [
                      const TextSpan(text: '恭喜获得 '),
                      TextSpan(
                        text: '$cardCount张',
                        style: const TextStyle(
                          color: ClassroomColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' SVIP卡'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '会员卡领取成功后可在背包中查看',
                  style: TextStyle(fontSize: 13, color: ClassroomColors.textGray),
                ),
                const SizedBox(height: 16),
                _MiniGiftCard(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.toNamed<void>(RoutePath.classroomClaimGift);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ClassroomColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '立即领取',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text(
                    '查看礼品卡规则 >',
                    style: TextStyle(fontSize: 13, color: ClassroomColors.textGray),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGiftCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1677FF), Color(0xFF0958D9)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🦜', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('英语趣配音', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Center(
            child: Text(
              'Way to go ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1天 AI SVIP', style: TextStyle(color: Colors.white, fontSize: 12)),
                  SizedBox(height: 2),
                  Text('体验会员卡', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
              const Spacer(),
              const Text('🧑‍🎓', style: TextStyle(fontSize: 36)),
            ],
          ),
        ],
      ),
    );
  }
}
