import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';

class ChatDetailBinding extends Bindings {
  ChatDetailBinding(this.conversation);

  final ConversationModel conversation;

  @override
  void dependencies() {
    Get.lazyPut<ChatDetailViewModel>(
      () => ChatDetailViewModel(conversation: conversation),
    );
  }
}
