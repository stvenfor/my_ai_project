import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/mine/controller/mine_profile_controller.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:module_utils/module_utils.dart';

/// 个人资料：与「我的」同色系；右上角保存后才提交。
class MineProfilePage extends GetView<MineProfileController> {
  const MineProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: MineTheme.background,
      navBar: AppNavBar(
        title: '个人资料',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        actions: [
          Obx(() {
            final canSave = controller.dirty.value && !controller.saving.value;
            return TextButton(
              onPressed: canSave ? controller.save : null,
              child: Text(
                controller.saving.value ? '保存中' : '保存',
                style: TextStyle(
                  fontFamily: VercelTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: canSave
                      ? MineTheme.accent
                      : MineTheme.labelTertiary,
                ),
              ),
            );
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const SizedBox(height: 16),
          _AvatarHero(controller: controller),
          const SizedBox(height: 32),
          const _SectionLabel('基本信息'),
          const SizedBox(height: 8),
          _InfoCard(controller: controller),
          const SizedBox(height: 32),
          _LogoutCard(onTap: controller.logout),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: MineTheme.caption.copyWith(
          fontSize: 12,
          letterSpacing: 0.4,
          color: MineTheme.labelTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AvatarHero extends StatelessWidget {
  const _AvatarHero({required this.controller});

  final MineProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.pickAvatar();
            },
            child: Obx(() {
              final url = controller.avatarPreview.value;
              final busy = controller.saving.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedOpacity(
                    opacity: busy ? 0.65 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: _ProfileAvatar(url: url, size: 104),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: MineTheme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: MineTheme.surface, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: MineTheme.accent.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: busy
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.camera_fill,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '轻触更换头像',
            style: MineTheme.caption.copyWith(color: MineTheme.labelTertiary),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.controller});

  final MineProfileController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: MineTheme.groupedCardDecoration,
      child: Column(
        children: [
          _NicknameRow(controller: controller),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 16,
            color: MineTheme.separator,
          ),
          Obx(() {
            final phone = controller.phoneMasked.value;
            return _StaticRow(
              label: '手机号',
              value: phone.isEmpty ? '未绑定' : phone,
              muted: phone.isEmpty,
            );
          }),
        ],
      ),
    );
  }
}

class _NicknameRow extends StatelessWidget {
  const _NicknameRow({required this.controller});

  final MineProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text('昵称', style: MineTheme.body.copyWith(fontSize: 15)),
          ),
          Expanded(
            child: TextField(
              controller: controller.nicknameController,
              focusNode: controller.nicknameFocus,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.done,
              style: MineTheme.body.copyWith(fontSize: 15),
              cursorColor: MineTheme.accent,
              onSubmitted: (_) => controller.nicknameFocus.unfocus(),
              decoration: InputDecoration(
                hintText: '请输入昵称',
                hintStyle: MineTheme.body.copyWith(
                  fontSize: 15,
                  color: MineTheme.labelTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: MineTheme.labelTertiary,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _StaticRow extends StatelessWidget {
  const _StaticRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: MineTheme.body.copyWith(fontSize: 15)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: MineTheme.body.copyWith(
                fontSize: 15,
                color: muted ? MineTheme.labelTertiary : MineTheme.labelPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MineTheme.surface,
      borderRadius: BorderRadius.circular(MineTheme.radiusMd),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(MineTheme.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MineTheme.radiusMd),
            border: Border.all(color: MineTheme.separator),
          ),
          alignment: Alignment.center,
          child: const Text(
            '退出登录',
            style: TextStyle(
              fontFamily: VercelTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFDC2626),
              height: 24 / 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url, this.size = 96});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MineTheme.fillSecondary,
        border: Border.all(color: MineTheme.separator, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(url),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) return _placeholder();
    if (url.startsWith('data:')) {
      final bytes = _decodeDataUrl(url);
      if (bytes == null) return _placeholder();
      return Image.memory(bytes, fit: BoxFit.cover, width: size, height: size);
    }
    if (url.startsWith('/') || url.startsWith('file:')) {
      return Image.file(
        File(url.replaceFirst('file:', '')),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return CacheImageUtils.network(url, width: size, height: size, fit: BoxFit.cover);
  }

  Uint8List? _decodeDataUrl(String url) {
    final comma = url.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(url.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _placeholder() {
    return ColoredBox(
      color: MineTheme.fillSecondary,
      child: Icon(
        CupertinoIcons.person_fill,
        size: size * 0.42,
        color: MineTheme.labelTertiary,
      ),
    );
  }
}
