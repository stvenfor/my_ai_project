import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/bindings/chat_detail_binding.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/view/chat_detail_page.dart';
import 'package:module_chat/chat/viewmodel/chat_viewmodel.dart';
import 'package:module_chat/chat/widgets/conversation_list_empty.dart';
import 'package:module_chat/chat/widgets/conversation_list_item.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:wys_router/wys_router.dart';

class ChatPage extends GetView<ChatViewModel> {
  const ChatPage({super.key});

  void _openConversation(ConversationModel conversation) {
    Get.to<void>(
      () => ChatDetailPage(conversation: conversation),
      binding: ChatDetailBinding(conversation),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    )?.then((_) => controller.refreshConversations());
  }

  void _openFriends() {
    Get.toNamed(RoutePath.friend);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: ChatTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
              constraints.maxWidth >= 840 ? 720.0 : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      AppSafeInsets.top(context) + 8,
                      8,
                      8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('消息', style: ChatTheme.largeTitle),
                        ),
                        IconButton(
                          icon: Obx(
                            () => Icon(
                              controller.searchOpen.value
                                  ? CupertinoIcons.xmark
                                  : CupertinoIcons.search,
                              color: ChatTheme.accent,
                            ),
                          ),
                          onPressed: controller.toggleSearch,
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.square_pencil,
                            color: ChatTheme.accent,
                          ),
                          onPressed: _openFriends,
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (!controller.searchOpen.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: TextField(
                          controller: controller.searchController,
                          autofocus: true,
                          onChanged: controller.onSearchQueryChanged,
                          style: ChatTheme.body,
                          decoration: InputDecoration(
                            hintText: '搜索会话名称或消息',
                            hintStyle: ChatTheme.subhead.copyWith(
                              color: ChatTheme.labelTertiary,
                            ),
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                              size: 18,
                              color: ChatTheme.labelTertiary,
                            ),
                            suffixIcon: Obx(() {
                              if (controller.searchQuery.value.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  size: 18,
                                  color: ChatTheme.labelTertiary,
                                ),
                                onPressed: controller.clearSearchQuery,
                              );
                            }),
                            filled: true,
                            fillColor: ChatTheme.surface,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(ChatTheme.radiusLg),
                              borderSide:
                                  BorderSide(color: ChatTheme.separator),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(ChatTheme.radiusLg),
                              borderSide:
                                  BorderSide(color: ChatTheme.separator),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(ChatTheme.radiusLg),
                              borderSide: BorderSide(
                                color: ChatTheme.accent,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.conversations.isEmpty) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }

                      if (controller.errorMessage.value != null &&
                          controller.conversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.errorMessage.value!,
                                style: ChatTheme.caption,
                              ),
                              const SizedBox(height: 12),
                              CupertinoButton(
                                onPressed: controller.refreshConversations,
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        );
                      }

                      final conversations = controller.visibleConversations;
                      if (controller.conversations.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: controller.refreshConversations,
                          color: ChatTheme.accent,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: ConversationListEmpty(
                                  connectionHint:
                                      'IM ${controller.imStateLabel.value}',
                                  onAddFriend: _openFriends,
                                  onRefreshHint:
                                      controller.refreshConversations,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (conversations.isEmpty) {
                        return Center(
                          child: Text(
                            '没有匹配的会话',
                            style: ChatTheme.subhead,
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: controller.refreshConversations,
                        color: ChatTheme.accent,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            DecoratedBox(
                              decoration: ChatTheme.groupedCardDecoration,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(ChatTheme.radiusMd),
                                child: Column(
                                  children: [
                                    for (var i = 0;
                                        i < conversations.length;
                                        i++) ...[
                                      ConversationListItem(
                                        conversation: conversations[i],
                                        onTap: () => _openConversation(
                                          conversations[i],
                                        ),
                                      ),
                                      if (i < conversations.length - 1)
                                        ChatTheme.groupedDivider(),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
