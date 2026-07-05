import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class MyClassListPage extends StatelessWidget {
  const MyClassListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = ClassroomMockData.classes;

    return AppPageScaffold(
      backgroundColor: ClassroomColors.background,
      navBar: AppNavBar(
        title: '我的班级',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: ClassroomColors.background,
        foregroundColor: ClassroomColors.titleBlack,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: ClassroomColors.primaryGreen, size: 20),
                const SizedBox(width: 6),
                const Text(
                  '班级',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ClassroomColors.titleBlack,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => UiKitInitializer.toast('禁用班级功能开发中'),
                  child: const Text(
                    '禁用班级',
                    style: TextStyle(
                      fontSize: 14,
                      color: ClassroomColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                return _ClassCard(classInfo: classes[index]);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => UiKitInitializer.toast('创建班级功能开发中'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClassroomColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '创建班级',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classInfo});

  final ClassInfo classInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ClassroomColors.cardWhite,
        borderRadius: BorderRadius.circular(ClassroomDimens.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classInfo.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ClassroomColors.titleBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '邀请码：${classInfo.inviteCode}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: ClassroomColors.textGray,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '班级成员：${classInfo.memberCount}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: ClassroomColors.textGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ClassroomColors.divider),
          Row(
            children: [
              _ActionButton(
                icon: Icons.person_add_outlined,
                label: '邀请同学',
                onTap: () => UiKitInitializer.toast('邀请同学功能开发中'),
              ),
              _ActionButton(
                icon: Icons.pie_chart_outline,
                label: '作业统计',
                onTap: () => Get.toNamed(
                  RoutePath.classroomHomeworkStats,
                  arguments: ClassroomRouteArgs(classId: classInfo.id),
                ),
              ),
              _ActionButton(
                icon: Icons.leaderboard_outlined,
                label: '排行榜',
                onTap: () => UiKitInitializer.toast('排行榜功能开发中'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () => Get.toNamed(RoutePath.classroomHomeworkReview),
              child: const Text(
                '作业点评 >',
                style: TextStyle(
                  fontSize: 13,
                  color: ClassroomColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: ClassroomColors.primaryGreen, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ClassroomColors.titleBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
