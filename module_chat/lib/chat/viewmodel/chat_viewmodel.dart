import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';

class ChatViewModel extends BaseViewModel {
  final title = '聊天模块'.obs;
}

class ChatBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ChatViewModel>(ChatViewModel.new);
}
