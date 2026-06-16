import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/login_redirect.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
import 'package:module_settings/mine/model/mine_profile_model.dart';

class MineController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final profile = Rxn<MineProfileModel>();
  final functions = <MineFunctionItem>[].obs;

  static const _defaultAvatar =
      'https://picsum.photos/seed/mine_profile/200/200';

  @override
  void onInit() {
    super.onInit();
    _initFunctions();
    _syncUser(_userService.currentUser.value);
    ever(_userService.currentUser, _syncUser);
  }

  void _initFunctions() {
    functions.assignAll(const [
      MineFunctionItem(
        id: 'sms',
        title: '短信模板',
        subtitle: '一键发送 轻松快捷',
        accentColor: Color(0xFFE8F8EF),
        iconColor: Color(0xFF52C41A),
        icon: Icons.sms_outlined,
      ),
      MineFunctionItem(
        id: 'calculator',
        title: '购车计算器',
        subtitle: '全款/贷款/保险全能算',
        accentColor: Color(0xFFE8F0FF),
        iconColor: Color(0xFF1890FF),
        icon: Icons.calculate_outlined,
      ),
      MineFunctionItem(
        id: 'used_car',
        title: '二手车',
        subtitle: '置换/专卖/估价',
        accentColor: Color(0xFFE8F0FF),
        iconColor: Color(0xFF1890FF),
        icon: Icons.directions_car_outlined,
      ),
      MineFunctionItem(
        id: 'short_video',
        title: '小视频',
        subtitle: '用小视频秀车秀店',
        accentColor: Color(0xFFF0E8FF),
        iconColor: Color(0xFF9254DE),
        icon: Icons.play_circle_outline,
      ),
      MineFunctionItem(
        id: 'after_sales',
        title: '售后专区',
        subtitle: '售后维修保养记录',
        accentColor: Color(0xFFFFF8E8),
        iconColor: Color(0xFFFAAD14),
        icon: Icons.build_outlined,
      ),
      MineFunctionItem(
        id: 'qr_pay',
        title: '店铺收款码',
        subtitle: '常见问题 功能介绍',
        accentColor: Color(0xFFE8F8EF),
        iconColor: Color(0xFF52C41A),
        icon: Icons.qr_code_2_outlined,
      ),
      MineFunctionItem(
        id: 'qa',
        title: '选买问答',
        subtitle: '在线解答客户问题',
        accentColor: Color(0xFFE8F0FF),
        iconColor: Color(0xFF1890FF),
        icon: Icons.support_agent_outlined,
      ),
      MineFunctionItem(
        id: 'poster',
        title: '商家海报',
        subtitle: '置换/专卖/估价',
        accentColor: Color(0xFFFFF8E8),
        iconColor: Color(0xFFFAAD14),
        icon: Icons.bar_chart_outlined,
      ),
    ]);
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
      storeName: '[4S] 北京沃德龙鼎吉利',
      maskedPhone: _maskPhone(user.id),
      stats: MineProfileModel.demoStats,
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

  void onInfoTap() => UiKitInitializer.toast('关于我们');

  void onCalendarTap() => UiKitInitializer.toast('签到日历');

  void onStoreTap() => UiKitInitializer.toast('切换门店');

  void onElectronicCardTap() => UiKitInitializer.toast('电子名片');

  void onFunctionTap(MineFunctionItem item) {
    if (item.id == 'qa') {
      Get.toNamed(RoutePath.mineHttpTest);
      return;
    }
    if (item.id == 'short_video') {
      openShortVideo();
      return;
    }
    UiKitInitializer.toast('${item.title} 开发中');
  }

  void onFunctionLongPress(MineFunctionItem item) {
    UiKitInitializer.toast('长按拖动排序（开发中）');
  }
}
