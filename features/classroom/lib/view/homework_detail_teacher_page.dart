import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/controller/classroom_controllers.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class HomeworkDetailTeacherPage extends GetView<HomeworkDetailTeacherController> {
  const HomeworkDetailTeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeworkDetailTeacherController>()) {
      HomeworkDetailTeacherBinding().dependencies();
    }

    final profile = ClassroomMockData.findStudent(controller.studentId)!;
    final items = ClassroomMockData.timelineForStudent(controller.studentId);

    return AppPageScaffold(
      backgroundColor: ClassroomColors.background,
      navBar: AppNavBar(
        title: '作业详情',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: ClassroomColors.background,
        foregroundColor: ClassroomColors.titleBlack,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('导出成绩'),
            style: TextButton.styleFrom(
              foregroundColor: ClassroomColors.primaryGreen,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ProfileCard(profile: profile),
          _StatusTabs(),
          Expanded(
            child: Obx(() {
              final tab = controller.selectedTab.value;
              final filtered = _filterItems(items, tab);
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _TimelineItem(
                    item: filtered[index],
                    isLast: index == filtered.length - 1,
                    onTap: () => Get.toNamed(
                      RoutePath.classroomHomeworkDetailStudent,
                      arguments: ClassroomRouteArgs(
                        classId: controller.classId,
                        studentId: controller.studentId,
                        homeworkId: filtered[index].id,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<HomeworkTimelineItem> _filterItems(
    List<HomeworkTimelineItem> items,
    HomeworkStatusTab tab,
  ) {
    switch (tab) {
      case HomeworkStatusTab.all:
        return items;
      case HomeworkStatusTab.completed:
        return items.where((e) => e.isCompleted).toList();
      case HomeworkStatusTab.incomplete:
        return items.where((e) => !e.isCompleted).toList();
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClassroomColors.cardWhite,
        borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: ClassroomColors.primaryGreenLight,
            child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ClassroomColors.titleBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '作业数：${profile.homeworkCount}    完成率：${profile.completionRate.toInt()}%',
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
    );
  }
}

class _StatusTabs extends GetView<HomeworkDetailTeacherController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.selectedTab.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _Tab(label: '全部', selected: tab == HomeworkStatusTab.all, onTap: () => controller.selectTab(HomeworkStatusTab.all)),
            _Tab(label: '已完成', selected: tab == HomeworkStatusTab.completed, onTap: () => controller.selectTab(HomeworkStatusTab.completed)),
            _Tab(label: '未完成', selected: tab == HomeworkStatusTab.incomplete, onTap: () => controller.selectTab(HomeworkStatusTab.incomplete)),
          ],
        ),
      );
    });
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? ClassroomColors.titleBlack : ClassroomColors.textGray,
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final HomeworkTimelineItem item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeColor = ClassroomMockData.homeworkTypeColor(item.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.dateLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ClassroomColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ClassroomColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: ClassroomColors.divider),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ClassroomColors.cardWhite,
                  borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: typeColor.withValues(alpha: 0.15),
                          child: Icon(
                            _typeIcon(item.type),
                            size: 18,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ClassroomColors.titleBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.className,
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
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Transform.rotate(
                        angle: 0.3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: ClassroomColors.stampGray),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.isCompleted ? '完成' : '未完成',
                            style: TextStyle(
                              fontSize: 10,
                              color: ClassroomColors.textGray.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(HomeworkType type) {
    switch (type) {
      case HomeworkType.dubbing:
        return Icons.mic;
      case HomeworkType.sync:
        return Icons.menu_book;
      case HomeworkType.checkin:
        return Icons.check_circle_outline;
    }
  }
}
