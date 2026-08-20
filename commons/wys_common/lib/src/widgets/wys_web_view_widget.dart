import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/wys_web_page_args.dart';
import 'wys_page_state.dart';

/// 可复用的 WebView 组件：按 [WysWebPageArgs] 加载内容，内置加载态与错误重试。
class WysWebViewWidget extends StatefulWidget {
  const WysWebViewWidget({
    super.key,
    required this.args,
    this.retryKey = 0,
    this.onRetry,
    this.onControllerCreated,
    this.onPageFinished,
  });

  final WysWebPageArgs args;
  final int retryKey;
  final VoidCallback? onRetry;
  final ValueChanged<WebViewController>? onControllerCreated;
  final VoidCallback? onPageFinished;

  @override
  State<WysWebViewWidget> createState() => _WysWebViewWidgetState();
}

class _WysWebViewWidgetState extends State<WysWebViewWidget> {
  static const _heightChannel = 'WysWebViewHeight';
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  double? _contentHeight;

  @override
  void initState() {
    super.initState();
    _prepareAndLoad();
  }

  @override
  void didUpdateWidget(covariant WysWebViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.retryKey != widget.retryKey ||
        oldWidget.args.url != widget.args.url ||
        oldWidget.args.htmlContent != widget.args.htmlContent ||
        oldWidget.args.adaptiveHeight != widget.args.adaptiveHeight) {
      _prepareAndLoad();
    }
  }

  Future<void> _prepareAndLoad() async {
    _contentHeight = null;
    _controller = _createController();
    widget.onControllerCreated?.call(_controller!);
    await _loadContent();
  }

  WebViewController _createController() {
    final controller = WebViewController()
      ..setJavaScriptMode(
        widget.args.enableJs
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            if (widget.args.adaptiveHeight) {
              _controller?.runJavaScript(_heightObserverScript);
            }
            widget.onPageFinished?.call();
          },
          onProgress: (progress) {
            if (progress >= 100 && mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == true) {
              _markWebError();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
    if (widget.args.adaptiveHeight) {
      controller.addJavaScriptChannel(
        _heightChannel,
        onMessageReceived: (message) => _updateContentHeight(message.message),
      );
    }
    return controller;
  }

  void _updateContentHeight(String value) {
    final height = double.tryParse(value);
    if (!mounted || height == null || !height.isFinite || height <= 0) return;
    if (_contentHeight != null && (height - _contentHeight!).abs() < 0.5) {
      return;
    }
    setState(() => _contentHeight = height);
  }

  static const _heightObserverScript =
      '''
(function() {
  function resetImage(img) {
    if (!img) return;
    img.style.setProperty('max-width', '100%', 'important');
    img.style.setProperty('height', 'auto', 'important');
  }
  function reportHeight() {
    var body = document.body;
    var root = document.documentElement;
    var height = Math.max(body ? body.scrollHeight : 0,
      body ? body.offsetHeight : 0, root ? root.scrollHeight : 0,
      root ? root.offsetHeight : 0);
    if (height > 0 && window.$_heightChannel) {
      window.$_heightChannel.postMessage(String(height));
    }
  }
  function resetAndReport(img) {
    resetImage(img);
    requestAnimationFrame(reportHeight);
  }
  if (window.__tfHeightObserver) window.__tfHeightObserver.disconnect();
  if (window.ResizeObserver) {
    window.__tfHeightObserver = new ResizeObserver(reportHeight);
    window.__tfHeightObserver.observe(document.documentElement);
    if (document.body) window.__tfHeightObserver.observe(document.body);
  }
  Array.prototype.forEach.call(document.images || [], function(img) {
    if (img.complete && img.naturalWidth) {
      resetImage(img);
    } else {
      img.addEventListener('load', function() { resetAndReport(img); });
      img.addEventListener('error', reportHeight);
    }
  });
  reportHeight();
  setTimeout(function() {
    Array.prototype.forEach.call(document.images || [], resetImage);
    reportHeight();
  }, 100);
  setTimeout(function() {
    Array.prototype.forEach.call(document.images || [], resetImage);
    reportHeight();
  }, 500);
})();
''';

  String _wrapHtml(String body) {
    final overflow = widget.args.adaptiveHeight ? 'hidden' : 'auto';
    return '''<!DOCTYPE html>
<html><head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>html,body{margin:0;padding:0;width:100%;overflow-x:hidden;overflow-y:$overflow;background:transparent;}
img{max-width:100% !important;height:auto !important;}
p{margin:0;padding:0;}</style></head><body>$body</body></html>''';
  }

  void _markWebError() {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  Future<void> _loadContent() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final controller = _controller!;
      final args = widget.args;

      if (args.loadMode == WysWebLoadMode.directHtml) {
        final html = args.htmlContent ?? '';
        await controller.loadHtmlString(_wrapHtml(html), baseUrl: args.baseUrl);
      } else if (args.loadMode == WysWebLoadMode.htmlString) {
        final html = await _fetchHtmlString();
        if (!mounted) return;
        await controller.loadHtmlString(html, baseUrl: args.baseUrl);
      } else if (args.isAssets) {
        await controller.loadFlutterAsset(args.url);
      } else if (_isRemoteUrl(args.url)) {
        final uri = Uri.parse(args.url);
        if (args.headers != null && args.headers!.isNotEmpty) {
          await controller.loadRequest(uri, headers: args.headers!);
        } else {
          await controller.loadRequest(uri);
        }
      } else {
        await controller.loadFlutterAsset(args.url);
      }
      if (!mounted) return;
      // loadRequest 返回后 WebView 可能尚未回调 onPageFinished，避免一直转圈。
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<String> _fetchHtmlString() async {
    final args = widget.args;
    if (args.isAssets) {
      return DefaultAssetBundle.of(context).loadString(args.url);
    }
    final response = await Dio().get<dynamic>(
      args.url,
      options: args.headers == null ? null : Options(headers: args.headers),
    );
    return '${response.data ?? ''}';
  }

  bool _isRemoteUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  void _handleRetry() {
    if (widget.onRetry != null) {
      widget.onRetry!();
      return;
    }
    _prepareAndLoad();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return WysErrorRetryView(message: '内容加载失败', onRetry: _handleRetry);
    }
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final content = Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.args.allowInteraction,
            child: WebViewWidget(controller: controller),
          ),
        ),
        if (_isLoading)
          const ColoredBox(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
    if (!widget.args.adaptiveHeight) return content;
    return SizedBox(
      height: _contentHeight ?? widget.args.initialHeight,
      child: content,
    );
  }
}
