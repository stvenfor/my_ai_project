import 'package:get/get.dart';
import 'package:module_home/home/api/transaction_api.dart';
import 'package:module_home/home/controller/used_car_detail_controller.dart';
import 'package:module_home/home/controller/used_car_list_controller.dart';
import 'package:module_home/home/repository/transaction_repository.dart';

class UsedCarListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TransactionApi>()) {
      Get.lazyPut(TransactionApi.new, fenix: true);
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut(TransactionRepository.new, fenix: true);
    }
    Get.lazyPut<UsedCarListController>(UsedCarListController.new, fenix: true);
  }
}

class UsedCarDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TransactionApi>()) {
      Get.lazyPut(TransactionApi.new, fenix: true);
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut(TransactionRepository.new, fenix: true);
    }
    Get.lazyPut<UsedCarDetailController>(UsedCarDetailController.new);
  }
}
