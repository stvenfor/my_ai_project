import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/mine/model/level_card_model.dart';

class MineController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final displayName = '访客'.obs;
  final avatarUrl = RxnString();
  final userId = RxnString();

  final levels = const [
    LevelCardModel(
      level: 1,
      title: 'Level 1 Starter',
      collected: 60,
      total: 120,
      collecting: true,
      locked: false,
    ),
    LevelCardModel(
      level: 2,
      title: 'Level 2 Mover',
      collected: 0,
      total: 120,
      locked: true,
    ),
    LevelCardModel(
      level: 3,
      title: 'Level 3 Flyer',
      collected: 0,
      total: 120,
      locked: true,
    ),
    LevelCardModel(
      level: 4,
      title: 'Level 4 Explorer',
      collected: 0,
      total: 120,
      locked: true,
    ),
    LevelCardModel(
      level: 5,
      title: 'Level 5 Pionter',
      collected: 0,
      total: 120,
      locked: true,
    ),
    LevelCardModel(
      level: 6,
      title: 'Level 6 Master',
      collected: 0,
      total: 120,
      locked: true,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _syncUser(_userService.currentUser.value);
    ever(_userService.currentUser, _syncUser);
  }

  void _syncUser(User? user) {
    if (user == null) {
      displayName.value = '访客';
      avatarUrl.value = null;
      userId.value = null;
      return;
    }
    displayName.value = user.name;
    avatarUrl.value = user.avatar;
    userId.value = user.id;
    _refreshLevelsForUser(user);
  }

  void _refreshLevelsForUser(User user) {
    // 用户切换时刷新业务数据（示例：按用户 id 区分展示）
    levels.refresh();
  }

  void openTestPage(LevelCardModel level) {
    Get.toNamed(
      RoutePath.mineHttpTest,
      arguments: level.toArguments(),
    );
  }
}
