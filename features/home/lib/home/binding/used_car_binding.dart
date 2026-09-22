import 'package:get/get.dart';
import 'package:module_home/home/api/transaction_api.dart';
import 'package:module_home/home/api/used_car_order_api.dart';
import 'package:module_home/home/controller/ledger_detail_controller.dart';
import 'package:module_home/home/controller/ledger_list_controller.dart';
import 'package:module_home/home/controller/used_car_create_controller.dart';
import 'package:module_home/home/controller/used_car_detail_controller.dart';
import 'package:module_home/home/controller/used_car_list_controller.dart';
import 'package:module_home/home/repository/transaction_repository.dart';
import 'package:module_home/home/repository/used_car_order_repository.dart';

class UsedCarListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsedCarOrderApi>()) {
      Get.lazyPut(UsedCarOrderApi.new, fenix: true);
    }
    if (!Get.isRegistered<UsedCarOrderRepository>()) {
      Get.lazyPut(UsedCarOrderRepository.new, fenix: true);
    }
    Get.lazyPut<UsedCarListController>(UsedCarListController.new, fenix: true);
  }
}

class UsedCarDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsedCarOrderApi>()) {
      Get.lazyPut(UsedCarOrderApi.new, fenix: true);
    }
    if (!Get.isRegistered<UsedCarOrderRepository>()) {
      Get.lazyPut(UsedCarOrderRepository.new, fenix: true);
    }
    Get.lazyPut<UsedCarDetailController>(UsedCarDetailController.new);
  }
}

class UsedCarCreateBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsedCarOrderApi>()) {
      Get.lazyPut(UsedCarOrderApi.new, fenix: true);
    }
    if (!Get.isRegistered<UsedCarOrderRepository>()) {
      Get.lazyPut(UsedCarOrderRepository.new, fenix: true);
    }
    Get.lazyPut<UsedCarCreateController>(UsedCarCreateController.new);
  }
}

class LedgerListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TransactionApi>()) {
      Get.lazyPut(TransactionApi.new, fenix: true);
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut(TransactionRepository.new, fenix: true);
    }
    Get.lazyPut<LedgerListController>(LedgerListController.new, fenix: true);
  }
}

class LedgerDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TransactionApi>()) {
      Get.lazyPut(TransactionApi.new, fenix: true);
    }
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut(TransactionRepository.new, fenix: true);
    }
    Get.lazyPut<LedgerDetailController>(LedgerDetailController.new);
  }
}
