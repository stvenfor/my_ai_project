import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/controller/classroom_controllers.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_classroom/view/widgets/custom_time_range_sheet.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class ClassHomeworkStatsPage extends GetView<HomeworkStatsController> {
  const ClassHomeworkStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeworkStatsController>()) {
      HomeworkStatsBinding().dependencies();
    }

    final args = ClassroomRouteArgs.from(Get.arguments);
    final classId = args?.classId ?? ClassroomMockData.defaultClassId;
    final summary = ClassroomMockData.statSummary;
    final students = ClassroomMockData.students;

    return AppPageScaffold(
      backgroundColor: ClassroomColors.background,
      navBar: AppNavBar(
        title: '我的班级',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: ClassroomColors.background,
        foregroundColor: ClassroomColors.titleBlack,
        actions: [
          TextButton.icon(
            onPressed: () => UiKitInitializer.toast('导出成绩功能开发中'),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text('导出成绩'),
            style: TextButton.styleFrom(
              foregroundColor: ClassroomColors.primaryGreen,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainTabs(),
          _buildTimeFilters(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatsCard(summary: summary),
                const SizedBox(height: 12),
                _StudentListCard(
                  students: students,
                  classId: classId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabs() {
    return Obx(() {
      final tab = controller.selectedTab.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            _TabChip(
              label: '全部',
              selected: tab == HomeworkTab.all,
              onTap: () => controller.selectTab(HomeworkTab.all),
            ),
            _TabChip(
              label: '配音作业',
              selected: tab == HomeworkTab.dubbing,
              onTap: () => controller.selectTab(HomeworkTab.dubbing),
            ),
            _TabChip(
              label: '同步作业',
              selected: tab == HomeworkTab.sync,
              onTap: () => controller.selectTab(HomeworkTab.sync),
            ),
            const Spacer(),
            Obx(() {
              final label = controller.timeFilterLabel;
              return Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: ClassroomColors.textGray,
                ),
              );
            }),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: ClassroomColors.textGray),
          ],
        ),
      );
    });
  }

  Widget _buildTimeFilters(BuildContext context) {
    return Obx(() {
      final filter = controller.selectedTimeFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _TimePill(
              label: '本周',
              selected: filter == TimeFilter.thisWeek,
              onTap: () => controller.selectTimeFilter(TimeFilter.thisWeek),
            ),
            _TimePill(
              label: '本月',
              selected: filter == TimeFilter.thisMonth,
              onTap: () => controller.selectTimeFilter(TimeFilter.thisMonth),
            ),
            _TimePill(
              label: '上个月',
              selected: filter == TimeFilter.lastMonth,
              onTap: () => controller.selectTimeFilter(TimeFilter.lastMonth),
            ),
            _TimePill(
              label: '自定义',
              selected: filter == TimeFilter.custom,
              onTap: () => _showCustomTimeSheet(context),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showCustomTimeSheet(BuildContext context) async {
    final result = await showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomTimeRangeSheet(
        initialStart: controller.customStartDate.value ??
            DateTime(2026, 5, 15),
        initialEnd: controller.customEndDate.value ?? DateTime(2026, 5, 18),
      ),
    );
    if (result != null) {
      controller.setCustomRange(result.$1, result.$2);
    }
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? ClassroomColors.primaryGreen : Colors.transparent,
              width: 2,
            ),
          ),
        ),
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

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ClassroomColors.primaryGreenLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? ClassroomColors.primaryGreen : ClassroomColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? ClassroomColors.primaryGreen : ClassroomColors.textGray,
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.summary});

  final HomeworkStatSummary summary;

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
            children: [
              _StatItem(value: '${summary.totalCount}', label: '作业数'),
              _StatDivider(),
              _StatItem(value: '${summary.avgCompletion}', label: '人均完成'),
              _StatDivider(),
              _StatItem(
                value: '${summary.classCompletionRate.toInt()}%',
                label: '班级完成率',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                '作业类型',
                style: TextStyle(fontSize: 13, color: ClassroomColors.textGray),
              ),
              const SizedBox(width: 8),
              _TypeTag(
                label: '配音作业 ${summary.typeCounts[HomeworkType.dubbing]}',
              ),
              const SizedBox(width: 6),
              _TypeTag(
                label: '同步作业 ${summary.typeCounts[HomeworkType.sync]}',
              ),
              const SizedBox(width: 6),
              _TypeTag(
                label: '打卡作业 ${summary.typeCounts[HomeworkType.checkin]}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ClassroomColors.titleBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: ClassroomColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: ClassroomColors.divider,
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ClassroomColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: ClassroomColors.textGray),
      ),
    );
  }
}

class _StudentListCard extends StatelessWidget {
  const _StudentListCard({
    required this.students,
    required this.classId,
  });

  final List<StudentHomeworkRow> students;
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ClassroomColors.cardWhite,
        borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '姓名',
                    style: TextStyle(
                      fontSize: 13,
                      color: ClassroomColors.textGray,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '已完成',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: ClassroomColors.textGray,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '待完成',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: ClassroomColors.textGray,
                    ),
                  ),
                ),
                SizedBox(width: 24),
              ],
            ),
          ),
          ...students.map((s) => _StudentRow(student: s, classId: classId)),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student, required this.classId});

  final StudentHomeworkRow student;
  final String classId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(
        RoutePath.classroomHomeworkDetailTeacher,
        arguments: ClassroomRouteArgs(
          classId: classId,
          studentId: student.id,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                student.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: ClassroomColors.titleBlack,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${student.completed}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: ClassroomColors.titleBlack,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${student.pending}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: ClassroomColors.titleBlack,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: ClassroomColors.textGrayLight,
            ),
          ],
        ),
      ),
    );
  }
}
