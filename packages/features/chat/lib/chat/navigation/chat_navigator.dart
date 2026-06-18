import 'package:get/get.dart';
import 'package:module_chat/chat/bindings/chat_detail_binding.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/repository/im_chat_repository.dart';
import 'package:module_chat/chat/view/chat_detail_page.dart';
import 'package:module_core/model/im/conversation_ref.dart';

/// 跨模块打开聊天（社区/好友/直播等入口）。
class ChatNavigator {
  ChatNavigator._();

  static Future<void> openPrivate({
    required String peerImUserId,
  }) async {
    final repo = resolveChatRepository();
    final conv = await repo.ensurePrivateConversation(peerImUserId);
    await Get.to<void>(
      () => ChatDetailPage(conversation: conv),
      binding: ChatDetailBinding(conv),
    );
  }

  static Future<void> openConversation(ConversationModel conversation) async {
    await Get.to<void>(
      () => ChatDetailPage(conversation: conversation),
      binding: ChatDetailBinding(conversation),
    );
  }

  static Future<ConversationModel> resolvePrivateConversation(
    String peerImUserId,
  ) async {
    final repo = resolveChatRepository();
    return repo.ensurePrivateConversation(peerImUserId);
  }

  static ConversationRef refFromArgs(Object? args) {
    if (args is ConversationModel) return args.ref;
    if (args is Map) {
      return ConversationRef.parse(
        type: args['type']?.toString() ?? 'private',
        targetId: args['targetId']?.toString() ?? args['peerId']?.toString() ?? '',
      );
    }
    throw ArgumentError('invalid chat args');
  }
}
