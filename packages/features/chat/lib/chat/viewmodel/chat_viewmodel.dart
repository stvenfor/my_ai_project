import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';
import 'package:module_chat/chat/repository/mock_chat_repository.dart';
import 'package:module_common_ui/module_common_ui.dart';

class ChatViewModel extends BaseViewModel {
  ChatViewModel({ChatRepository? repository})
      : _repository = repository ?? MockChatRepository.instance;

  final ChatRepository _repository;
  final conversations = <ConversationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    await runAsync(() async {
      conversations.assignAll(await _repository.fetchConversations());
    });
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ChatViewModel>(
        ChatViewModel.new,
        fenix: true,
      );
}
