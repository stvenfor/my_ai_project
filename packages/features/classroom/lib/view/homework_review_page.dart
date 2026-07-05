import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/controller/classroom_controllers.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_classroom/view/widgets/svip_reward_dialog.dart';
import 'package:module_common_ui/module_common_ui.dart';

class HomeworkReviewPage extends GetView<HomeworkReviewController> {
  const HomeworkReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeworkReviewController>()) {
      HomeworkReviewBinding().dependencies();
    }

    return AppPageScaffold(
      backgroundColor: ClassroomColors.background,
      navBar: AppNavBar(
        title: '作业点评',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: ClassroomColors.background,
        foregroundColor: ClassroomColors.titleBlack,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _onSend(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ClassroomColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                '发送',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StudentTags(),
          const SizedBox(height: 12),
          _FeedbackCard(),
          const SizedBox(height: 12),
          _GiftCardSection(),
        ],
      ),
    );
  }

  Future<void> _onSend(BuildContext context) async {
    UiKitInitializer.toast('点评已发送');
    if (controller.sendGiftCard.value) {
      await SvipRewardDialog.show(context, cardCount: controller.giftCardCount.value);
    } else {
      Get.back<void>();
    }
  }
}

class _StudentTags extends GetView<HomeworkReviewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final students = controller.selectedStudents.toList();
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ClassroomColors.cardWhite,
          borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: students
                .map(
                  (name) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ClassroomColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 13, color: ClassroomColors.titleBlack),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    });
  }
}

class _FeedbackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClassroomColors.cardWhite,
        borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '作业完成的非常好，交作业时间也及时，一整个好评好评再好评，希望再接再厉，再创辉煌',
            style: TextStyle(fontSize: 14, height: 1.5, color: ClassroomColors.titleBlack),
          ),
          const SizedBox(height: 16),
          _AudioRow(duration: "03'22\""),
          const SizedBox(height: 8),
          _AudioRow(duration: "03'22\""),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionChip(icon: Icons.mic, label: '语音评语'),
              const SizedBox(width: 24),
              _ActionChip(icon: Icons.send_outlined, label: '评语模版'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.play_circle_fill, color: ClassroomColors.primaryGreen, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.4,
              minHeight: 6,
              backgroundColor: ClassroomColors.divider,
              valueColor: const AlwaysStoppedAnimation(ClassroomColors.primaryGreen),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(duration, style: const TextStyle(fontSize: 12, color: ClassroomColors.textGray)),
        const SizedBox(width: 8),
        const Icon(Icons.delete_outline, size: 18, color: ClassroomColors.textGray),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ClassroomColors.textGray),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: ClassroomColors.textGray)),
      ],
    );
  }
}

class _GiftCardSection extends GetView<HomeworkReviewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sendGift = controller.sendGiftCard.value;
      final count = controller.giftCardCount.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ClassroomColors.cardWhite,
          borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: sendGift,
                  onChanged: (v) => controller.toggleSendGiftCard(v ?? false),
                  activeColor: ClassroomColors.primaryGreen,
                ),
                Text(
                  '送礼品卡 (${HomeworkReviewController.totalGiftCards})',
                  style: const TextStyle(fontSize: 14, color: ClassroomColors.titleBlack),
                ),
                const Spacer(),
                _StepperButton(
                  icon: Icons.remove,
                  onTap: controller.decrementGiftCards,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$count',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: controller.incrementGiftCards,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                '+$count 即为以上${HomeworkReviewController.studentCount}名同学各送${count}张',
                style: const TextStyle(fontSize: 12, color: ClassroomColors.textGray),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: ClassroomColors.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: ClassroomColors.textGray),
      ),
    );
  }
}
