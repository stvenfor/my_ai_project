import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/mine/address/api/address_api.dart';
import 'package:module_settings/mine/address/model/address_model.dart';
import 'package:wys_common/wys_common.dart';
import 'package:wys_router/src/route/route_path.dart';

class AddressListController extends GetxController {
  AddressListController({AddressApi? api, this.chooseMode = false})
      : _api = api ?? AddressApi();

  final AddressApi _api;
  final bool chooseMode;

  final items = <AddressModel>[].obs;
  final loading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (chooseMode) {
      WysAddressChooseBridge.beginChoose();
    }
    load();
  }

  @override
  void onClose() {
    if (chooseMode && WysAddressChooseBridge.isAwaitingChoose) {
      WysAddressChooseBridge.cancelChoose();
    }
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = '';
    try {
      items.assignAll(await _api.list());
    } on HttpRequestException catch (e) {
      errorMessage.value = e.message.isEmpty ? '加载失败' : e.message;
      items.clear();
    } catch (_) {
      errorMessage.value = '加载失败';
      items.clear();
    } finally {
      loading.value = false;
    }
  }

  Future<void> openEdit({AddressModel? item}) async {
    await Get.toNamed(
      RoutePath.mineAddressEdit,
      arguments: item?.addressId,
    );
    await load();
  }

  Future<void> onTap(AddressModel item) async {
    if (chooseMode) {
      WysAddressChooseBridge.completeChoose(item.toBridgeJson());
      Get.back();
      return;
    }
    await openEdit(item: item);
  }

  Future<void> setDefault(AddressModel item) async {
    try {
      await _api.setDefault(item.addressId);
      await load();
      UiKitInitializer.toast('已设为默认');
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '设置失败' : e.message);
    }
  }

  Future<void> delete(AddressModel item) async {
    try {
      await _api.delete(item.addressId);
      await load();
      UiKitInitializer.toast('已删除');
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '删除失败' : e.message);
    }
  }
}
