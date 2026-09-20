import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_ai/ai/controller/ai_stream_controller.dart';
import 'package:module_ai/ai/model/ai_chat_message.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// AI 小石头客服式气泡页（纯文本流式回复）。
///
/// 颜色走 [ThemeData.colorScheme] / [AppTheme]，不依赖未合入的 Vercel Token 迁移。
class AiStreamPage extends GetView<AiStreamController> {
  const AiStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      body: Column(
        children: [
          Obx(() {
            final streaming = controller.isStreaming.value;
            return AppNavBar(
              title: 'AI 小石头',
              showBackButton: true,
              onBack: () => Get.back<void>(),
              actions: [
                if (streaming)
                  TextButton(
                    onPressed: controller.stop,
                    child: Text(
                      '停止',
                      style: TextStyle(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            );
          }),
          Expanded(
            child: Obx(() {
              final items = controller.messages.toList();
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _Bubble(message: items[index]);
                },
              );
            }),
          ),
          Obx(() {
            final streaming = controller.isStreaming.value;
            final showChips = controller.messages.length <= 1 && !streaming;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showChips) const _QuickPromptChips(),
                _Composer(
                  enabled: !streaming,
                  textController: controller.textController,
                  onSend: controller.send,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _QuickPromptChips extends GetView<AiStreamController> {
  const _QuickPromptChips();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = !controller.isStreaming.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final prompt in AiStreamController.quickPrompts)
              ActionChip(
                label: Text(prompt),
                onPressed:
                    enabled ? () => controller.sendQuickPrompt(prompt) : null,
              ),
          ],
        ),
      );
    });
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.textController,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController textController;
  final bool enabled;
  final Future<void> Function(String text) onSend;

  @override
  Widget build(BuildContext context) {
    final bottom = AppSafeInsets.bottom(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: AppTheme.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottom),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled
                    ? (value) {
                        if (value.trim().isNotEmpty) onSend(value);
                      }
                    : null,
                decoration: InputDecoration(
                  hintText: enabled ? '输入问题…' : '生成中，请稍候…',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.separator),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.separator),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled
                  ? () {
                      final text = textController.text;
                      if (text.trim().isEmpty) return;
                      onSend(text);
                    }
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.role == AiChatRole.user;
    final isWelcome = message.role == AiChatRole.welcome;

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isUser
        ? scheme.primary
        : (isWelcome ? scheme.primaryContainer : AppTheme.surface);
    final fg = isUser
        ? scheme.onPrimary
        : (isWelcome ? scheme.onPrimaryContainer : scheme.onSurface);
    final border =
        isUser || isWelcome ? null : Border.all(color: AppTheme.separator);

    final displayText =
        message.text.isEmpty && message.isStreaming ? '…' : message.text;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: border,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWelcome)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'AI 小石头',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              SelectableText(
                displayText,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              if (message.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  message.errorMessage!,
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
