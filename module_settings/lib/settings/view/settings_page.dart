import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
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
                SwitchListTile(
                  title: const Text('沉浸式模式'),
                  subtitle: const Text('透明状态栏与导航栏，全屏显示'),
                  value: config.immersiveMode,
                  onChanged: (value) =>
                      _refreshAfter(() => _vm.setImmersive(value)),
                ),
                ListTile(
                  title: const Text('语言'),
                  subtitle: Text(_localeLabel(config.locale)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showLanguagePicker(config.locale.languageCode),
                ),
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
