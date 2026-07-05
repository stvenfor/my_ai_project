import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class HomeworkDetailStudentPage extends StatelessWidget {
  const HomeworkDetailStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ClassroomRouteArgs.from(Get.arguments);
    final student = ClassroomMockData.findStudent(args?.studentId)!;
    final tasks = ClassroomMockData.studentHomeworkTasks;
    const progress = 0.74;
    const completedCount = 32;

    return AppPageScaffold(
      backgroundColor: ClassroomColors.background,
      navBar: AppNavBar(
        title: '作业详情',
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
            child: ElevatedButton.icon(
              onPressed: () => UiKitInitializer.toast('分享到班级群'),
              icon: const Icon(Icons.share, size: 18),
              label: const Text('分享到班级群'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ClassroomColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UserCard(student: student),
          const SizedBox(height: 12),
          _ProgressCard(progress: progress),
          const SizedBox(height: 8),
          _SocialProofRow(completedCount: completedCount),
          const SizedBox(height: 12),
          _ContentCard(tasks: tasks, args: args),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.student});

  final StudentProfile student;

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
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ClassroomColors.primaryGreenLight,
                child: Text(student.avatarEmoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ClassroomColors.titleBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ClassroomColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '这里老师没写的话默认会有一句话',
              style: TextStyle(fontSize: 13, color: ClassroomColors.textGray),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClassroomColors.cardWhite,
        borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '作业进度',
                style: TextStyle(fontSize: 14, color: ClassroomColors.titleBlack),
              ),
              Text(
                '已完成 ${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: ClassroomColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: ClassroomColors.divider,
                  valueColor: const AlwaysStoppedAnimation(ClassroomColors.primaryGreen),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * progress * 0.75,
                top: -6,
                child: const Text('🐦', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialProofRow extends StatelessWidget {
  const _SocialProofRow({required this.completedCount});

  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ClassroomColors.cardWhite,
        borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 24,
            child: Stack(
              children: List.generate(3, (i) {
                return Positioned(
                  left: i * 16.0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: ClassroomColors.primaryGreenLight,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 10)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '已有$completedCount人完成作业',
              style: const TextStyle(fontSize: 13, color: ClassroomColors.textGray),
            ),
          ),
          const Icon(Icons.chevron_right, color: ClassroomColors.textGrayLight),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.tasks, required this.args});

  final List<HomeworkTaskItem> tasks;
  final ClassroomRouteArgs? args;

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
            'Unit 3 Part A: Let\'s talk & Let\'s learn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ClassroomColors.titleBlack,
            ),
          ),
          const SizedBox(height: 12),
          ...tasks.map((t) => _TaskRow(task: t)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ClassroomColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '谭老师：本次作业完成的很棒！送你 1 张体验卡，以资鼓励。',
                  style: TextStyle(fontSize: 13, color: ClassroomColors.titleBlack),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Get.toNamed(RoutePath.classroomClaimGift),
                  child: const Text(
                    '点击领取',
                    style: TextStyle(
                      fontSize: 13,
                      color: ClassroomColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.toNamed(
              RoutePath.classroomDubbingHomework,
              arguments: args,
            ),
            child: const Text(
              '查看配音作业 >',
              style: TextStyle(
                fontSize: 13,
                color: ClassroomColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final HomeworkTaskItem task;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ClassroomColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: task.iconColor.withValues(alpha: 0.15),
            child: Text(
              task.iconLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: task.iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ClassroomColors.titleBlack,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${task.starReward}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: ClassroomColors.orange,
                      ),
                    ),
                    const Text(' ⭐', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Text(
                  task.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ClassroomColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
