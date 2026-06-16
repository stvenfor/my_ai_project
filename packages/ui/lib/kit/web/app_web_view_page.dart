import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebMessage;
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';

/// 统一 WebView 页面：支持本地 asset 与远程 URL，内置 JS Bridge。
class AppWebViewPage extends StatefulWidget {
  const AppWebViewPage({
    super.key,
    required this.config,
  });

  final WebPageConfig config;

  @override
  State<AppWebViewPage> createState() => _AppWebViewPageState();
}

class _AppWebViewPageState extends State<AppWebViewPage> {
  double _progress = 0;
  String? _error;
  int _reloadKey = 0;

  WebBridgeRegistry get _registry => Get.find<WebBridgeRegistry>();

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return AppPageScaffold(
      layout: config.showAppBar
          ? AppPageLayout.standard
          : AppPageLayout.edgeToEdge,
      navBar: config.showAppBar
          ? AppNavBar(
              title: config.displayTitle,
              showBackButton: config.showBackButton,
              onBack: config.showBackButton ? () => Get.back<void>() : null,
            )
          : null,
      body: Column(
        children: [
          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(value: _progress),
          Expanded(
            child: _error != null
                ? _ErrorBody(
                    message: _error!,
                    onRetry: () => setState(() {
                      _error = null;
                      _reloadKey++;
                    }),
                  )
                : InAppWebView(
                    key: ValueKey(_reloadKey),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: widget.config.enableJavaScript,
                      transparentBackground: true,
                      useHybridComposition: true,
                    ),
                    initialFile:
                        widget.config.loadType == WebPageLoadType.asset
                            ? widget.config.assetPath
                            : null,
                    initialUrlRequest:
                        widget.config.loadType == WebPageLoadType.url
                            ? URLRequest(
                                url: WebUri(widget.config.url!),
                              )
                            : null,
                    onWebViewCreated: _onWebViewCreated,
                    onLoadStop: _onLoadStop,
                    onProgressChanged: (_, progress) {
                      setState(() => _progress = progress / 100);
                    },
                    onReceivedError: (controller, request, error) {
                      if (request.isForMainFrame ?? false) {
                        setState(() => _error = error.description);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: WebBridgeConstants.channelName,
      callback: (args) async {
        final raw = args.isNotEmpty ? args.first : null;
        final message = WebMessage.fromDynamic(raw);
        return _registry.dispatch(message);
      },
    );
  }

  Future<void> _onLoadStop(InAppWebViewController controller, WebUri? url) async {
    await _injectFlutterParams(controller);
  }

  Future<void> _injectFlutterParams(InAppWebViewController controller) async {
    final params = widget.config.params;
    if (params.isEmpty) {
      await controller.evaluateJavascript(source: '''
        window.dispatchEvent(new Event('${WebBridgeConstants.jsReadyEvent}'));
      ''');
      return;
    }

    final json = jsonEncode(params);
    await controller.evaluateJavascript(source: '''
      window.${WebBridgeConstants.jsParamsKey} = $json;
      window.dispatchEvent(new Event('${WebBridgeConstants.jsReadyEvent}'));
    ''');
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
