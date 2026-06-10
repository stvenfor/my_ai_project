import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';

class CommunityViewModel extends BaseViewModel {
  final title = '社区模块'.obs;
}

class CommunityBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<CommunityViewModel>(CommunityViewModel.new);
}
