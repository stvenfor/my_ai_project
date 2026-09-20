import 'package:get/get.dart';
import 'package:module_ai/ai/controller/ai_stream_controller.dart';

class AiStreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiStreamController>(AiStreamController.new, fenix: true);
  }
}
