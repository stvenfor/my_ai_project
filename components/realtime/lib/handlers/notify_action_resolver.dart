import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';
import 'package:module_linking/models/app_route_intent.dart';
import 'package:module_linking/navigation/app_navigator.dart';
import 'package:module_utils/module_utils.dart';

/// 将 sys.notify payload.action 解析为 Banner 点击回调。
VoidCallback? resolveNotifyTap({
  required Map<String, dynamic> extras,
  required String notifyId,
}) {
  final actionRaw = extras['action'];
  if (actionRaw is! Map) return null;

  final action = Map<String, dynamic>.from(actionRaw);
  final url = _actionToUrl(action);
  if (url == null || url.isEmpty) return null;

  return () => _navigateFromAction(url: url, notifyId: notifyId);
}

String? _actionToUrl(Map<String, dynamic> action) {
  final url = action['url']?.toString();
  if (url != null && url.isNotEmpty) return url;

  final route = action['route']?.toString();
  if (route == null || route.isEmpty) return null;
  if (route.startsWith('http')) return route;
  if (route.startsWith('/app')) {
    return 'https://xiaomaomain.com$route';
  }
  return 'https://xiaomaomain.com/app$route';
}

Future<void> _navigateFromAction({
  required String url,
  required String notifyId,
}) async {
  if (!Get.isRegistered<AppNavigator>()) {
    LogUtils.w('[GlobalNotify] AppNavigator 未注册，跳过 action 跳转 url=$url');
    return;
  }

  const parser = AppLinkParser();
  final intent = parser.parse(url);
  if (intent == null) {
    LogUtils.w('[GlobalNotify] 无法解析 action url=$url');
    return;
  }

  await Get.find<AppNavigator>().navigate(
    intent.copyWith(
      source: LinkSource.push,
      msgId: notifyId,
    ),
  );
}
