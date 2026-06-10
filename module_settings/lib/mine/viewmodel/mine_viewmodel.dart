import 'package:get/get.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/mine/model/level_card_model.dart';

class MineViewModel extends GetxController {
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

  void openTestPage(LevelCardModel level) {
    Get.toNamed(
      RoutePath.mineHttpTest,
      arguments: level.toArguments(),
    );
  }
}
