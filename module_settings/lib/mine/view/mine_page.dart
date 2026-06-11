import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_settings/mine/controller/mine_controller.dart';
import 'package:module_settings/mine/model/level_card_model.dart';

class MinePage extends GetView<MineController> {
  const MinePage({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF5F4),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _MineHeader(
              showBackButton: showBackButton,
              controller: controller,
            ),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 36),
                  itemBuilder: (context, index) {
                    final level = controller.levels[index];
                    return _LevelCard(
                      data: level,
                      onTap: () => controller.openTestPage(level),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 38),
                  itemCount: controller.levels.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MineHeader extends StatelessWidget {
  const _MineHeader({
    required this.showBackButton,
    required this.controller,
  });

  final bool showBackButton;
  final MineController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showBackButton)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      iconSize: 34,
                      color: const Color(0xFF2F3034),
                      onPressed: () => Get.back<void>(),
                      tooltip: '返回',
                    ),
                  ),
                const Text(
                  '我的',
                  style: TextStyle(
                    color: Color(0xFF2B2D31),
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFEEF5F4),
                  backgroundImage: controller.avatarUrl.value != null
                      ? NetworkImage(controller.avatarUrl.value!)
                      : null,
                  child: controller.avatarUrl.value == null
                      ? const Icon(Icons.person_outline_rounded, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.displayName.value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2D31),
                        ),
                      ),
                      if (controller.userId.value != null)
                        Text(
                          'ID: ${controller.userId.value}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A8D93),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.data,
    required this.onTap,
  });

  final LevelCardModel data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 146,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 0,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 26, 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2E3034),
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (data.collecting) ...[
                            const SizedBox(width: 14),
                            const _CollectingTag(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFFA8ABAF),
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(text: '知识卡片收集进度：   '),
                            TextSpan(
                              text: '${data.collected}',
                              style: const TextStyle(
                                color: Color(0xFF313236),
                              ),
                            ),
                            TextSpan(text: '/${data.total}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.locked) ...[
                  const SizedBox(width: 18),
                  const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFFDDE3E5),
                    size: 42,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectingTag extends StatelessWidget {
  const _CollectingTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE4FCE8),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Text(
        '收集中',
        style: TextStyle(
          color: Color(0xFF53D65B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
