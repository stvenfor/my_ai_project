import 'dart:async';

import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';
import 'package:module_chat/chat/repository/im_chat_repository.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/model/im/im_session_state.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_core/service/im_user_profile_service.dart';
import 'package:module_rongcloud_im/im_initializer.dart';

class ChatViewModel extends BaseViewModel {
  ChatViewModel({
    ChatRepository? repository,
    ImSessionService? sessionService,
  })  : _repository = repository ?? resolveChatRepository(),
        _session = sessionService ??
            (Get.isRegistered<ImSessionService>() ? Get.find<ImSessionService>() : null);

  final ChatRepository _repository;
  final ImSessionService? _session;

  final conversations = <ConversationModel>[].obs;
  final imStateLabel = '未连接'.obs;

  StreamSubscription<List<ConversationModel>>? _convSub;
  StreamSubscription<ImConnectionState>? _imSub;

  @override
  void onInit() {
    super.onInit();
    _bindImState();
    _bindConversations();
    _ensureImAndRefresh();
  }

  void _bindImState() {
    final session = _session;
    if (session == null) return;
    imStateLabel.value = session.currentState.label;
    _imSub = session.connectionState.listen((state) {
      imStateLabel.value = state.label;
      if (state == ImConnectionState.connected) {
        refreshConversations();
      }
    });
  }

  void _bindConversations() {
    _convSub = _repository.watchConversations().listen((list) {
      conversations.assignAll(list);
    });
  }

  Future<void> _ensureImAndRefresh() async {
    await ImInitializer.tryConnectIfReady();
    await refreshConversations();
  }

  Future<void> refreshConversations() async {
    await runAsync(() => _repository.refreshConversations());
  }

  @override
  void onClose() {
    _convSub?.cancel();
    _imSub?.cancel();
    super.onClose();
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatRepository>() &&
        Get.isRegistered<ImSessionService>() &&
        Get.isRegistered<ImUserProfileService>() &&
        Get.isRegistered<ImBackupService>()) {
      Get.put<ChatRepository>(
        ImChatRepository(
          sessionService: Get.find<ImSessionService>(),
          profileService: Get.find<ImUserProfileService>(),
          backupService: Get.find<ImBackupService>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<ChatViewModel>(() => ChatViewModel(), fenix: true);
  }
}
