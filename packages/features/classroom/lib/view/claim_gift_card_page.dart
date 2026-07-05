import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_common_ui/module_common_ui.dart';

class ClaimGiftCardPage extends StatelessWidget {
  const ClaimGiftCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gift = ClassroomMockData.giftCard;

    return AppPageScaffold(
      backgroundColor: ClassroomColors.noteBackground,
      navBar: AppNavBar(
        title: '领取礼品卡',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: ClassroomColors.noteBackground,
        foregroundColor: ClassroomColors.titleBlack,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GiftCardVisual(gift: gift),
          const SizedBox(height: 24),
          _NotePaper(gift: gift),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                UiKitInitializer.toast('领取成功，可在背包中查看');
                Get.back<void>();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ClassroomColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                '立即领取',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftCardVisual extends StatelessWidget {
  const _GiftCardVisual({required this.gift});

  final GiftCardInfo gift;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1677FF), Color(0xFF0958D9)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🦜', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 8),
                const Text(
                  '英语趣配音',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Way to go ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gift.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        gift.cardType,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text('🧑‍🎓', style: TextStyle(fontSize: 48)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotePaper extends StatelessWidget {
  const _NotePaper({required this.gift});

  final GiftCardInfo gift;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -8,
          left: 24,
          child: Transform.rotate(
            angle: -0.3,
            child: const Icon(Icons.attach_file, size: 28, color: Color(0xFF999999)),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${gift.studentName} 同学：',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: ClassroomColors.titleBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                gift.message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: ClassroomColors.titleBlack,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      gift.teacherName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ClassroomColors.titleBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gift.date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ClassroomColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
