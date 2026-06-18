import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/settings/viewmodel/settings_viewmodel.dart';

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

    return AppPageScaffold(
      navBar: const AppNavBar(title: '设置', showBackButton: true),
      body: config == null
          ? const Center(child: Text('应用配置未初始化'))
          : ListView(
              children: [
                if (envService != null)
                  Obx(
                    () => ListTile(
                      title: const Text('运行环境'),
                      subtitle: Text(
                        '${envService.config.label} · ${envService.baseUrl}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showEnvironmentPicker(
                        envService.currentEnv.value,
                      ),
                    ),
                  ),
                SwitchListTile(
                  title: const Text('深色模式'),
                  subtitle: const Text('切换浅色 / 深色主题'),
                  value: config.themeMode == ThemeMode.dark,
                  onChanged: (_) => _refreshAfter(_vm.toggleTheme),
                ),
                ListTile(
                  title: const Text('语言'),
                  subtitle: Text(_localeLabel(config.locale)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showLanguagePicker(config.locale.languageCode),
                ),
                ListTile(
                  title: const Text('蓝牙连接示例'),
                  subtitle: const Text('BLE 扫描、连接、服务发现'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Get.toNamed(RoutePath.bluetoothDemo),
                ),
                ListTile(
                  title: const Text('新车成交示例'),
                  subtitle: const Text('悬浮 Tab、下拉刷新、上拉加载更多'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Get.toNamed(RoutePath.dealInvoiceDemo),
                ),
                if (kDebugMode) ...[
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '开发调试',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('弹框调度示例'),
                    subtitle: const Text('样式、优先级队列、清空/取消待展示'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.toNamed(RoutePath.dialogDemo),
                  ),
                  ListTile(
                    title: const Text('链接与推送调试'),
                    subtitle: const Text('Mock Deeplink / 前台 Push Banner'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.toNamed(RoutePath.linkingDebug),
                  ),
                  ListTile(
                    title: const Text('Realtime / WebSocket 调试'),
                    subtitle: const Text('连接状态、Mock 信令、离线队列'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.toNamed(RoutePath.realtimeDebug),
                  ),
                  ListTile(
                    title: const Text('融云 IM 调试'),
                    subtitle: const Text('imUserId、连接态、备份队列'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Get.toNamed(RoutePath.imDebug),
                  ),
                ],
              ],
            ),
    );
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
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final env in AppEnv.values)
                ListTile(
                  title: Text(env.label),
                  subtitle: Text(EnvConfig.of(env).baseUrl),
                  trailing: current == env
                      ? const Icon(Icons.check_rounded, color: Colors.blue)
                      : null,
                  onTap: () {
                    _refreshAfter(() => _vm.setEnvironment(env));
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(String currentCode) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('简体中文'),
                onTap: () {
                  _refreshAfter(
                    () => _vm.setLocale(const Locale('zh')),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  _refreshAfter(
                    () => _vm.setLocale(const Locale('en')),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
