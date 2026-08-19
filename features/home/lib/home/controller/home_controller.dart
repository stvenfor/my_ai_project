import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_home/home/model/home_dashboard_model.dart';
import 'package:module_home/home/repository/home_repository.dart';

class HomeController extends BaseViewModel {
  HomeController({
    HomeRepository? repository,
    AppLoading? loading,
  })  : _repository = repository ?? HomeRepository(),
        _loading = loading ?? Get.find<AppLoading>();

  final HomeRepository _repository;
  final AppLoading _loading;
  final UserService _userService = Get.find<UserService>();

  final userGreeting = '早上好'.obs;
  final selectedMetricTab = 0.obs;
  final selectedTopTab = 0.obs;
  final dashboard = Rxn<HomeDashboardData>();

  static const topTabs = ['首页', '视频', 'Club'];
  static const metricTabs = ['今日', '昨日', '近30天'];

  @override
  void onInit() {
    super.onInit();
    _updateGreeting(_userService.currentUser.value);
    ever(_userService.currentUser, _updateGreeting);
    if (Get.isRegistered<EnvironmentService>()) {
      ever(Get.find<EnvironmentService>().currentEnv, (_) => refreshDashboard());
    }
    _loadInitial();
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

  void selectTopTab(int index) => selectedTopTab.value = index;

  /// 错误页重试（走首次加载流程，含全局 Loading）。
  Future<void> retryInitialLoad() => _loadInitial();

  /// 首次进入：全局 Loading（BotToast 遮罩）。
  Future<void> _loadInitial() async {
    await _loading.run(
      () async {
        errorMessage.value = null;
        try {
          dashboard.value = await _repository.loadDashboard();
        } catch (error) {
          errorMessage.value = error.toString();
        }
      },
      message: '加载中',
    );
  }

  /// 下拉刷新 / 环境切换 / 用户变更：仅 EasyRefresh 动画，不弹全局 Loading。
  Future<void> refreshDashboard() async {
    await runAsync(() async {
      dashboard.value = await _repository.loadDashboard();
    });
  }
}
