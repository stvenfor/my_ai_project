import 'package:get/get.dart';
import 'package:module_auth/navigation/auth_navigation.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/login_redirect.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/mine/model/mine_menu_data.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
import 'package:module_settings/mine/model/mine_profile_model.dart';
import 'package:module_settings/mine/model/mine_store_data.dart';
import 'package:module_settings/mine/repository/mine_function_repository.dart';
import 'package:module_settings/mine/repository/mine_store_repository.dart';
import 'package:module_settings/mine/widgets/switch_store_dialog.dart';
import 'package:module_utils/module_utils.dart';

class MineController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final profile = Rxn<MineProfileModel>();
  final functions = <MineFunctionItem>[].obs;
  final selectedStoreId = RxString(MineStoreData.defaultStoreId);

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
      roleBadge: '销售经理',
      storeName: MineStoreRepository.resolveStoreName(selectedStoreId.value),
      maskedPhone: _maskPhone(user.id),
      stats: MineProfileModel.demoStats,
    );
  }

  void _applyStoreToProfile() {
    final current = profile.value;
    if (current == null || !isLoggedIn) return;
    profile.value = MineProfileModel(
      displayName: current.displayName,
      avatarUrl: current.avatarUrl,
      roleBadge: current.roleBadge,
      storeName: MineStoreRepository.resolveStoreName(selectedStoreId.value),
      maskedPhone: current.maskedPhone,
      stats: current.stats,
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
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    if (redirectRoute != null) {
      LoginRedirect.setPending(redirectRoute);
    }
    await Get.toNamed(RoutePath.login);
  }

  Future<void> openShortVideo() async {
    if (!isLoggedIn) {
      await goLogin(redirectRoute: RoutePath.shortVideo);
      return;
    }
    await Get.toNamed(RoutePath.shortVideo);
  }

  Future<void> logout() async {
    await AuthSession.logout();
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    _syncUser(null);
    await Get.offAllNamed(RoutePath.login);
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
    selectedStoreId.value = picked;
    await MineStoreRepository.saveSelectedStoreId(picked);
    _applyStoreToProfile();
  }

  void onElectronicCardTap() => UiKitInitializer.toast('电子名片');

  Future<void> onAvatarTap() async {
    if (!isLoggedIn) {
      UiKitInitializer.toast('请先登录');
      return;
    }

    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;

    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
      }

      final path = await ImagePickerUtils.pickImage(source, maxWidth: 800);
      if (path == null) return;
      await _updateAvatar(path);
    } catch (_) {
      UiKitInitializer.toastError('选择图片失败');
    }
  }

  Future<void> _updateAvatar(String path) async {
    final user = _userService.currentUser.value;
    if (user == null) return;
    await _userService.setUser(user.copyWith(avatar: path));
    UiKitInitializer.toast('头像已更新');
  }

  void onQuickServiceTap(MineQuickServiceItem item) {
    UiKitInitializer.toast('${item.label} 开发中');
  }

  void onMenuTap(MineMenuItem item) {
    switch (item.id) {
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
