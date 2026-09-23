import 'package:get/get.dart';
import 'package:module_home/after_sales/viewmodel/after_sales_list_viewmodel.dart';

class AfterSalesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(AfterSalesListViewModel.new);
  }
}
