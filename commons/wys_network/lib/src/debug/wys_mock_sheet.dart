import 'package:flutter/material.dart';

import '../mock/wys_mock_manager.dart';
import '../wys_app_navigator.dart';

Future<void> showWysMockSheet(BuildContext? context) async {
  final navContext = WysAppNavigator.overlayContext ?? context;
  if (navContext == null || !navContext.mounted) return;

  await showDialog<void>(
    context: navContext,
    barrierDismissible: true,
    builder: (ctx) =>
        const Dialog(child: SizedBox(width: 300, child: _WysMockSheetBody())),
  );
}

class _WysMockSheetBody extends StatefulWidget {
  const _WysMockSheetBody();

  @override
  State<_WysMockSheetBody> createState() => _WysMockSheetBodyState();
}

class _WysMockSheetBodyState extends State<_WysMockSheetBody> {
  late bool _enabled;
  late bool _userEnabled;
  late bool _apiEnabled;

  @override
  void initState() {
    super.initState();
    _enabled = WysMockManager.enabled;
    _userEnabled = WysMockManager.userEnabled;
    _apiEnabled = WysMockManager.apiEnabled;
  }

  Future<void> _save() async {
    await WysMockManager.configure(
      mockEnabled: _enabled,
      mockUser: _userEnabled,
      mockApi: _apiEnabled,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Mock 开关已保存，重启应用后用户登录态会重新初始化')),
    );
  }

  Future<void> _reset() async {
    await WysMockManager.resetLocalSwitches();
    setState(() {
      _enabled = WysMockManager.enabled;
      _userEnabled = WysMockManager.userEnabled;
      _apiEnabled = WysMockManager.apiEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Mock 开关',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            title: const Text('总开关'),
            subtitle: const Text('关闭后用户和接口 mock 都不生效'),
          ),
          SwitchListTile(
            value: _userEnabled,
            onChanged: _enabled
                ? (v) => setState(() => _userEnabled = v)
                : null,
            title: const Text('Mock 用户数据'),
          ),
          SwitchListTile(
            value: _apiEnabled,
            onChanged: _enabled ? (v) => setState(() => _apiEnabled = v) : null,
            title: const Text('Mock 接口数据'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(onPressed: _reset, child: const Text('恢复默认')),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FilledButton(onPressed: _save, child: const Text('保存')),
            ],
          ),
        ],
      ),
    );
  }
}
