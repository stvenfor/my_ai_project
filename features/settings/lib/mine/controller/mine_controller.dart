import 'package:get/get.dart';
import 'package:module_auth/navigation/auth_navigation.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:wys_router/src/route/route_path.dart';
import 'package:module_settings/mine/actions/mine_avatar_actions.dart';
import 'package:module_settings/mine/model/mine_menu_data.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
import 'package:module_settings/mine/model/mine_profile_model.dart';
import 'package:module_settings/mine/model/mine_store_data.dart';
import 'package:module_settings/mine/model/mine_stat_model.dart';
import 'package:module_settings/mine/repository/mine_function_repository.dart';
import 'package:module_settings/mine/repository/mine_repository.dart';
import 'package:module_settings/mine/repository/mine_store_repository.dart';
import 'package:module_settings/mine/widgets/switch_store_dialog.dart';

class MineController extends GetxController {
  MineController({MineRepository? repository})
      : _repository = repository ?? MineRepository();

  final UserService _userService = Get.find<UserService>();
  final MineRepository _repository;

  final profile = Rxn<MineProfileModel>();
  final functions = <MineFunctionItem>[].obs;
  final selectedStoreId = RxString(MineStoreData.defaultStoreId);
  List<MineStatModel>? _lastStats;
  String? _lastRoleLabel;

  static const _defaultAvatar =
      'https://picsum.photos/seed/mine_profile/200/200';

  @override
  void onInit() {
    super.onInit();
    selectedStoreId.value = MineStoreRepository.loadSelectedStoreId();
    _loadFunctions();
    _syncUser(_userService.currentUser.value);
    ever(_userService.currentUser, _syncUser);
  }

  Future<void> _loadFunctions() async {
    functions.assignAll(await MineFunctionRepository.loadFunctions());
  }

  Future<void> reorderFunction(int fromIndex, int toIndex) async {
    if (fromIndex == toIndex) return;
    final item = functions.removeAt(fromIndex);
    functions.insert(toIndex, item);
    await MineFunctionRepository.saveFunctions(functions);
  }

  void _syncUser(User? user) {
    if (user == null) {
      _lastStats = null;
      _lastRoleLabel = null;
      profile.value = const MineProfileModel(
        displayName: '访客',
        avatarUrl: null,
        roleBadge: '未登录',
        storeName: '登录后查看门店信息',
        maskedPhone: '— — —',
        stats: MineProfileModel.guestStats,
      );
      return;
    }

    profile.value = MineProfileModel(
      displayName: user.name.isNotEmpty ? user.name : '东东枪',
      avatarUrl: user.avatar.isNotEmpty ? user.avatar : _defaultAvatar,
      roleBadge: _lastRoleLabel ?? '销售顾问',
      storeName: MineStoreRepository.resolveStoreName(selectedStoreId.value),
      maskedPhone: user.phoneMasked.isNotEmpty
          ? user.phoneMasked
          : _maskPhone(user.id),
      stats: _lastStats ?? MineProfileModel.guestStats,
    );
    _refreshStats();
  }

  Future<void> _refreshStats() async {
    if (!isLoggedIn) return;
    final storeId = selectedStoreId.value;
    try {
      final store = await _repository.loadStoreStats(storeId: storeId);
      if (!isLoggedIn || selectedStoreId.value != storeId) return;
      _lastStats = MineRepository.statsToMineModels(store);
      _lastRoleLabel = store.roleLabel;
      if (store.storeId > 0) {
        selectedStoreId.value = '${store.storeId}';
      }
      _applyStats(
        _lastStats!,
        roleLabel: _lastRoleLabel,
        storeName: store.storeName,
      );
    } catch (_) {
      // 保持上次成功值或全 0，不回退 demo。
    }
  }

  void _applyStats(
    List<MineStatModel> stats, {
    String? roleLabel,
    String? storeName,
  }) {
    final current = profile.value;
    if (current == null || !isLoggedIn) return;
    final name = (storeName != null && storeName.isNotEmpty)
        ? storeName
        : current.storeName;
    profile.value = MineProfileModel(
      displayName: current.displayName,
      avatarUrl: current.avatarUrl,
      roleBadge: roleLabel ?? _lastRoleLabel ?? current.roleBadge,
      storeName: name,
      maskedPhone: current.maskedPhone,
      stats: stats,
    );
  }

  String _maskPhone(String seed) {
    if (seed.length >= 4) {
      return '138****${seed.substring(seed.length - 4).padLeft(4, '0')}';
    }
    return '138****5678';
  }

