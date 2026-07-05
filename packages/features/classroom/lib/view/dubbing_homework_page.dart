import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';

class DubbingHomeworkPage extends StatelessWidget {
  const DubbingHomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homework = ClassroomMockData.dubbingHomework;
    final args = ClassroomRouteArgs.from(Get.arguments);

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: ClassroomColors.background,
      body: Column(
        children: [
          _GradientHeader(homework: homework),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                decoration: const BoxDecoration(
                  color: ClassroomColors.cardWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            '配音作业（${homework.items.length}）',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ClassroomColors.titleBlack,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '本次作业可享受免费评分',
                              style: TextStyle(
                                fontSize: 11,
                                color: ClassroomColors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: homework.items.length,
                        itemBuilder: (context, index) {
                          return _DubbingItemRow(
                            item: homework.items[index],
                            onTap: () => Get.toNamed(
                              RoutePath.classroomVideoDetail,
                              arguments: args?.copyWith(
                                    videoId: homework.items[index].id,
                                  ) ??
                                  ClassroomRouteArgs(
                                    videoId: homework.items[index].id,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    );
  }
}

extension on ClassroomRouteArgs {
  ClassroomRouteArgs copyWith({
    String? classId,
    String? studentId,
    String? homeworkId,
    String? videoId,
  }) {
    return ClassroomRouteArgs(
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      homeworkId: homeworkId ?? this.homeworkId,
      videoId: videoId ?? this.videoId,
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.homework});

  final DubbingHomeworkDetail homework;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ClassroomColors.primaryGreenDark,
            ClassroomColors.gradientEnd,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back<void>(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Text(
                  '${homework.studentName}的作业',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            homework.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.backpack_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                homework.className,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                '截止时间：${homework.deadline}',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            homework.description,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _DubbingItemRow extends StatelessWidget {
  const _DubbingItemRow({required this.item, required this.onTap});

  final DubbingHomeworkItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 56,
            decoration: BoxDecoration(
              color: ClassroomColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.movie, color: ClassroomColors.textGray),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ClassroomColors.titleBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.score}分',
                  style: TextStyle(
                    fontSize: 13,
                    color: item.score >= 60
                        ? ClassroomColors.primaryGreen
                        : ClassroomColors.orange,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: ClassroomColors.primaryGreen,
              side: BorderSide(
                color: item.canResubmit
                    ? ClassroomColors.primaryGreen
                    : ClassroomColors.primaryGreen,
              ),
              backgroundColor: item.canResubmit
                  ? Colors.transparent
                  : ClassroomColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              item.canResubmit ? '重新提交' : '去配音',
              style: TextStyle(
                fontSize: 13,
                color: item.canResubmit ? ClassroomColors.primaryGreen : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
