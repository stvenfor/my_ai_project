import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_home/home/model/banner_model.dart';
import 'package:module_home/home/repository/home_repository.dart';

class HomeController extends BaseViewModel {
  HomeController({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;
  final UserService _userService = Get.find<UserService>();

  final banners = <BannerModel>[].obs;
  final userGreeting = '加载中...'.obs;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting(_userService.currentUser.value);
    ever(_userService.currentUser, _updateGreeting);
    refreshBanners();
  }

  void _updateGreeting(User? user) {
    userGreeting.value =
        user != null ? '你好，${user.name}' : '未登录，请先登录';
    if (user != null) {
      refreshBanners();
    }
  }

  Future<void> refreshBanners() async {
    await runAsync(() async {
      banners.value = await _repository.loadBanners();
    });
  }
}
