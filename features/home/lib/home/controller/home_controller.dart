import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/store/current_store_service.dart';
import 'package:module_auth/store/switch_store_dialog.dart';
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
  CurrentStoreService get _store => Get.find<CurrentStoreService>();

  final userGreeting = '早上好'.obs;
  final selectedMetricTab = 0.obs;
  final dashboard = Rxn<HomeDashboardData>();
  final displayStoreName = ''.obs;

  static const metricTabs = ['今日', '昨日', '近30天'];

  @override
  void onInit() {
    super.onInit();
    _updateGreeting(_userService.currentUser.value);
    ever(_userService.currentUser, _updateGreeting);
    if (Get.isRegistered<EnvironmentService>()) {
      ever(Get.find<EnvironmentService>().currentEnv, (_) => refreshDashboard());
    }
    everAll([_store.storeId, _store.storeName], (_) => _syncStoreName());
    _loadInitial();
  }

  void _syncStoreName() {
    final name = _store.storeName.value;
    if (name.isNotEmpty) {
      displayStoreName.value = name;
      return;
    }
    displayStoreName.value = dashboard.value?.storeName ?? '';
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

  /// 错误页重试（走首次加载流程，含全局 Loading）。
  Future<void> retryInitialLoad() => _loadInitial();

  /// 首次进入：全局 Loading（BotToast 遮罩）。
  Future<void> _loadInitial() async {
    await _loading.run(
      () async {
        errorMessage.value = null;
        try {
          await _ensureStores();
          dashboard.value = await _repository.loadDashboard(
            storeName: _store.storeName.value,
          );
          _syncStoreName();
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
      await _ensureStores();
      dashboard.value = await _repository.loadDashboard(
        storeName: _store.storeName.value,
      );
      _syncStoreName();
    });
  }

  Future<void> _ensureStores() async {
    if (!AuthSession.isLoggedIn) return;
    if (_store.stores.isNotEmpty && _store.storeName.value.isNotEmpty) return;
    try {
      await _store.refreshStores();
    } catch (_) {
      // 列表失败时仍展示本地缓存店名。
    }
  }

  Future<void> onStoreTap() async {
    if (!AuthSession.isLoggedIn) {
      UiKitInitializer.toast('请先登录');
      return;
    }
    if (_store.stores.isEmpty) {
      try {
        await _store.refreshStores();
      } catch (_) {}
    }
    if (_store.stores.isEmpty) {
      UiKitInitializer.toast('暂无可切换店铺');
      return;
    }
    final picked = await SwitchStoreDialog.show(
      selectedId: _store.storeId.value,
      stores: _store.stores.toList(),
    );
    if (picked == null || picked == _store.storeId.value) return;
    try {
      await _store.switchTo(picked);
      _syncStoreName();
    } catch (_) {
      UiKitInitializer.toast('切换店铺失败');
    }
  }
}
