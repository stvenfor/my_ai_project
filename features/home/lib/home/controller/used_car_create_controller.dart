import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/model/used_car_order_models.dart';
import 'package:module_home/home/repository/transaction_repository.dart';
import 'package:module_home/home/repository/used_car_order_repository.dart';
import 'package:module_common_ui/module_common_ui.dart';

class UsedCarCreateController extends GetxController {
  UsedCarCreateController({UsedCarOrderRepository? repository})
      : _repository = repository ?? Get.find<UsedCarOrderRepository>();

  final UsedCarOrderRepository _repository;

  final customers = <UsedCarCustomer>[].obs;
  final selectedCustomer = Rxn<UsedCarCustomer>();
  final kind = 'trade_in'.obs;
  final submitting = false.obs;

  final vehicleModelCtrl = TextEditingController();
  final plateNoCtrl = TextEditingController();
  final vinCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  @override
  void onClose() {
    vehicleModelCtrl.dispose();
    plateNoCtrl.dispose();
    vinCtrl.dispose();
    mileageCtrl.dispose();
    yearCtrl.dispose();
    amountCtrl.dispose();
    super.onClose();
  }

  Future<void> loadCustomers() async {
    try {
      customers.assignAll(await _repository.fetchCustomers());
      if (customers.isNotEmpty && selectedCustomer.value == null) {
        selectedCustomer.value = customers.first;
      }
    } catch (e) {
      UiKitInitializer.toastError(formatTransactionLoadError(e));
    }
  }

  Future<bool> submit() async {
    final customer = selectedCustomer.value;
    if (customer == null) {
      UiKitInitializer.toastError('请选择客户');
      return false;
    }
    final mileage = int.tryParse(mileageCtrl.text.trim());
    final year = int.tryParse(yearCtrl.text.trim());
    final amount = double.tryParse(amountCtrl.text.trim());
    if (vehicleModelCtrl.text.trim().isEmpty ||
        plateNoCtrl.text.trim().isEmpty ||
        vinCtrl.text.trim().isEmpty ||
        mileage == null ||
        year == null ||
        amount == null ||
        amount <= 0) {
      UiKitInitializer.toastError('请完整填写车况与金额');
      return false;
    }
    submitting.value = true;
    try {
      await _repository.create(
        kind: kind.value,
        customerId: customer.customerId,
        vehicleModel: vehicleModelCtrl.text.trim(),
        plateNo: plateNoCtrl.text.trim(),
        vin: vinCtrl.text.trim(),
        mileageKm: mileage,
        modelYear: year,
        amount: amount,
      );
      UiKitInitializer.toast('提交成功');
      return true;
    } catch (e) {
      UiKitInitializer.toastError(formatTransactionLoadError(e));
      return false;
    } finally {
      submitting.value = false;
    }
  }
}
