import 'package:flutter/material.dart';

import '../app_environment.dart';
import '../https_client.dart';
import '../wys_api_hosts.dart';
import '../wys_app_navigator.dart';
import '../wys_net_environment_store.dart';

/// 对齐 iOS `WysBaseUrlAlertController`（三档 URL + 确定修改）。
Future<void> showWysBaseUrlSheet(
  BuildContext? context, {
  void Function(String message)? onApplied,
}) async {
  final navContext = WysAppNavigator.overlayContext ?? context;
  if (navContext == null || !navContext.mounted) return;

  final current = AppEnvironment.instance.baseUrl;
  await showDialog<void>(
    context: navContext,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 290,
          child: _WysBaseUrlSheetBody(
            initialUrl: current,
            onApplied: onApplied,
          ),
        ),
      );
    },
  );
}

class _WysBaseUrlSheetBody extends StatefulWidget {
  const _WysBaseUrlSheetBody({
    required this.initialUrl,
    this.onApplied,
  });

  final String initialUrl;
  final void Function(String message)? onApplied;

  @override
  State<_WysBaseUrlSheetBody> createState() => _WysBaseUrlSheetBodyState();
}

class _WysBaseUrlSheetBodyState extends State<_WysBaseUrlSheetBody> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickUrl(String url) {
    setState(() => _controller.text = url);
  }

  Future<void> _sure() async {
    final url = _controller.text.trim();
    final env = WysNetEnvironmentStore.environmentForUrl(url);
    await WysNetEnvironmentStore.persistEnvironment(
      env,
      customBaseUrl: env == WysNetEnvironment.custom ? url : null,
    );
    AppEnvironment.applyRuntime(netEnvironment: env, baseUrl: url);
    HttpsClient.reset();
    if (!mounted) return;
    Navigator.pop(context);
    widget.onApplied?.call('请重新登录');
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '修改地址',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 12),
          _EnvButton(
            title: '点击开发地址:${WysApiHosts.dev}',
            onTap: () => _pickUrl(WysApiHosts.dev),
          ),
          _EnvButton(
            title: '点击测试地址:${WysApiHosts.test}',
            onTap: () => _pickUrl(WysApiHosts.test),
          ),
          _EnvButton(
            title: '点击正式地址:${WysApiHosts.product}',
            onTap: () => _pickUrl(WysApiHosts.product),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(165, 45),
            ),
            onPressed: _sure,
            child: const Text('确定修改'),
          ),
        ],
      ),
    );
  }
}

class _EnvButton extends StatelessWidget {
  const _EnvButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 15)),
    );
  }
}