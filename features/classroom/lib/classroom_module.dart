import 'package:flutter/material.dart';
import 'package:module_classroom/view/claim_gift_card_page.dart';
import 'package:module_classroom/view/class_homework_stats_page.dart';
import 'package:module_classroom/view/dubbing_homework_page.dart';
import 'package:module_classroom/view/homework_detail_student_page.dart';
import 'package:module_classroom/view/homework_detail_teacher_page.dart';
import 'package:module_classroom/view/homework_review_page.dart';
import 'package:module_classroom/view/my_class_list_page.dart';
import 'package:module_classroom/view/video_detail_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class ClassroomModule extends FeatureModule {
  @override
  String get moduleId => 'classroom';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.classroomMyClass: (_) => const MyClassListPage(),
        RoutePath.classroomHomeworkStats: (_) => const ClassHomeworkStatsPage(),
        RoutePath.classroomHomeworkDetailTeacher: (_) =>
            const HomeworkDetailTeacherPage(),
        RoutePath.classroomHomeworkDetailStudent: (_) =>
            const HomeworkDetailStudentPage(),
        RoutePath.classroomDubbingHomework: (_) => const DubbingHomeworkPage(),
        RoutePath.classroomHomeworkReview: (_) => const HomeworkReviewPage(),
        RoutePath.classroomClaimGift: (_) => const ClaimGiftCardPage(),
        RoutePath.classroomVideoDetail: (_) => const VideoDetailPage(),
      };
}
