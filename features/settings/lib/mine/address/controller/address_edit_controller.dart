import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/mine/address/api/address_api.dart';
import 'package:module_settings/mine/address/model/address_model.dart';
import 'package:module_settings/mine/address/widgets/china_region_picker.dart';
import 'package:wys_common/wys_common.dart';

class AddressEditController extends GetxController {
  AddressEditController({this.addressId, AddressApi? api})
      : _api = api ?? AddressApi();

  final int? addressId;
  final AddressApi _api;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final detailCtrl = TextEditingController();
  final labelCtrl = TextEditingController();
  final isDefault = false.obs;
  final loading = false.obs;
  final saving = false.obs;
  final regionLabel = ''.obs;

  bool get isEdit => addressId != null && addressId! > 0;

  @override
  void onInit() {
    super.onInit();
    if (isEdit) {
      _load();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    provinceCtrl.dispose();
    cityCtrl.dispose();
    districtCtrl.dispose();
    detailCtrl.dispose();
    labelCtrl.dispose();
    super.onClose();
  }

  void _syncRegionLabel() {
    final p = provinceCtrl.text.trim();
    final c = cityCtrl.text.trim();
    final d = districtCtrl.text.trim();
    regionLabel.value = [p, c, d].where((e) => e.isNotEmpty).join(' ');
  }

  Future<void> pickRegion(BuildContext context) async {
    final sel = await showChinaRegionPicker(
      context,
      initialProvince: provinceCtrl.text.trim(),
      initialCity: cityCtrl.text.trim(),
      initialDistrict: districtCtrl.text.trim(),
    );
    if (sel == null) return;
    provinceCtrl.text = sel.province;
    cityCtrl.text = sel.city;
    districtCtrl.text = sel.district;
    _syncRegionLabel();
  }

  Future<void> _load() async {
    loading.value = true;
    try {
      final list = await _api.list();
      AddressModel? hit;
      for (final e in list) {
        if (e.addressId == addressId) {
          hit = e;
          break;
        }
      }
      if (hit == null) {
        UiKitInitializer.toast('地址不存在');
        Get.back();
        return;
      }
      nameCtrl.text = hit.receiverName;
      phoneCtrl.text = hit.receiverPhone;
      provinceCtrl.text = hit.province;
      cityCtrl.text = hit.city;
      districtCtrl.text = hit.district;
      detailCtrl.text = hit.detailAddress;
      labelCtrl.text = hit.label;
      isDefault.value = hit.isDefault;
      _syncRegionLabel();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '加载失败' : e.message);
      Get.back();
    } finally {
      loading.value = false;
    }
  }

  Future<void> save() async {
    if (saving.value) return;
    final name = nameCtrl.text.trim();
    final phone = WysContactValidators.digitsOnly(phoneCtrl.text);
    final detail = detailCtrl.text.trim();
    final province = provinceCtrl.text.trim();
    final city = cityCtrl.text.trim();
    final district = districtCtrl.text.trim();
    if (!WysContactValidators.isNameValid(name)) {
      UiKitInitializer.toast(
        name.isEmpty
            ? '请填写收货人'
            : '收货人不超过 ${WysContactValidators.maxNameLength} 个字',
      );
      return;
    }
    if (!WysContactValidators.isCnMobile(phone)) {
      UiKitInitializer.toast('请输入以 1 开头的 11 位手机号');
      return;
    }
    if (detail.isEmpty) {
      UiKitInitializer.toast('请填写详细地址');
      return;
    }
    if (province.isEmpty || city.isEmpty || district.isEmpty) {
      UiKitInitializer.toast('请选择省市区');
      return;
    }
    saving.value = true;
    final body = {
      'receiver_name': name,
      'receiver_phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'detail_address': detail,
      'postal_code': '',
      'is_default': isDefault.value,
      'label': labelCtrl.text.trim(),
    };
    try {
      if (isEdit) {
        await _api.update(addressId!, body);
      } else {
        await _api.create(body);
      }
      UiKitInitializer.toast('已保存');
      Get.back();
    } on HttpRequestException catch (e) {
      UiKitInitializer.toast(e.message.isEmpty ? '保存失败' : e.message);
    } finally {
      saving.value = false;
    }
  }
}
