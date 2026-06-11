import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/repository/home_repository.dart';

class HomeController extends BaseViewModel {
  HomeController({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;
  final UserService _userService = Get.find<UserService>();

  final userGreeting = '早上好'.obs;
  final selectedMetricTab = 0.obs;
  final dashboard = Rxn<HomeDashboardData>();

  static const metricTabs = ['今日', '昨日', '近30天'];

  @override
  void onInit() {
    super.onInit();
    _updateGreeting(_userService.currentUser.value);
    ever(_userService.currentUser, _updateGreeting);
    refreshDashboard();
  }

  void _updateGreeting(User? user) {
    final hour = DateTime.now().hour;
    final period = hour < 12 ? '早上好' : (hour < 18 ? '下午好' : '晚上好');
    final name = user?.name ?? '访客';
    userGreeting.value = '$period，$name';
    if (user != null) refreshDashboard();
  }

  List<HomeMetric> get currentMetrics {
    final data = dashboard.value;
    if (data == null) return const [];
    return switch (selectedMetricTab.value) {
      1 => data.metricsYesterday,
      2 => data.metricsMonth,
      _ => data.metricsToday,
    };
  }

  void selectMetricTab(int index) => selectedMetricTab.value = index;

  Future<void> refreshDashboard() async {
    await runAsync(() async {
      dashboard.value = await _repository.loadDashboard();
    });
  }
}
