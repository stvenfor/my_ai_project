import 'package:get/get.dart';
import 'package:module_home/new_car_follow/viewmodel/new_car_follow_list_viewmodel.dart';

class NewCarFollowListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(NewCarFollowListViewModel.new);
  }
}
