import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/layout/app_nav_bar.dart';
import 'package:module_common_ui/layout/app_page_scaffold.dart';
import 'package:module_common_ui/layout/app_safe_insets.dart';
import 'package:module_common_ui/theme/app_theme.dart';
import 'package:module_settings/mine/personalized_settings/personalized_settings_assets.dart';
import 'package:module_settings/mine/personalized_settings/personalized_settings_controller.dart';

class PersonalizedSettingsPage extends GetView<PersonalizedSettingsController> {
  const PersonalizedSettingsPage({super.key});

  static const _pageBg = Color(0xFFF5F5F5);
  static const _titleColor = Color(0xFF333333);
  static const _sectionColor = Color(0xFF999999);
  static const _valueColor = Color(0xFF666666);
  static const _dividerColor = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _pageBg,
      navBar: const AppNavBar(title: '个性化设置', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SettingsCard(
            children: [
              _NavTile(
                title: '装扮中心',
                onTap: controller.openDecorationCenter,
              ),
            ],
          ),
          const _SectionHeader('模式选择'),
          _SettingsCard(
            children: [
              Obx(() {
                final mode = controller.eyeProtectionMode.value;
                return _NavTile(
                  title: '护眼模式',
                  showHelp: true,
                  onHelpTap: () => controller.showHelp('护眼模式'),
                  trailingText: mode,
                  onTap: controller.pickEyeProtectionMode,
                );
              }),
              const _RowDivider(),
              Obx(() {
                final enabled = controller.teachingMode.value;
                return _SwitchTile(
                  title: '教学模式',
                  showHelp: true,
                  onHelpTap: () => controller.showHelp('教学模式'),
                  value: enabled,
                  onChanged: controller.setTeachingMode,
                );
              }),
            ],
          ),
          const _SectionHeader('个性化设置'),
          _SettingsCard(
            children: [
              Obx(() {
                final enabled = controller.contentRecommendation.value;
                return _SwitchTile(
                  title: '个性化内容推荐',
                  showHelp: true,
                  onHelpTap: () => controller.showHelp('个性化内容推荐'),
                  value: enabled,
                  onChanged: controller.setContentRecommendation,
                );
              }),
              const _RowDivider(),
              Obx(() {
                final enabled = controller.adRecommendation.value;
                return _SwitchTile(
                  title: '个性化广告推荐',
                  showHelp: true,
                  onHelpTap: () => controller.showHelp('个性化广告推荐'),
                  value: enabled,
                  onChanged: controller.setAdRecommendation,
                );
              }),
              const _RowDivider(),
              Obx(() {
                final enabled = controller.oralScoring.value;
                return _SwitchTile(
                  title: '口语评分',
                  value: enabled,
                  onChanged: controller.setOralScoring,
                );
              }),
              const _RowDivider(),
              Obx(() {
                final enabled = controller.cellularVideoReminder.value;
                return _SwitchTile(
                  title: '2/3/4/5G 流量播放视频时提醒我',
                  value: enabled,
                  onChanged: controller.setCellularVideoReminder,
                );
              }),
              const _RowDivider(),
              Obx(() {
                final enabled = controller.uploadStatusMonitor.value;
                return _SwitchTile(
                  title: '作品上传状态监控',
                  value: enabled,
                  onChanged: controller.setUploadStatusMonitor,
                );
              }),
            ],
          ),
          SizedBox(height: AppSafeInsets.bottom(context)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: PersonalizedSettingsPage._sectionColor,
          height: 1.3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 0,
      color: PersonalizedSettingsPage._dividerColor,
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    this.showHelp = false,
    this.onHelpTap,
    this.trailingText,
    required this.onTap,
  });

  final String title;
  final bool showHelp;
  final VoidCallback? onHelpTap;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _TitleRow(
                    title: title,
                    showHelp: showHelp,
                    onHelpTap: onHelpTap,
                  ),
                ),
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: PersonalizedSettingsPage._valueColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                const _ChevronIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    this.showHelp = false,
    this.onHelpTap,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool showHelp;
  final VoidCallback? onHelpTap;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: _TitleRow(
                title: title,
                showHelp: showHelp,
                onHelpTap: onHelpTap,
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppTheme.seedColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.title,
    this.showHelp = false,
    this.onHelpTap,
  });

  final String title;
  final bool showHelp;
  final VoidCallback? onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: PersonalizedSettingsPage._titleColor,
              height: 1.35,
            ),
          ),
        ),
        if (showHelp) ...[
          const SizedBox(width: 4),
          _HelpButton(onTap: onHelpTap),
        ],
      ],
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            PersonalizedSettingsAssets.helpCircle,
            package: PersonalizedSettingsAssets.package,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      PersonalizedSettingsAssets.chevronRight,
      package: PersonalizedSettingsAssets.package,
      width: 16,
      height: 16,
      fit: BoxFit.contain,
    );
  }
}
