import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';

/// 会话列表空态（避免白板）。
class ConversationListEmpty extends StatelessWidget {
  const ConversationListEmpty({
    super.key,
    this.connectionHint,
    this.onAddFriend,
    this.onRefreshHint,
  });

  /// 如「已连接」「连接中」等，可选展示。
  final String? connectionHint;
  final VoidCallback? onAddFriend;
  final VoidCallback? onRefreshHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: ChatTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: ChatTheme.separator),
            ),
            child: Icon(
              CupertinoIcons.chat_bubble_2,
              size: 40,
              color: ChatTheme.labelTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '还没有消息',
            style: ChatTheme.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '加个好友，发一条问候吧',
            style: ChatTheme.subhead,
            textAlign: TextAlign.center,
          ),
          if (connectionHint != null && connectionHint!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              connectionHint!,
              style: ChatTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),
          if (onAddFriend != null)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: onAddFriend,
                style: FilledButton.styleFrom(
                  backgroundColor: ChatTheme.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ChatTheme.radiusLg),
                  ),
                ),
                child: Text(
                  '去通讯录',
                  style: ChatTheme.subhead.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (onRefreshHint != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRefreshHint,
              child: Text('下拉也可刷新', style: ChatTheme.caption),
            ),
          ],
        ],
      ),
    );
  }
}
