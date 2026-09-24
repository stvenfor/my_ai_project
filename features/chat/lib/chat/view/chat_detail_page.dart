import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/input_panel.dart';
import 'package:module_chat/chat/widgets/message_list_view.dart';
import 'package:module_chat/chat/widgets/voice_record_overlay.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_rongcloud_im/api/im_friend_api.dart';
import 'package:module_rongcloud_im/api/im_group_api.dart';
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      _ChatDetailHeader(
                        conversation: conversation,
                        onBack: () => Get.back<void>(),
                        onMore: conversation.isGroup
                            ? () => _showGroupActions(context)
                            : null,
                      ),
                      Expanded(
                        child: MessageListView(
                          peerAvatar: conversation.peerAvatar,
                        ),
                      ),
                      const InputPanel(),
                    ],
                  ),
                  const VoiceRecordOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showGroupActions(BuildContext context) async {
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(conversation.peerName),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'invite'),
            child: const Text('邀请好友'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'quit'),
            child: const Text('退出群聊'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, 'dismiss'),
            child: const Text('解散群聊（群主）'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final api = ImGroupApi();
    final groupId = conversation.targetId;
    try {
      switch (action) {
        case 'invite':
          final friends = await ImFriendApi().listFriends();
          if (!context.mounted) return;
          if (friends.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('暂无好友可邀请')),
            );
            return;
          }
          final picked = await showDialog<List<String>>(
            context: context,
            builder: (ctx) {
              final selected = <String>{};
              return StatefulBuilder(
                builder: (ctx, setLocal) {
                  return AlertDialog(
                    title: const Text('邀请好友入群'),
                    content: SizedBox(
                      width: 320,
                      height: 280,
                      child: ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (_, i) {
                          final u = friends[i];
                          return CheckboxListTile(
                            dense: true,
                            value: selected.contains(u.userId),
                            title: Text(u.displayName),
                            onChanged: (v) {
                              setLocal(() {
                                if (v == true) {
                                  selected.add(u.userId);
                                } else {
                                  selected.remove(u.userId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, selected.toList()),
                        child: const Text('邀请'),
                      ),
                    ],
                  );
                },
              );
            },
          );
          if (picked == null || picked.isEmpty) return;
          await api.invite(groupId: groupId, memberIds: picked);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已发送邀请')),
            );
          }
        case 'quit':
          await api.quit(groupId);
          if (context.mounted) {
            Get.back<void>();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已退群')),
            );
          }
        case 'dismiss':
          await api.dismiss(groupId);
          if (context.mounted) {
            Get.back<void>();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('群已解散')),
            );
          }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _ChatDetailHeader extends StatelessWidget {
  const _ChatDetailHeader({
    required this.conversation,
    required this.onBack,
    this.onMore,
  });

  final ConversationModel conversation;
  final VoidCallback onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChatTheme.surface,
        border: Border(
          bottom: BorderSide(color: ChatTheme.separator, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSafeInsets.top(context),
        left: 4,
        right: 8,
        bottom: 10,
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: onBack,
            child: Icon(
              CupertinoIcons.back,
              color: ChatTheme.accent,
              size: 24,
            ),
          ),
          CacheImageUtils.circle(conversation.peerAvatar, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.peerName,
                  style: ChatTheme.headline.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  conversation.isGroup
                      ? '群聊'
                      : (conversation.isOnline ? '在线' : '离线'),
                  style: ChatTheme.caption.copyWith(
                    color: conversation.isGroup
                        ? ChatTheme.labelSecondary
                        : (conversation.isOnline
                            ? ChatTheme.online
                            : ChatTheme.labelTertiary),
                  ),
                ),
              ],
            ),
          ),
          if (onMore != null)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: onMore,
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                color: ChatTheme.labelSecondary,
                size: 26,
              ),
            ),
        ],
      ),
    );
  }
}
