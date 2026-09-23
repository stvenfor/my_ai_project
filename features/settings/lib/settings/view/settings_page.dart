import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_settings/mine/theme/mine_theme.dart';
import 'package:module_settings/settings/viewmodel/settings_viewmodel.dart';
import 'package:wys_router/src/route/route_path.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsViewModel get _vm => Get.find<SettingsViewModel>();

  Future<void> _refreshAfter(Future<void> Function() action) async {
    await action();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final config = _vm.config;
    final envService = _vm.envService;

    // Rebuild when themeMode flips so MineTheme + chrome stay in lockstep.
    return Obx(() {
      final configLive = Get.isRegistered<AppConfigController>()
          ? Get.find<AppConfigController>()
          : null;
      final themeMode = configLive?.themeModeRx.value ?? config?.themeMode;

      return AppPageScaffold(
        backgroundColor: MineTheme.background,
        navBar: const AppNavBar(title: '设置', showBackButton: true),
        body: config == null
            ? Center(
                child: Text(
                  '应用配置未初始化',
                  style: MineTheme.caption,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  const _SectionHeader('通用'),
                  _SettingsCard(
                    children: [
                      if (envService != null) ...[
                        Obx(
                          () => _NavTile(
                            icon: CupertinoIcons.cloud,
                            title: '运行环境',
                            value:
                                '${envService.config.label} · ${envService.backendBaseUrl}',
                            onTap: () => _showEnvironmentPicker(
                              envService.currentEnv.value,
                            ),
                          ),
                        ),
                        const _RowDivider(),
                      ],
                      _SwitchTile(
                        icon: CupertinoIcons.moon_stars,
                        title: '深色模式',
                        subtitle: '切换浅色 / 深色主题',
                        value: themeMode == ThemeMode.dark,
                        onChanged: (_) => _refreshAfter(_vm.toggleTheme),
                      ),
                      const _RowDivider(),
                      _NavTile(
                        icon: CupertinoIcons.globe,
                        title: '语言',
                        value: _localeLabel(config.locale),
                        onTap: () =>
                            _showLanguagePicker(config.locale.languageCode),
                      ),
                    ],
                  ),
                  const _SectionHeader('示例'),
                  _SettingsCard(
                    children: [
                      _NavTile(
                        icon: CupertinoIcons.bluetooth,
                        title: '蓝牙连接示例',
                        subtitle: 'BLE 扫描、连接、服务发现',
                        onTap: () => Get.toNamed(RoutePath.bluetoothDemo),
                      ),
                    ],
                  ),
                  if (kDebugMode) ...[
                    const _SectionHeader('开发调试'),
                    _SettingsCard(
                      children: [
                        _NavTile(
                          icon: CupertinoIcons.square_stack_3d_up,
                          title: '弹框调度示例',
                          subtitle: '样式、优先级队列、清空/取消待展示',
                          onTap: () => Get.toNamed(RoutePath.dialogDemo),
                        ),
                        const _RowDivider(),
                        _NavTile(
                          icon: CupertinoIcons.link,
                          title: '链接与推送调试',
                          subtitle: 'Mock Deeplink / 前台 Push Banner',
                          onTap: () => Get.toNamed(RoutePath.linkingDebug),
                        ),
                        const _RowDivider(),
                        _NavTile(
                          icon: CupertinoIcons.antenna_radiowaves_left_right,
                          title: 'Realtime / WebSocket 调试',
                          subtitle: '连接状态、Mock 信令、离线队列',
                          onTap: () => Get.toNamed(RoutePath.realtimeDebug),
                        ),
                        const _RowDivider(),
                        _NavTile(
                          icon: CupertinoIcons.chat_bubble_2,
                          title: '融云 IM 调试',
                          subtitle: 'imUserId、连接态、备份队列',
                          onTap: () => Get.toNamed(RoutePath.imDebug),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
      );
    });
  }

  String _localeLabel(Locale locale) {
    return switch (locale.languageCode) {
      'en' => 'English',
      _ => '简体中文',
    };
  }

  void _showEnvironmentPicker(AppEnv current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: MineTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('选择运行环境', style: MineTheme.headline),
              ),
              for (final env in AppEnv.values)
                ListTile(
                  title: Text(env.label, style: MineTheme.body),
                  subtitle: Text(
                    EnvConfig.of(env).backendBaseUrl,
                    style: MineTheme.caption,
                  ),
                  trailing: current == env
                      ? Icon(
                          CupertinoIcons.checkmark_alt,
                          color: MineTheme.accent,
                        )
                      : null,
                  onTap: () {
                    _refreshAfter(() => _vm.setEnvironment(env));
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(String currentCode) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: MineTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('选择语言', style: MineTheme.headline),
              ),
              ListTile(
                title: Text('简体中文', style: MineTheme.body),
                trailing: currentCode == 'zh'
                    ? Icon(
                        CupertinoIcons.checkmark_alt,
                        color: MineTheme.accent,
                      )
                    : null,
                onTap: () {
                  _refreshAfter(() => _vm.setLocale(const Locale('zh')));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('English', style: MineTheme.body),
                trailing: currentCode == 'en'
                    ? Icon(
                        CupertinoIcons.checkmark_alt,
                        color: MineTheme.accent,
                      )
                    : null,
                onTap: () {
                  _refreshAfter(() => _vm.setLocale(const Locale('en')));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: MineTheme.caption.copyWith(
          color: MineTheme.labelTertiary,
          fontWeight: FontWeight.w600,
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
      decoration: MineTheme.groupedCardDecoration,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 52,
      color: MineTheme.separator,
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: MineTheme.accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: MineTheme.body),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: MineTheme.caption),
                      ],
                      if (value != null && subtitle == null) ...[
                        const SizedBox(height: 2),
                        Text(
                          value!,
                          style: MineTheme.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (value != null && subtitle != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      value!,
                      style: MineTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: MineTheme.labelTertiary,
                ),
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
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: MineTheme.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: MineTheme.body),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: MineTheme.caption),
                  ],
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: MineTheme.accent,
            ),
          ],
        ),
      ),
    );
  }
}