  void openSettings() => Get.toNamed(RoutePath.settings);

  Future<void> goLogin({String? redirectRoute}) async {
    await AuthNavigation.openLogin(redirectRoute: redirectRoute);
  }

  Future<void> openShortVideo() async {
    if (!isLoggedIn) {
      await goLogin(redirectRoute: RoutePath.shortVideo);
      return;
    }
    await Get.toNamed(RoutePath.shortVideo);
  }

  Future<void> openProfile() async {
    if (!isLoggedIn) {
      await goLogin(redirectRoute: RoutePath.mineProfile);
      return;
    }
    await Get.toNamed(RoutePath.mineProfile);
  }

  Future<void> logout() async {
    try {
      await AuthSession.logout();
    } on AuthFailure catch (error) {
      UiKitInitializer.toast(error.message);
      return;
    } catch (error) {
      UiKitInitializer.toast(
        error is AuthFailure ? error.message : '登出失败，请稍后重试',
      );
      return;
    }
    _syncUser(null);
    await AuthNavigation.resetToLogin();
  }

  bool get isLoggedIn => AuthSession.isLoggedIn;

  void onInfoTap() => Get.toNamed(RoutePath.personalizedSettings);

  void onCalendarTap() => UiKitInitializer.toast('签到日历');

  Future<void> onStoreTap() async {
    if (!isLoggedIn) {
      UiKitInitializer.toast('请先登录');
      return;
    }
    final picked = await SwitchStoreDialog.show(
      selectedId: selectedStoreId.value,
    );
    if (picked == null || picked == selectedStoreId.value) return;
    final storeId = int.tryParse(picked);
    if (storeId == null || storeId <= 0) {
      UiKitInitializer.toast('店铺编号无效');
      return;
    }
    final previous = selectedStoreId.value;
    try {
      final store = await _repository.switchStore(storeId: storeId);
      selectedStoreId.value = '${store.storeId}';
      await MineStoreRepository.saveSelectedStoreId(selectedStoreId.value);
      _lastStats = MineRepository.statsToMineModels(store);
      _lastRoleLabel = store.roleLabel;
      _applyStats(
        _lastStats!,
        roleLabel: store.roleLabel,
        storeName: store.storeName,
      );
    } catch (error) {
      selectedStoreId.value = previous;
      UiKitInitializer.toast('切换店铺失败');
    }
  }

  void onElectronicCardTap() => UiKitInitializer.toast('电子名片');

  Future<void> onAvatarTap() async {
    if (!isLoggedIn) {
      await goLogin();
      return;
    }
    // 选图并 PATCH 后 UserService.setUser → ever → 我的页头像刷新
    await MineAvatarActions.pickAndUpload();
  }

  void onQuickServiceTap(MineQuickServiceItem item) {
    switch (item.id) {
      case 'mall':
        if (isLoggedIn) {
          Get.toNamed(RoutePath.mall);
        } else {
          AuthNavigation.openLogin(redirectRoute: RoutePath.mall);
        }
      case 'wallet':
      case 'order':
        UiKitInitializer.toast('${item.label} 开发中');
      default:
        UiKitInitializer.toast('${item.label} 开发中');
    }
  }

  void onMenuTap(MineMenuItem item) {
    switch (item.id) {
      case 'address':
        if (isLoggedIn) {
          Get.toNamed(RoutePath.mineAddresses);
        } else {
          AuthNavigation.openLogin(redirectRoute: RoutePath.mineAddresses);
        }
      case 'settings':
        openSettings();
      case 'feedback':
        UiKitInitializer.toast('意见反馈');
      case 'fan_group':
        UiKitInitializer.toast('粉丝群');
      case 'invite':
        UiKitInitializer.toast('邀请好友');
      case 'reminder':
        UiKitInitializer.toast('提醒事项');
      case 'cooperation':
        UiKitInitializer.toast('商务合作');
      default:
        UiKitInitializer.toast('${item.label} 开发中');
    }
  }

  void onFunctionTap(MineFunctionItem item) {
    if (item.id == 'qa') {
      Get.toNamed(RoutePath.mineHttpTest);
      return;
    }
    if (item.id == 'short_video') {
      openShortVideo();
      return;
    }
    if (item.id == 'used_car') {
      if (isLoggedIn) {
        Get.toNamed(RoutePath.homeUsedCarList);
      } else {
        AuthNavigation.openLogin(redirectRoute: RoutePath.homeUsedCarList);
      }
      return;
    }
    UiKitInitializer.toast('${item.title} 开发中');
  }
}
