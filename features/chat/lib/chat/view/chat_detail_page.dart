import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/input_panel.dart';
import 'package:module_chat/chat/widgets/message_list_view.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class ChatDetailPage extends GetView<ChatDetailViewModel> {
  ChatDetailPage({super.key, ConversationModel? conversation})
      : conversation = conversation ?? Get.arguments as ConversationModel;

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: ChatTheme.background,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth >= 840 ? 720.0 : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  _ChatDetailHeader(
                    conversation: conversation,
                    onBack: () => Get.back<void>(),
                  ),
                  Expanded(
                    child: MessageListView(peerAvatar: conversation.peerAvatar),
                  ),
                  const InputPanel(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatDetailHeader extends StatelessWidget {
  const _ChatDetailHeader({
    required this.conversation,
    required this.onBack,
  });

  final ConversationModel conversation;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ChatTheme.surface,
      padding: EdgeInsets.only(
        top: AppSafeInsets.top(context),
        left: 4,
        right: 4,
        bottom: 8,
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onBack,
            child: const Icon(
              CupertinoIcons.back,
              color: ChatTheme.accent,
              size: 24,
            ),
          ),
          CacheImageUtils.circle(conversation.peerAvatar, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.peerName,
                  style: ChatTheme.headline.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  conversation.isOnline ? '在线' : '离线',
                  style: ChatTheme.caption.copyWith(
                    color: conversation.isOnline
                        ? ChatTheme.online
                        : ChatTheme.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: const Icon(
              CupertinoIcons.ellipsis,
              color: ChatTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}
