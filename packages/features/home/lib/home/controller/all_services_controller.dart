import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/model/all_services_data.dart';
import 'package:module_home/home/model/all_services_model.dart';
import 'package:module_home/home/repository/all_services_repository.dart';

class AllServicesController extends GetxController {
  final isEditing = false.obs;
  final favoriteItems = <AllServiceItem>[].obs;

  Set<String> get favoriteIds => favoriteItems.map((item) => item.id).toSet();

  bool get canRemoveFavorite =>
      favoriteItems.length > AllServicesData.minFavoriteCount;

  bool get canAddFavorite =>
      favoriteItems.length < AllServicesData.maxFavoriteCount;

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    favoriteItems.assignAll(await AllServicesRepository.loadFavoriteItems());
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  Future<void> removeFavorite(String id) async {
    if (!canRemoveFavorite) {
      UiKitInitializer.toast(
        '常用服务至少保留${AllServicesData.minFavoriteCount}个',
      );
      return;
    }
    favoriteItems.removeWhere((item) => item.id == id);
    await AllServicesRepository.saveFavoriteItems(favoriteItems);
  }

  Future<void> addFavorite(String id) async {
    if (!canAddFavorite) {
      UiKitInitializer.toast(
        '常用服务最多添加${AllServicesData.maxFavoriteCount}个',
      );
      return;
    }
    if (isFavorite(id)) return;
    final item = AllServicesData.findItemById(id);
    if (item == null) return;
    favoriteItems.add(item);
    await AllServicesRepository.saveFavoriteItems(favoriteItems);
  }
}

class AllServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AllServicesController.new);
  }
}
