import 'package:get/get.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';

class HomeworkStatsController extends GetxController {
  final selectedTab = HomeworkTab.all.obs;
  final selectedTimeFilter = TimeFilter.thisWeek.obs;
  final customStartDate = Rxn<DateTime>();
  final customEndDate = Rxn<DateTime>();

  String get timeFilterLabel {
    switch (selectedTimeFilter.value) {
      case TimeFilter.thisWeek:
        return '本周';
      case TimeFilter.thisMonth:
        return '本月';
      case TimeFilter.lastMonth:
        return '上个月';
      case TimeFilter.custom:
        final start = customStartDate.value;
        final end = customEndDate.value;
        if (start != null && end != null) {
          return '${start.month}/${start.day}-${end.month}/${end.day}';
        }
        return '自定义';
    }
  }

  void selectTab(HomeworkTab tab) => selectedTab.value = tab;

  void selectTimeFilter(TimeFilter filter) => selectedTimeFilter.value = filter;

  void setCustomRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    selectedTimeFilter.value = TimeFilter.custom;
  }
}

class HomeworkDetailTeacherController extends GetxController {
  final selectedTab = HomeworkStatusTab.all.obs;
  late final String studentId;
  late final String classId;

  @override
  void onInit() {
    super.onInit();
    final args = ClassroomRouteArgs.from(Get.arguments);
    studentId = args?.studentId ?? ClassroomMockData.defaultStudentId;
    classId = args?.classId ?? ClassroomMockData.defaultClassId;
  }

  void selectTab(HomeworkStatusTab tab) => selectedTab.value = tab;
}

class HomeworkReviewController extends GetxController {
  final giftCardCount = 2.obs;
  final sendGiftCard = true.obs;
  final selectedStudents = <String>[].obs;

  static const totalGiftCards = 23;
  static const studentCount = 8;

  @override
  void onInit() {
    super.onInit();
    selectedStudents.assignAll(ClassroomMockData.reviewStudents.take(4));
  }

  void incrementGiftCards() {
    if (giftCardCount.value < totalGiftCards) {
      giftCardCount.value++;
    }
  }

  void decrementGiftCards() {
    if (giftCardCount.value > 1) {
      giftCardCount.value--;
    }
  }

  void toggleSendGiftCard(bool value) => sendGiftCard.value = value;
}

class HomeworkStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomeworkStatsController.new);
  }
}

class HomeworkDetailTeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomeworkDetailTeacherController.new);
  }
}

class HomeworkReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(HomeworkReviewController.new);
  }
}
