import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/model/banner_model.dart';
import 'package:module_home/home/repository/home_repository.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;
  final banners = <BannerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshBanners();
  }

  Future<void> refreshBanners() async {
    await runAsync(() async {
      banners.value = await _repository.loadBanners();
    });
  }
}
